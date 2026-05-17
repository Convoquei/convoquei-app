import 'package:convoquei_app/app/router.dart';
import 'package:convoquei_app/design_system/ds.dart';
import 'package:convoquei_app/features/auth/providers/auth_providers.dart';
import 'package:convoquei_app/features/organizations/shared/models/organization_model.dart';
import 'package:convoquei_app/features/organizations/shared/providers/selected_organization_provider.dart';
import 'package:convoquei_app/features/organizations/shared/widgets/org_switcher_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Header padrão das telas raiz (Home, abas da org). Mostra a org atual
/// via [selectedOrganizationProvider] e permite trocar de contexto.
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
      onProfileTap: () => context.pushNamed(AppRoutes.profile),
      onContextTap: () {
        final location = GoRouterState.of(context).uri.toString();
        DSBaseModal.show(context, OrgSwitcherSheet(currentLocation: location));
      },
      onNotificationsTap: () {
        // TODO: navegar para /notifications quando a tela existir.
      },
    );
  }

  OrganizationModel? _resolveCurrentOrg(BuildContext context, WidgetRef ref) {
    final loc = GoRouterState.of(context).matchedLocation;
    if (!loc.startsWith('/org')) return null;
    return ref.watch(selectedOrganizationProvider);
  }
}
