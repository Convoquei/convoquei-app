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
import 'package:convoquei_app/features/organizations/shared/models/organization_model.dart';
import 'package:convoquei_app/features/organizations/shared/providers/organization_providers.dart';
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
  static const orgCreateEvent = 'org-create-event';
  static const orgScales = 'org-scales';
  static const orgTeam = 'org-team';
  static const orgSettings = 'org-settings';
  static const orgSettingsRoles = 'org-settings-roles';
  static const orgSettingsFunctions = 'org-settings-functions';
  static const orgSettingsGroups = 'org-settings-groups';
  static const orgEventDetail = 'org-event-detail';
  static const orgEditEvent = 'org-edit-event';
}

// ── Route paths ─────────────────────────────────────────────────────────────

abstract final class AppPaths {
  static const login = '/login';
  static const home = '/home';
  static String org(String orgId) => '/orgs/$orgId';
  static String orgHome(String orgId) => '/orgs/$orgId/home';
  static String orgEvents(String orgId) => '/orgs/$orgId/events';
  static String orgCreateEvent(String orgId) => '/orgs/$orgId/events/new';
  static String orgScales(String orgId) => '/orgs/$orgId/scales';
  static String orgTeam(String orgId) => '/orgs/$orgId/team';
  static String orgSettings(String orgId) => '/orgs/$orgId/settings';
  static String orgSettingsRoles(String orgId) =>
      '/orgs/$orgId/settings/roles';
  static String orgSettingsFunctions(String orgId) =>
      '/orgs/$orgId/settings/functions';
  static String orgSettingsGroups(String orgId) =>
      '/orgs/$orgId/settings/groups';
  static String orgEventDetail(String orgId, String eventId) =>
      '/orgs/$orgId/events/$eventId';
  static String orgEditEvent(String orgId, String eventId) =>
      '/orgs/$orgId/events/$eventId/edit';
}

// ── Branch navigator keys ────────────────────────────────────────────────────

final _homeTabKey = GlobalKey<NavigatorState>();
final _eventsTabKey = GlobalKey<NavigatorState>();
final _scalesTabKey = GlobalKey<NavigatorState>();
final _ministryTabKey = GlobalKey<NavigatorState>();

// ── Static branch entry points ───────────────────────────────────────────────
//
// StatefulShellBranch.initialLocation must (a) have no path parameters and
// (b) match a descendant route of the branch. Since all real org routes use
// `:orgId`, we add non-parameterized sentinel routes that redirect to the
// correct org path at runtime using selectedOrganizationProvider.

const _kOrgHomeEntry = '/org/home';
const _kOrgEventsEntry = '/org/events';
const _kOrgScalesEntry = '/org/scales';
const _kOrgSettingsEntry = '/org/settings';

// ── Router provider ─────────────────────────────────────────────────────────

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppPaths.home,
    refreshListenable: _AuthStateListenable(ref),
    redirect: (context, state) {
      final authState = ref.read(authProvider);

      // Still initialising – stay put and let the splash screen handle it.
      if (authState.status == AuthStatus.unknown) return null;

      FlutterNativeSplash.remove();

      final isAuthenticated = authState.status == AuthStatus.authenticated;
      final isOnLogin = state.matchedLocation == AppPaths.login;

      if (!isAuthenticated && !isOnLogin) return AppPaths.login;
      if (isAuthenticated && isOnLogin) return AppPaths.home;
      return null;
    },
    routes: [
      // ── Auth ────────────────────────────────────────────────────────────
      GoRoute(
        path: AppPaths.login,
        name: AppRoutes.login,
        builder: (_, _) => const LoginPage(),
      ),

      // ── Home ────────────────────────────────────────────────────────────
      GoRoute(
        path: AppPaths.home,
        name: AppRoutes.home,
        builder: (_, _) => const HomePage(),
      ),

      // ── Organization shell (4 stateful branches — stacks preserved on tab switch) ──
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          final org = _orgFromState(ref, state);
          if (org == null) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          return OrganizationShell(
            navigationShell: navigationShell,
            organization: org,
            branchNavigatorKeys: [
              _homeTabKey,
              _eventsTabKey,
              _scalesTabKey,
              _ministryTabKey,
            ],
          );
        },
        branches: [
          // ── Branch 0: Início ────────────────────────────────────────────
          StatefulShellBranch(
            navigatorKey: _homeTabKey,
            initialLocation: _kOrgHomeEntry,
            routes: [
              // Sentinel: static path with no params — redirects to the actual org home.
              GoRoute(
                path: _kOrgHomeEntry,
                redirect: (_, __) {
                  final orgId = ref.read(selectedOrganizationProvider)?.id;
                  return orgId != null ? AppPaths.orgHome(orgId) : AppPaths.home;
                },
              ),
              GoRoute(
                path: '/orgs/:orgId/home',
                name: AppRoutes.orgHome,
                pageBuilder: (_, state) => _noTransitionPage(
                  ValueKey('${AppRoutes.orgHome}-${state.pathParameters['orgId']}'),
                  const OrgHomePage(),
                ),
              ),
            ],
          ),

          // ── Branch 1: Eventos ───────────────────────────────────────────
          StatefulShellBranch(
            navigatorKey: _eventsTabKey,
            initialLocation: _kOrgEventsEntry,
            routes: [
              GoRoute(
                path: _kOrgEventsEntry,
                redirect: (_, __) {
                  final orgId = ref.read(selectedOrganizationProvider)?.id;
                  return orgId != null ? AppPaths.orgEvents(orgId) : AppPaths.home;
                },
              ),
              GoRoute(
                path: '/orgs/:orgId/events',
                name: AppRoutes.orgEvents,
                pageBuilder: (_, state) => _noTransitionPage(
                  ValueKey('${AppRoutes.orgEvents}-${state.pathParameters['orgId']}'),
                  OrgEventsPage(organizationId: state.pathParameters['orgId']!),
                ),
                routes: [
                  GoRoute(
                    path: 'new',
                    name: AppRoutes.orgCreateEvent,
                    pageBuilder: (_, state) => _noTransitionPage(
                      state.pageKey,
                      OrgEventConfigurationWizardPage(
                        organizationId: state.pathParameters['orgId']!,
                      ),
                    ),
                  ),
                  GoRoute(
                    path: ':eventId',
                    name: AppRoutes.orgEventDetail,
                    pageBuilder: (_, state) => _noTransitionPage(
                      state.pageKey,
                      OrgEventDetailPage(
                        organizationId: state.pathParameters['orgId']!,
                        eventId: state.pathParameters['eventId']!,
                      ),
                    ),
                    routes: [
                      GoRoute(
                        path: 'edit',
                        name: AppRoutes.orgEditEvent,
                        pageBuilder: (_, state) => _noTransitionPage(
                          state.pageKey,
                          OrgEventConfigurationWizardPage(
                            organizationId: state.pathParameters['orgId']!,
                            eventId: state.pathParameters['eventId']!,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),

          // ── Branch 2: Escalas ───────────────────────────────────────────
          StatefulShellBranch(
            navigatorKey: _scalesTabKey,
            initialLocation: _kOrgScalesEntry,
            routes: [
              GoRoute(
                path: _kOrgScalesEntry,
                redirect: (_, __) {
                  final orgId = ref.read(selectedOrganizationProvider)?.id;
                  return orgId != null ? AppPaths.orgScales(orgId) : AppPaths.home;
                },
              ),
              GoRoute(
                path: '/orgs/:orgId/scales',
                name: AppRoutes.orgScales,
                pageBuilder: (_, state) => _noTransitionPage(
                  ValueKey('${AppRoutes.orgScales}-${state.pathParameters['orgId']}'),
                  const OrgScalesPage(),
                ),
              ),
            ],
          ),

          // ── Branch 3: Ministério ────────────────────────────────────────
          StatefulShellBranch(
            navigatorKey: _ministryTabKey,
            initialLocation: _kOrgSettingsEntry,
            routes: [
              GoRoute(
                path: _kOrgSettingsEntry,
                redirect: (_, __) {
                  final orgId = ref.read(selectedOrganizationProvider)?.id;
                  return orgId != null ? AppPaths.orgSettings(orgId) : AppPaths.home;
                },
              ),
              GoRoute(
                path: '/orgs/:orgId/settings',
                name: AppRoutes.orgSettings,
                pageBuilder: (_, state) => _noTransitionPage(
                  ValueKey('${AppRoutes.orgSettings}-${state.pathParameters['orgId']}'),
                  OrgSettingsPage(organization: _orgFromState(ref, state)!),
                ),
                routes: [
                  GoRoute(
                    path: 'roles',
                    name: AppRoutes.orgSettingsRoles,
                    pageBuilder: (_, state) => _noTransitionPage(
                      state.pageKey,
                      ManageRolesPage(organization: _orgFromState(ref, state)!),
                    ),
                  ),
                  GoRoute(
                    path: 'functions',
                    name: AppRoutes.orgSettingsFunctions,
                    pageBuilder: (_, state) => _noTransitionPage(
                      state.pageKey,
                      ManageFunctionsPage(organization: _orgFromState(ref, state)!),
                    ),
                  ),
                  GoRoute(
                    path: 'groups',
                    name: AppRoutes.orgSettingsGroups,
                    pageBuilder: (_, state) => _noTransitionPage(
                      state.pageKey,
                      ManageGroupsPage(organization: _orgFromState(ref, state)!),
                    ),
                  ),
                ],
              ),
              // Página de membros — acessada de dentro da aba Ministério
              GoRoute(
                path: '/orgs/:orgId/team',
                name: AppRoutes.orgTeam,
                pageBuilder: (_, state) => _noTransitionPage(
                  state.pageKey,
                  const OrgMembersPage(),
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

// ── Helpers ──────────────────────────────────────────────────────────────────

NoTransitionPage<void> _noTransitionPage(ValueKey<String> key, Widget child) {
  return NoTransitionPage<void>(key: key, child: child);
}

/// Resolves the [OrganizationModel] for the current route.
///
/// First checks [selectedOrganizationProvider] (set when the user taps an org
/// card on the Home page). Falls back to reading from the user's organization
/// list via [userOrganizationsProvider] using the `:orgId` path parameter.
OrganizationModel? _orgFromState(Ref ref, GoRouterState state) {
  final selected = ref.read(selectedOrganizationProvider);
  if (selected != null) return selected;

  final orgId = state.pathParameters['orgId'];
  if (orgId == null) return null;

  final orgsAsync = ref.read(userOrganizationsProvider);
  return orgsAsync.asData?.value.where((o) => o.id == orgId).firstOrNull;
}

// ── Auth listenable ──────────────────────────────────────────────────────────

/// Bridges Riverpod auth state changes into a [Listenable] so GoRouter can
/// react to authentication changes and re-evaluate its redirect logic.
class _AuthStateListenable extends ChangeNotifier {
  _AuthStateListenable(Ref ref) {
    ref.listen<AuthState>(authProvider, (_, _) => notifyListeners());
  }
}
