import 'package:convoquei_app/app/router.dart';
import 'package:convoquei_app/core/constants/app_breakpoints.dart';
import 'package:convoquei_app/core/theme/app_theme.dart';
import 'package:convoquei_app/features/organizations/shared/models/organization_model.dart';
import 'package:convoquei_app/features/organizations/organization_tab.dart';
import 'package:convoquei_app/features/organizations/shared/providers/organization_providers.dart';
import 'package:convoquei_app/features/organizations/shared/providers/selected_organization_provider.dart';
import 'package:convoquei_app/core/widgets/app_header.dart';
import 'package:convoquei_app/design_system/ds.dart';
import 'package:convoquei_app/features/organizations/shared/widgets/organization_side_rail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class OrganizationShell extends ConsumerStatefulWidget {
  final OrganizationModel organization;

  /// The stateful navigation shell provided by GoRouter's [StatefulShellRoute].
  /// Acts as the body widget and exposes [goBranch] for tab switching.
  final StatefulNavigationShell navigationShell;

  /// Per-branch navigator keys — used to delegate back presses to the
  /// active branch's navigator (respects [PopScope] within each branch).
  final List<GlobalKey<NavigatorState>> branchNavigatorKeys;

  const OrganizationShell({
    super.key,
    required this.navigationShell,
    required this.organization,
    required this.branchNavigatorKeys,
  });

  @override
  ConsumerState<OrganizationShell> createState() => _OrganizationShellState();
}

class _OrganizationShellState extends ConsumerState<OrganizationShell> {
  String _orgId() => widget.organization.id;

  // ── Location helpers ────────────────────────────────────────────────────

  bool _isDetailsEventLocation(String path) =>
      path.startsWith('${AppPaths.orgEvents(_orgId())}/');

  bool _showTabBar(String path) {
    final id = _orgId();
    // Settings sub-pages (roles, functions, groups) hide the tab bar
    if (path.startsWith('${AppPaths.orgSettings(id)}/')) return false;
    // Members page accessed from within the Ministério branch
    if (path.startsWith(AppPaths.orgTeam(id))) return false;
    // Event sub-pages (detail, create, edit)
    if (_isDetailsEventLocation(path)) return false;
    return true;
  }

  int _tabIndexForPath(String path) {
    final id = _orgId();
    if (path.startsWith(AppPaths.orgEvents(id))) return 1;
    if (path.startsWith(AppPaths.orgScales(id))) return 2;
    if (path.startsWith(AppPaths.orgSettings(id))) return 3;
    if (path.startsWith(AppPaths.orgTeam(id))) return 3;
    return 0;
  }

  String _titleForPath(String path) {
    final id = _orgId();
    if (path.startsWith(AppPaths.orgSettingsRoles(id))) return 'Gerenciar Papéis';
    if (path.startsWith(AppPaths.orgSettingsFunctions(id))) return 'Gerenciar Funções';
    if (path.startsWith(AppPaths.orgSettingsGroups(id))) return 'Gerenciar Grupos';
    if (path.startsWith(AppPaths.orgTeam(id))) return 'Membros';
    if (path.startsWith(AppPaths.orgCreateEvent(id))) return '';
    if (path.endsWith('/edit')) return '';
    if (_isDetailsEventLocation(path)) return 'Detalhes do Evento';
    if (path.startsWith(AppPaths.orgEvents(id))) return kOrgTabs[1].label;
    if (path.startsWith(AppPaths.orgScales(id))) return kOrgTabs[2].label;
    return kOrgTabs[0].label;
  }

  // ── Navigation actions ──────────────────────────────────────────────────

  void _onTabChanged(int index) {
    widget.navigationShell.goBranch(
      index,
      // Tapping the current tab again resets it to its root page
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  void _exitOrganization() {
    ref.invalidate(currentUserMembershipOrganizationProvider(_orgId()));
    ref.read(selectedOrganizationProvider.notifier).clear();
    context.goNamed(AppRoutes.home);
  }

  void _handleBack(String path) {
    // Delegate to the active branch's navigator so that PopScope widgets
    // inside child pages (e.g. WizardPage) can intercept the back action.
    final branchIndex = _tabIndexForPath(path);
    final branchNav = widget.branchNavigatorKeys[branchIndex].currentState;
    if (branchNav != null && branchNav.canPop()) {
      branchNav.maybePop();
      return;
    }

    // Branch has nothing to pop — exit the organization.
    _exitOrganization();
  }

  // ── Layouts ─────────────────────────────────────────────────────────────

  Widget _buildWideLayout() {
    return Scaffold(
      body: Row(
        children: [
          OrganizationSideRail(
            organization: widget.organization,
            currentIndex: _tabIndexForPath(GoRouterState.of(context).uri.path),
            onTabChanged: _onTabChanged,
            onSettingsTap: () => _onTabChanged(3),
            onExitTap: _exitOrganization,
          ),
          Expanded(child: widget.navigationShell),
        ],
      ),
    );
  }

  Widget _buildNarrowLayout(String path) {
    final showTabBar = _showTabBar(path);
    final tabIndex = _tabIndexForPath(path);
    final textForPath = _titleForPath(path);

    return Scaffold(
      extendBodyBehindAppBar: showTabBar,
      appBar: showTabBar
          ? AppHeader()
          : textForPath.isNotEmpty
          ? AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => _handleBack(path),
              ),
              title: Text(textForPath),
            )
          : null,
      body: showTabBar
          ? Padding(
              padding: EdgeInsets.only(
                top:
                    MediaQuery.of(context).padding.top +
                    DSAppHeader.kPreferredHeight,
              ),
              child: widget.navigationShell,
            )
          : widget.navigationShell,
      bottomNavigationBar: showTabBar
          ? _OrgNavigationBar(
              currentIndex: tabIndex,
              onTabChanged: _onTabChanged,
            )
          : null,
    );
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    ref.listen(
      currentUserMembershipOrganizationProvider(_orgId()),
      (_, next) => next.whenOrNull(error: (_, _) => _exitOrganization()),
    );

    final path = GoRouterState.of(context).uri.path;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _handleBack(path);
      },
      child: AppBreakpoints.isWide(context)
          ? _buildWideLayout()
          : _buildNarrowLayout(path),
    );
  }
}

class _OrgNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabChanged;

  const _OrgNavigationBar({
    required this.currentIndex,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: onTabChanged,
      backgroundColor: Colors.white,
      indicatorColor: Colors.transparent,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return TextStyle(
          fontFamily: 'Inter',
          fontSize: 12,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          color: selected ? AppTheme.primaryColor : const Color(0xFF94A3B8),
        );
      }),
      destinations: kOrgTabs
          .map(
            (tab) => NavigationDestination(
              icon: Icon(tab.icon, color: const Color(0xFF94A3B8)),
              selectedIcon: Icon(tab.icon, color: AppTheme.primaryColor),
              label: tab.label,
            ),
          )
          .toList(),
    );
  }
}
