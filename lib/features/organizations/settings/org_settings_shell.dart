import 'package:convoquei_app/app/router.dart';
import 'package:convoquei_app/features/organizations/shared/models/organization_model.dart';
import 'package:convoquei_app/features/organizations/shared/widgets/organization_shell_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Shell for organization settings screens.
///
/// Displays the [OrganizationShellAppBar] with the current route title and
/// renders the active page via [child] (provided by GoRouter's [ShellRoute]).
class OrgSettingsShell extends StatelessWidget {
  final OrganizationModel organization;

  /// The active page provided by GoRouter's [ShellRoute].
  final Widget child;

  const OrgSettingsShell({
    super.key,
    required this.organization,
    required this.child,
  });

  String _titleFromLocation(String location) {
    final id = organization.id;
    if (location == AppPaths.orgSettingsRoles(id)) return 'Gerenciar Papéis';
    if (location == AppPaths.orgSettingsFunctions(id)) {
      return 'Gerenciar Funções';
    }
    return 'Configurações';
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final title = _titleFromLocation(location);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (context.canPop()) {
          context.pop();
        } else {
          context.goNamed(
            AppRoutes.orgHome,
            pathParameters: {'orgId': organization.id},
          );
        }
      },
      child: Scaffold(
        appBar: OrganizationShellAppBar(
          organization: organization,
          currentPage: title,
          onBackTap: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.goNamed(
                AppRoutes.orgHome,
                pathParameters: {'orgId': organization.id},
              );
            }
          },
        ),
        body: child,
      ),
    );
  }
}

