import 'package:convoquei_app/features/organizations/settings/providers/list_roles_organization_provider.dart';
import 'package:convoquei_app/features/organizations/shared/models/organization_role_model.dart';
import 'package:convoquei_app/features/organizations/shared/repositories/organization_role_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final updateRolePermissionsProvider =
    AsyncNotifierProvider<UpdateRolePermissionsNotifier, void>(
      UpdateRolePermissionsNotifier.new,
    );

class UpdateRolePermissionsNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> execute({
    required String organizationId,
    required String roleId,
    required List<String> permissions,
  }) async {
    state = const AsyncData(null);
    state = const AsyncLoading();

    late final OrganizationRoleModel updated;

    state = await AsyncValue.guard(() async {
      updated = await ref
          .read(organizationRoleRepositoryProvider)
          .updateRolePermissions(
            organizationId: organizationId,
            roleId: roleId,
            permissions: permissions,
          );
    });

    if (state.hasError) throw state.error!;

    ref
        .read(listRolesOrganizationProvider.notifier)
        .updateRolePermissions(
          roleId: roleId,
          permissions: updated.permissions,
        );
  }
}
