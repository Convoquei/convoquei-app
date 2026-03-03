import 'package:convoquei_app/core/theme/app_theme.dart';
import 'package:convoquei_app/features/organizations/models/organization_model.dart';
import 'package:convoquei_app/features/organizations/pages/org_events_page.dart';
import 'package:convoquei_app/features/organizations/pages/org_home_page.dart';
import 'package:convoquei_app/features/organizations/pages/org_scales_page.dart';
import 'package:convoquei_app/features/organizations/pages/org_team_page.dart';
import 'package:convoquei_app/features/organizations/providers/selected_organization_provider.dart';
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

  // One navigator key per tab so each tab keeps its own navigation stack.
  final List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  static const _tabs = [
    _TabItem(label: 'Início', icon: Icons.home_rounded),
    _TabItem(label: 'Eventos', icon: Icons.event_rounded),
    _TabItem(label: 'Escalas', icon: Icons.assignment_rounded),
    _TabItem(label: 'Equipe', icon: Icons.group_rounded),
  ];

  Widget _buildPage(int index) {
    return switch (index) {
      0 => const OrgHomePage(),
      1 => const OrgEventsPage(),
      2 => const OrgScalesPage(),
      3 => const OrgTeamPage(),
      _ => const SizedBox.shrink(),
    };
  }

  /// Intercepts the Android back button: first pops within the current tab's
  /// stack; if there's nothing to pop, goes back to the home tab; if already
  /// on home tab, pops the whole shell (leaving the organization).
  bool _handlePopInvoked() {
    final currentNav = _navigatorKeys[_currentIndex].currentState;

    // If current tab's inner navigator can pop, do that first.
    if (currentNav != null && currentNav.canPop()) {
      currentNav.pop();
      return true; // consumed
    }

    // If not on home tab, navigate back to home tab.
    if (_currentIndex != 0) {
      setState(() => _currentIndex = 0);
      return true; // consumed
    }

    // On home tab with nothing to pop → let the shell be popped normally.
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        final consumed = _handlePopInvoked();
        if (!consumed) {
          ref.read(selectedOrganizationProvider.notifier).clear();
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25),
              ),
              border: Border(
                bottom: BorderSide(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                        tooltip: 'Voltar',
                        onPressed: () {
                          ref.read(selectedOrganizationProvider.notifier).clear();
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 56),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            widget.organization.name.toUpperCase(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                              height: 1.2,
                              color: Colors.white.withValues(alpha: 0.75),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _tabs[_currentIndex].label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              height: 1.2,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Right: settings button
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        icon: const Icon(Icons.settings_rounded, color: Colors.white),
                        tooltip: 'Configurações',
                        onPressed: () {
                          // TODO: open organization settings
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: IndexedStack(
          index: _currentIndex,
          children: List.generate(_tabs.length, (index) {
            return Navigator(
              key: _navigatorKeys[index],
              onGenerateRoute: (_) => MaterialPageRoute(
                builder: (_) => _buildPage(index),
              ),
            );
          }),
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) =>
              setState(() => _currentIndex = index),
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
          destinations: _tabs
              .map(
                (tab) => NavigationDestination(
                  icon: Icon(tab.icon, color: const Color(0xFF94A3B8)),
                  selectedIcon: Icon(tab.icon, color: AppTheme.primaryColor),
                  label: tab.label,
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class _TabItem {
  final String label;
  final IconData icon;
  const _TabItem({required this.label, required this.icon});
}


