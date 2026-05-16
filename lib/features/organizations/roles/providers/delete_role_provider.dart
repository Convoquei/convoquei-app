import 'dart:async';

import 'package:convoquei_app/features/organizations/roles/providers/list_roles_organization_provider.dart';
import 'package:convoquei_app/features/organizations/shared/repositories/organization_role_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final deleteRoleProvider =
    AsyncNotifierProvider.autoDispose<DeleteRoleNotifier, void>(
      DeleteRoleNotifier.new,
    );

class DeleteRoleNotifier extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() async {}

  Future<void> execute({
    required String organizationId,
    required String roleId,
  }) async {
    final link = ref.keepAlive();

    try {
      state = const AsyncLoading();

      state = await AsyncValue.guard(() async {
        await ref
            .read(organizationRoleRepositoryProvider)
            .deleteRole(organizationId: organizationId, roleId: roleId);
      });

      if (state.hasError) throw state.error!;

      if (!ref.mounted) return;

      ref
          .read(rolesProvider.notifier)
          .removeRole(roleId: roleId);
    } finally {
      link.close();
    }
  }
}
