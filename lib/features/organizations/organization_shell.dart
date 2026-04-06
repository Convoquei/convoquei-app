import 'package:convoquei_app/app/router.dart';
import 'package:convoquei_app/core/constants/app_breakpoints.dart';
import 'package:convoquei_app/core/theme/app_theme.dart';
import 'package:convoquei_app/features/organizations/shared/models/organization_model.dart';
import 'package:convoquei_app/features/organizations/organization_tab.dart';
import 'package:convoquei_app/features/organizations/shared/providers/organization_providers.dart';
import 'package:convoquei_app/features/organizations/shared/providers/selected_organization_provider.dart';
import 'package:convoquei_app/features/organizations/shared/widgets/organization_shell_app_bar.dart';
import 'package:convoquei_app/features/organizations/shared/widgets/organization_side_rail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class OrganizationShell extends ConsumerStatefulWidget {
  final OrganizationModel organization;

  /// The active tab page provided by GoRouter's [ShellRoute].
  final Widget child;

  /// Key of the nested [Navigator] created by GoRouter's [ShellRoute].
  /// Used to call [NavigatorState.maybePop] so that [PopScope] widgets
  /// inside child pages (e.g. [WizardPage]) are properly respected.
  final GlobalKey<NavigatorState> shellNavigatorKey;

  const OrganizationShell({
    super.key,
    required this.shellNavigatorKey,
    required this.organization,
    required this.child,
  });

  @override
  ConsumerState<OrganizationShell> createState() => _OrganizationShellState();
}

class _OrganizationShellState extends ConsumerState<OrganizationShell> {
  static const _tabRouteNames = [
    AppRoutes.orgHome,
    AppRoutes.orgEvents,
    AppRoutes.orgScales,
    AppRoutes.orgTeam,
  ];

  String _orgId() => widget.organization.id;

  // ── Location helpers ────────────────────────────────────────────────────

  bool _isSettingsLocation(String path) =>
      path.startsWith(AppPaths.orgSettings(_orgId()));

  bool _isDetailsEventLocation(String path) =>
      path.startsWith('${AppPaths.orgEvents(_orgId())}/');

  bool _showTabBar(String path) {
      if (_isSettingsLocation(path) || _isDetailsEventLocation(path)) {
        return false;
      }

      return true;
  }

  int _tabIndexForPath(String path) {
    final id = _orgId();
    if (path.startsWith(AppPaths.orgEvents(id))) return 1;
    if (path.startsWith(AppPaths.orgScales(id))) return 2;
    if (path.startsWith(AppPaths.orgTeam(id))) return 3;
    return 0;
  }

  String _titleForPath(String path) {
    final id = _orgId();
    if (path.startsWith(AppPaths.orgSettingsRoles(id))) return 'Gerenciar Papéis';
    if (path.startsWith(AppPaths.orgSettingsFunctions(id))) return 'Gerenciar Funções';
    if (path.startsWith(AppPaths.orgSettings(id))) return 'Configurações';
    if (path.startsWith(AppPaths.orgCreateEvent(id))) return 'Novo Evento';
    if (path.endsWith('/edit')) return 'Editar Evento';
    if (_isDetailsEventLocation(path)) return 'Detalhes do Evento';
    if (path.startsWith(AppPaths.orgEvents(id))) return kOrgTabs[1].label;
    if (path.startsWith(AppPaths.orgScales(id))) return kOrgTabs[2].label;
    if (path.startsWith(AppPaths.orgTeam(id))) return kOrgTabs[3].label;
    return kOrgTabs[0].label;
  }

  // ── Navigation actions ──────────────────────────────────────────────────

  void _onTabChanged(int index) {
    final path = GoRouterState.of(context).uri.path;
    // When on a sub-page (tab bar hidden, e.g. Create Event), push the tab so
    // that pressing back returns to the sub-page instead of exiting the org.
    if (!_showTabBar(path)) {
      context.pushNamed(
        _tabRouteNames[index],
        pathParameters: {'orgId': _orgId()},
      );
    } else {
      context.goNamed(
        _tabRouteNames[index],
        pathParameters: {'orgId': _orgId()},
      );
    }
  }

  void _openSettings() {
    // Push so the current page (any tab or sub-page) stays in the stack and
    // the user returns to it when pressing back from Settings.
    context.pushNamed(
      AppRoutes.orgSettings,
      pathParameters: {'orgId': _orgId()},
    );
  }

  void _exitOrganization() {
    ref.invalidate(currentUserMembershipOrganizationProvider(_orgId()));
    ref.read(selectedOrganizationProvider.notifier).clear();
    context.goNamed(AppRoutes.home);
  }

  void _handleBack(String path) {
    // Delegate to the shell navigator first so that PopScope widgets inside
    // child pages (e.g. WizardPage) can intercept and handle the back action
    // (stepping through wizard steps) before we do any shell-level navigation.
    final shellNav = widget.shellNavigatorKey.currentState;
    if (shellNav != null && shellNav.canPop()) {
      shellNav.maybePop();
      return;
    }

    // Shell navigator has nothing to pop — handle at the shell level.
    if (_isSettingsLocation(path)) {
      // Settings root – go back to the home tab
      context.goNamed(AppRoutes.orgHome, pathParameters: {'orgId': _orgId()});
    } else {
      _exitOrganization();
    }
  }

  // ── Layouts ─────────────────────────────────────────────────────────────

  Widget _buildWideLayout() {
    return Scaffold(
      body: Row(
        children: [
          OrganizationSideRail(
            organization: widget.organization,
            currentIndex: _tabIndexForPath(
              GoRouterState.of(context).uri.path,
            ),
            onTabChanged: _onTabChanged,
            onSettingsTap: _openSettings,
            onExitTap: _exitOrganization,
          ),
          Expanded(child: widget.child),
        ],
      ),
    );
  }

  Widget _buildNarrowLayout(String path) {
    final showTabBar = _showTabBar(path);
    final tabIndex = _tabIndexForPath(path);

    return Scaffold(
      appBar: OrganizationShellAppBar(
        organization: widget.organization,
        currentPage: _titleForPath(path),
        onBackTap: () => _handleBack(path),
        onSettingsTap: showTabBar ? _openSettings : null,
      ),
      body: widget.child,
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
