import 'package:convoquei_app/features/auth/models/auth_state.dart';
import 'package:convoquei_app/features/auth/pages/login_page.dart';
import 'package:convoquei_app/features/auth/providers/auth_providers.dart';
import 'package:convoquei_app/features/home/pages/home_page.dart';
import 'package:convoquei_app/features/organizations/events/pages/org_event_configuration_wizard_page.dart';
import 'package:convoquei_app/features/organizations/events/pages/org_event_detail_page.dart';
import 'package:convoquei_app/features/organizations/events/pages/org_events_page.dart';
import 'package:convoquei_app/features/organizations/home/pages/org_home_page.dart';
import 'package:convoquei_app/features/organizations/members/pages/org_members_page.dart';
import 'package:convoquei_app/features/organizations/organization_shell.dart';
import 'package:convoquei_app/features/organizations/scales/pages/org_scales_page.dart';
import 'package:convoquei_app/features/organizations/functions/pages/manage_functions_page.dart';
import 'package:convoquei_app/features/organizations/groups/pages/manage_groups_page.dart';
import 'package:convoquei_app/features/organizations/roles/pages/manage_roles_page.dart';
import 'package:convoquei_app/features/organizations/settings/pages/org_settings_page.dart';
import 'package:convoquei_app/features/organizations/shared/providers/selected_organization_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// ── Route names ─────────────────────────────────────────────────────────────

abstract final class AppRoutes {
  static const login = 'login';
  static const home = 'home';
  static const orgHome = 'org-home';
  static const orgEvents = 'org-events';
  static const orgScales = 'org-scales';
  static const orgMinistry = 'org-ministry';
  static const orgTeam = 'org-team';
  static const orgEventNew = 'org-event-new';
  static const orgEventDetail = 'org-event-detail';
  static const orgEventEdit = 'org-event-edit';
  static const orgMinistryRoles = 'org-ministry-roles';
  static const orgMinistryFunctions = 'org-ministry-functions';
  static const orgMinistryGroups = 'org-ministry-groups';
}

// ── Route paths ──────────────────────────────────────────────────────────────
// App é mobile-only: paths são tokens de navegação, não URLs públicas.
// orgId não aparece no path — vive em selectedOrganizationProvider.

abstract final class AppPaths {
  static const login = '/login';
  static const home = '/home';
  static const orgHome = '/org/home';
  static const orgEvents = '/org/events';
  static const orgScales = '/org/scales';
  static const orgMinistry = '/org/ministry';
  static const orgTeam = '/org/team';
  static const orgEventNew = '/org/event/new';
  static String orgEventDetail(String eventId) => '/org/event/$eventId';
  static String orgEventEdit(String eventId) => '/org/event/$eventId/edit';
  static const orgMinistryRoles = '/org/ministry/roles';
  static const orgMinistryFunctions = '/org/ministry/functions';
  static const orgMinistryGroups = '/org/ministry/groups';
}

// ── Router provider ─────────────────────────────────────────────────────────

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppPaths.home,
    refreshListenable: _AuthStateListenable(ref),
    redirect: (context, state) {
      final authState = ref.read(authProvider);

      if (authState.status == AuthStatus.unknown) return null;

      FlutterNativeSplash.remove();

      final isAuthenticated = authState.status == AuthStatus.authenticated;
      final loc = state.matchedLocation;
      final isOnLogin = loc == AppPaths.login;

      if (!isAuthenticated && !isOnLogin) return AppPaths.login;
      if (isAuthenticated && isOnLogin) return AppPaths.home;

      // Sem org selecionada tentando acessar área da org → volta para /home
      if (isAuthenticated &&
          loc.startsWith('/org') &&
          ref.read(selectedOrganizationProvider) == null) {
        return AppPaths.home;
      }

      return null;
    },
    routes: [
      // ── Auth ──────────────────────────────────────────────────────────────
      GoRoute(
        path: AppPaths.login,
        name: AppRoutes.login,
        builder: (_, _) => const LoginPage(),
      ),

      // ── Home (seleção de org) ──────────────────────────────────────────────
      GoRoute(
        path: AppPaths.home,
        name: AppRoutes.home,
        builder: (_, _) => const HomePage(),
      ),

      // ── Organization shell (só as 4 abas — sem sub-rotas) ─────────────────
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => OrganizationShell(
          navigationShell: navigationShell,
        ),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppPaths.orgHome,
                name: AppRoutes.orgHome,
                builder: (_, _) => const OrgHomePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppPaths.orgEvents,
                name: AppRoutes.orgEvents,
                builder: (_, _) => const OrgEventsPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppPaths.orgScales,
                name: AppRoutes.orgScales,
                builder: (_, _) => const OrgScalesPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppPaths.orgMinistry,
                name: AppRoutes.orgMinistry,
                builder: (_, _) => const OrgSettingsPage(),
              ),
            ],
          ),
        ],
      ),

      // ── Rotas-irmãs do shell — empilhadas acima, tab bar some nativamente ──

      GoRoute(
        path: AppPaths.orgTeam,
        name: AppRoutes.orgTeam,
        builder: (_, _) => const OrgMembersPage(),
      ),

      GoRoute(
        path: AppPaths.orgEventNew,
        name: AppRoutes.orgEventNew,
        builder: (_, _) {
          final orgId = ref.read(selectedOrganizationProvider)!.id;
          return OrgEventConfigurationWizardPage(organizationId: orgId);
        },
      ),

      GoRoute(
        path: '/org/event/:eventId',
        name: AppRoutes.orgEventDetail,
        builder: (_, state) {
          final orgId = ref.read(selectedOrganizationProvider)!.id;
          return OrgEventDetailPage(
            organizationId: orgId,
            eventId: state.pathParameters['eventId']!,
          );
        },
        routes: [
          GoRoute(
            path: 'edit',
            name: AppRoutes.orgEventEdit,
            builder: (_, state) {
              final orgId = ref.read(selectedOrganizationProvider)!.id;
              return OrgEventConfigurationWizardPage(
                organizationId: orgId,
                eventId: state.pathParameters['eventId']!,
              );
            },
          ),
        ],
      ),

      GoRoute(
        path: AppPaths.orgMinistryRoles,
        name: AppRoutes.orgMinistryRoles,
        builder: (_, _) {
          final org = ref.read(selectedOrganizationProvider)!;
          return ManageRolesPage(organization: org);
        },
      ),

      GoRoute(
        path: AppPaths.orgMinistryFunctions,
        name: AppRoutes.orgMinistryFunctions,
        builder: (_, _) {
          final org = ref.read(selectedOrganizationProvider)!;
          return ManageFunctionsPage(organization: org);
        },
      ),

      GoRoute(
        path: AppPaths.orgMinistryGroups,
        name: AppRoutes.orgMinistryGroups,
        builder: (_, _) {
          final org = ref.read(selectedOrganizationProvider)!;
          return ManageGroupsPage(organization: org);
        },
      ),
    ],
  );
});

// ── Auth listenable ──────────────────────────────────────────────────────────

class _AuthStateListenable extends ChangeNotifier {
  _AuthStateListenable(Ref ref) {
    ref.listen<AuthState>(authProvider, (_, _) => notifyListeners());
  }
}
