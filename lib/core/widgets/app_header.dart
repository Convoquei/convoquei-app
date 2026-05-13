import 'package:convoquei_app/app/router.dart';
import 'package:convoquei_app/design_system/ds.dart';
import 'package:convoquei_app/features/auth/providers/auth_providers.dart';
import 'package:convoquei_app/features/organizations/shared/models/organization_model.dart';
import 'package:convoquei_app/features/organizations/shared/providers/organization_providers.dart';
import 'package:convoquei_app/features/organizations/shared/providers/selected_organization_provider.dart';
import 'package:convoquei_app/features/organizations/shared/widgets/org_switcher_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Header padrão usado em telas raiz do app (Home, OrgHome, Eventos, etc.).
///
/// Deriva o contexto atual (organização) da rota — `:orgId` no path — com
/// fallback para [selectedOrganizationProvider]. Telas internas que "fogem da
/// pilha" (ex.: Configurações da organização) não devem usar este header.
class AppHeader extends ConsumerWidget implements PreferredSizeWidget {
  const AppHeader({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(DSAppHeader.kPreferredHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final currentOrg = _resolveCurrentOrg(context, ref);

    final userName = user?.name ?? '';
    final userAvatarUrl = user?.avatarUrl;
    final currentContextLabel = currentOrg?.name ?? 'Visão Global';

    return DSAppHeader(
      userName: userName,
      userAvatarUrl: userAvatarUrl,
      currentContextLabel: currentContextLabel,
      onProfileTap: () {
        // TODO: navegar para /profile quando a tela de perfil existir.
      },
      onContextTap: () {
        final location = GoRouterState.of(context).uri.toString();
        DSBaseModal.show(context, OrgSwitcherSheet(currentLocation: location));
      },
      onSettingsTap: currentOrg != null
          ? () => context.pushNamed(
                AppRoutes.orgSettings,
                pathParameters: {'orgId': currentOrg.id},
              )
          : null,
      onNotificationsTap: () {
        // TODO: navegar para /notifications quando a tela existir.
      },
    );
  }

  /// Determines the current organization from the route (`:orgId`), falling
  /// back to [selectedOrganizationProvider] when the route param is absent
  /// (or to enrich it with a freshly fetched model). Returns null on /home or
  /// any route outside the org shell.
  OrganizationModel? _resolveCurrentOrg(BuildContext context, WidgetRef ref) {
    final routeOrgId =
        GoRouterState.of(context).pathParameters['orgId'];
    final selected = ref.watch(selectedOrganizationProvider);

    if (routeOrgId == null) return null;

    if (selected != null && selected.id == routeOrgId) return selected;

    final orgs = ref.watch(userOrganizationsProvider).asData?.value;
    final found =
        orgs?.where((o) => o.id == routeOrgId).cast<OrganizationModel?>().firstOrNull;
    return found ?? selected;
  }
}
