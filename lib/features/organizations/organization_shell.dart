import 'package:convoquei_app/app/router.dart';
import 'package:convoquei_app/core/constants/app_breakpoints.dart';
import 'package:convoquei_app/core/theme/app_theme.dart';
import 'package:convoquei_app/core/widgets/app_header.dart';
import 'package:convoquei_app/design_system/ds.dart';
import 'package:convoquei_app/features/organizations/organization_tab.dart';
import 'package:convoquei_app/features/organizations/shared/providers/current_org_provider.dart';
import 'package:convoquei_app/features/organizations/shared/providers/organization_providers.dart';
import 'package:convoquei_app/features/organizations/shared/providers/selected_organization_provider.dart';
import 'package:convoquei_app/features/organizations/shared/widgets/organization_side_rail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class OrganizationShell extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const OrganizationShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final org = ref.watch(selectedOrganizationProvider);
    if (org == null) return const SizedBox.shrink();

    ref.listen(
      currentUserMembershipOrganizationProvider(org.id),
      (_, next) => next.whenOrNull(error: (_, _) => _exit(context, ref)),
    );

    final Widget content;

    if (AppBreakpoints.isWide(context)) {
      content = Scaffold(
        body: Row(
          children: [
            OrganizationSideRail(
              organization: org,
              currentIndex: navigationShell.currentIndex,
              onTabChanged: (i) => navigationShell.goBranch(
                i,
                initialLocation: i == navigationShell.currentIndex,
              ),
              onSettingsTap: () => navigationShell.goBranch(3),
              onExitTap: () => _exit(context, ref),
            ),
            Expanded(child: navigationShell),
          ],
        ),
      );
    } else {
      final mq = MediaQuery.of(context);
      content = Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppHeader(),
        body: Padding(
          padding: EdgeInsets.only(
            top: mq.padding.top + DSAppHeader.kPreferredHeight,
          ),
          child: navigationShell,
        ),
        bottomNavigationBar: _OrgNavigationBar(
          currentIndex: navigationShell.currentIndex,
          onTabChanged: (i) => navigationShell.goBranch(
            i,
            initialLocation: i == navigationShell.currentIndex,
          ),
        ),
      );
    }

    return ProviderScope(
      overrides: [currentOrgProvider.overrideWithValue(org)],
      child: KeyedSubtree(key: ValueKey(org.id), child: content),
    );
  }

  void _exit(BuildContext context, WidgetRef ref) {
    ref.read(selectedOrganizationProvider.notifier).clear();
    context.go(AppPaths.home);
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
