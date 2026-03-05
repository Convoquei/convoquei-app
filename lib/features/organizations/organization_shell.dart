import 'package:convoquei_app/core/constants/app_breakpoints.dart';
import 'package:convoquei_app/core/theme/app_theme.dart';
import 'package:convoquei_app/features/organizations/shared/models/organization_my_member_profile_model.dart';
import 'package:convoquei_app/features/organizations/shared/models/organization_model.dart';
import 'package:convoquei_app/features/organizations/events/pages/org_events_page.dart';
import 'package:convoquei_app/features/organizations/home/pages/org_home_page.dart';
import 'package:convoquei_app/features/organizations/members/pages/org_members_page.dart';
import 'package:convoquei_app/features/organizations/members/pages/org_members_page.dart' show OrgMembersTab;
import 'package:convoquei_app/features/organizations/organization_tab.dart';
import 'package:convoquei_app/features/organizations/scales/pages/org_scales_page.dart';
import 'package:convoquei_app/features/organizations/settings/pages/org_settings_page.dart';
import 'package:convoquei_app/features/organizations/shared/providers/organization_providers.dart';
import 'package:convoquei_app/features/organizations/shared/providers/selected_organization_provider.dart';
import 'package:convoquei_app/features/organizations/shared/widgets/organization_shell_app_bar.dart';
import 'package:convoquei_app/features/organizations/shared/widgets/organization_side_rail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OrganizationShell extends ConsumerStatefulWidget {
  final OrganizationModel organization;

  const OrganizationShell({super.key, required this.organization});

  @override
  ConsumerState<OrganizationShell> createState() => _OrganizationShellState();
}

class _OrganizationShellState extends ConsumerState<OrganizationShell> {
  int _currentIndex = 0;
  OrgMembersTab? _membersInitialTab;

  final List<GlobalKey<NavigatorState>> _navigatorKeys = List.generate(
    kOrgTabs.length,
    (_) => GlobalKey<NavigatorState>(),
  );

  Widget _pageForIndex(int index) => switch (index) {
    0 => const OrgHomePage(),
    1 => const OrgEventsPage(),
    2 => const OrgScalesPage(),
    3 => OrgMembersPage(initialTab: _membersInitialTab ?? OrgMembersTab.membros),
    _ => const SizedBox.shrink(),
  };

  bool _handlePopInvoked() {
    final nav = _navigatorKeys[_currentIndex].currentState;
    if (nav != null && nav.canPop()) {
      nav.pop();
      return true;
    }
    if (_currentIndex != 0) {
      setState(() => _currentIndex = 0);
      return true;
    }
    return false;
  }

  void _navigateToMembersTab(OrgMembersTab tab) {
    Navigator.of(context).pop(); // fecha settings
    setState(() {
      _membersInitialTab = tab;
      _currentIndex = 3;
    });
  }

  void _openSettings() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => OrgSettingsPage(
          organization: widget.organization,
          onNavigateToMembersTab: _navigateToMembersTab,
        ),
      ),
    );
  }

  void _exitOrganization() {
    ref.invalidate(currentUserMembershipOrganizationProvider(widget.organization.id));
    ref.read(selectedOrganizationProvider.notifier).clear();
    Navigator.of(context).pop();
  }

  Widget _buildIndexedContent() {
    return Navigator(
      key: _navigatorKeys[_currentIndex],
      onGenerateRoute: (_) =>
          MaterialPageRoute(builder: (_) => _pageForIndex(_currentIndex)),
    );
    
    // return IndexedStack(
    //   index: _currentIndex,
    //   children: List.generate(kOrgTabs.length, (index) {
    //     return Navigator(
    //       key: _navigatorKeys[index],
    //       onGenerateRoute: (_) =>
    //           MaterialPageRoute(builder: (_) => _pageForIndex(index)),
    //     );
    //   }),
    // );
  }

  Widget _buildWideLayout({required OrganizationMyMemberProfile? member}) {
    return Scaffold(
      body: Row(
        children: [
          OrganizationSideRail(
            organization: widget.organization,
            currentIndex: _currentIndex,
            onTabChanged: (i) => setState(() {
              _membersInitialTab = null;
              _currentIndex = i;
            }),
            onSettingsTap: _openSettings,
            onExitTap: _exitOrganization,
          ),
          Expanded(child: _buildIndexedContent()),
        ],
      ),
    );
  }

  Widget _buildNarrowLayout({required OrganizationMyMemberProfile? member}) {
    return Scaffold(
      appBar: OrganizationShellAppBar(
        organization: widget.organization,
        currentPage: kOrgTabs[_currentIndex].label,
        onBackTap: _exitOrganization,
        onSettingsTap: _openSettings,
      ),
      body: _buildIndexedContent(),
      bottomNavigationBar: _OrgNavigationBar(
        currentIndex: _currentIndex,
        onTabChanged: (i) => setState(() {
          _membersInitialTab = null;
          _currentIndex = i;
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Watch the current member. Errors (e.g. 403 – kicked) trigger an exit.
    ref.listen(
      currentUserMembershipOrganizationProvider(widget.organization.id),
      (_, next) => next.whenOrNull(
        error: (_, __) => _exitOrganization(),
      ),
    );

    final memberAsync =
        ref.watch(currentUserMembershipOrganizationProvider(widget.organization.id));

    // Resolve the member (null while loading or on error).
    final OrganizationMyMemberProfile? member = memberAsync.asData?.value;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (!_handlePopInvoked()) _exitOrganization();
      },
      child: AppBreakpoints.isWide(context)
          ? _buildWideLayout(member: member)
          : _buildNarrowLayout(member: member),
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
