import 'package:convoquei_app/core/constants/app_breakpoints.dart';
import 'package:convoquei_app/core/theme/app_theme.dart';
import 'package:convoquei_app/features/organizations/models/organization_model.dart';
import 'package:convoquei_app/features/organizations/pages/events/org_events_page.dart';
import 'package:convoquei_app/features/organizations/pages/home/org_home_page.dart';
import 'package:convoquei_app/features/organizations/pages/scales/org_scales_page.dart';
import 'package:convoquei_app/features/organizations/pages/team/org_team_page.dart';
import 'package:convoquei_app/features/organizations/providers/selected_organization_provider.dart';
import 'package:convoquei_app/features/organizations/widgets/organization_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Width of the rail when expanded (label visible)
const double _kRailExpanded = 220;
// Width of the rail when collapsed (icons only)
const double _kRailCollapsed = 64;

class OrganizationShell extends ConsumerStatefulWidget {
  final OrganizationModel organization;

  const OrganizationShell({super.key, required this.organization});

  @override
  ConsumerState<OrganizationShell> createState() => _OrganizationShellState();
}

class _OrganizationShellState extends ConsumerState<OrganizationShell>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;

  late final AnimationController _railController;
  late final Animation<double> _railAnim;

  // One navigator key per tab so each tab keeps its own navigation stack.
  final List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  @override
  void initState() {
    super.initState();
    _railController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _railAnim = CurvedAnimation(
      parent: _railController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _railController.dispose();
    super.dispose();
  }

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

  bool _handlePopInvoked() {
    final currentNav = _navigatorKeys[_currentIndex].currentState;
    if (currentNav != null && currentNav.canPop()) {
      currentNav.pop();
      return true;
    }
    if (_currentIndex != 0) {
      setState(() => _currentIndex = 0);
      return true;
    }
    return false;
  }

  // ── Narrow layout helpers ──────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return PreferredSize(
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
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: const Icon(Icons.settings_rounded, color: Colors.white),
                    tooltip: 'Configurações',
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Wide layout: persistent side rail ─────────────────────────────────────

  Widget _buildSideRail(BuildContext context) {
    const Color bg = Colors.white;
    const Color dividerColor = Color(0xFFE2E8F0);
    final Color iconMuted = const Color(0xFF94A3B8);
    final Color labelMuted = const Color(0xFF64748B);

    return MouseRegion(
      onEnter: (_) => _railController.forward(),
      onExit: (_) => _railController.reverse(),
      child: AnimatedBuilder(
        animation: _railAnim,
        builder: (context, _) {
          final double width = _kRailCollapsed +
              (_kRailExpanded - _kRailCollapsed) * _railAnim.value;

          // Labels are visible (with fade) as soon as animation starts opening.
          // They fade in proportionally to the animation progress.
          final double labelOpacity = _railAnim.value;

          return Container(
            width: width,
            decoration: BoxDecoration(
              color: bg,
              border: Border(
                right: BorderSide(color: dividerColor, width: 1),
              ),
            ),
            child: ClipRect(
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Header ────────────────────────────────────────────
                    SizedBox(
                      height: 64,
                      child: Stack(
                        children: [
                          // Avatar always centered in the collapsed zone
                          Positioned(
                            left: 0,
                            top: 0,
                            bottom: 0,
                            width: _kRailCollapsed,
                            child: Center(
                              child: OrganizationAvatar(
                                photoUrl: widget.organization.photoUrl,
                                size: 36,
                              ),
                            ),
                          ),
                          // Org name fades in to the right of the avatar
                          Positioned(
                            left: _kRailCollapsed,
                            top: 0,
                            bottom: 0,
                            right: 8,
                            child: Opacity(
                              opacity: labelOpacity,
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  widget.organization.name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                    color: AppTheme.primaryColor,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Divider(color: dividerColor, height: 1, thickness: 1),
                    const SizedBox(height: 6),

                    // ── Nav items ──────────────────────────────────────────
                    ..._tabs.asMap().entries.map((entry) {
                      final int index = entry.key;
                      final _TabItem tab = entry.value;
                      final bool selected = _currentIndex == index;

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        child: Material(
                            color: selected
                                ? AppTheme.primaryColor.withValues(alpha: 0.08)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(8),
                              onTap: () =>
                                  setState(() => _currentIndex = index),
                              child: SizedBox(
                                height: 40,
                                child: Stack(
                                  children: [
                                    // Icon always centered in the collapsed zone
                                    Positioned(
                                      left: 0,
                                      top: 0,
                                      bottom: 0,
                                      width: _kRailCollapsed - 12,
                                      child: Center(
                                        child: Icon(
                                          tab.icon,
                                          size: 20,
                                          color: selected
                                              ? AppTheme.primaryColor
                                              : iconMuted,
                                        ),
                                      ),
                                    ),
                                    // Label fades in to the right
                                    Positioned(
                                      left: _kRailCollapsed - 12,
                                      top: 0,
                                      bottom: 0,
                                      right: 0,
                                      child: Opacity(
                                        opacity: labelOpacity,
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            tab.label,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontFamily: 'Inter',
                                              fontWeight: selected
                                                  ? FontWeight.w600
                                                  : FontWeight.w400,
                                              fontSize: 13,
                                              color: selected
                                                  ? AppTheme.primaryColor
                                                  : labelMuted,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }),

                    const Spacer(),

                    Divider(color: dividerColor, height: 1, thickness: 1),

                    // ── Settings ───────────────────────────────────────────
                    _buildFooterItem(
                      icon: Icons.settings_outlined,
                      label: 'Configurações',
                      labelOpacity: labelOpacity,
                      iconMuted: iconMuted,
                      labelMuted: labelMuted,
                      verticalPadding: 4,
                      onTap: () {
                        // TODO: open organization settings
                      },
                    ),

                    // ── Exit org ───────────────────────────────────────────
                    _buildFooterItem(
                      icon: Icons.logout_rounded,
                      label: 'Sair da organização',
                      labelOpacity: labelOpacity,
                      iconMuted: iconMuted,
                      labelMuted: labelMuted,
                      verticalPadding: 12,
                      onTap: () {
                        ref
                            .read(selectedOrganizationProvider.notifier)
                            .clear();
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFooterItem({
    required IconData icon,
    required String label,
    required double labelOpacity,
    required Color iconMuted,
    required Color labelMuted,
    required double verticalPadding,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: EdgeInsets.only(left: 6, right: 6, bottom: verticalPadding),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: SizedBox(
            height: 40,
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  width: _kRailCollapsed - 12,
                  child: Center(
                    child: Icon(icon, size: 20, color: iconMuted),
                  ),
                ),
                Positioned(
                  left: _kRailCollapsed - 12,
                  top: 0,
                  bottom: 0,
                  right: 0,
                  child: Opacity(
                    opacity: labelOpacity,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          color: labelMuted,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final wide = AppBreakpoints.isWide(context);

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
      child: wide ? _buildWideLayout(context) : _buildNarrowLayout(context),
    );
  }

  // Wide: no AppBar, side rail always visible
  Widget _buildWideLayout(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          _buildSideRail(context),
          // Content area
          Expanded(
            child: IndexedStack(
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
          ),
        ],
      ),
    );
  }

  // Narrow: top AppBar + bottom NavigationBar
  Widget _buildNarrowLayout(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
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
            color: selected
                ? AppTheme.primaryColor
                : const Color(0xFF94A3B8),
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
    );
  }
}

class _TabItem {
  final String label;
  final IconData icon;
  const _TabItem({required this.label, required this.icon});
}


