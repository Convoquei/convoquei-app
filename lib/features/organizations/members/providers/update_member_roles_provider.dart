import 'dart:async';

import 'package:convoquei_app/features/organizations/shared/repositories/organization_role_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final updateMemberRolesProvider =
    AsyncNotifierProvider.autoDispose<UpdateMemberRolesNotifier, void>(
      UpdateMemberRolesNotifier.new,
    );

class UpdateMemberRolesNotifier extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() async {}

  Future<void> execute({
    required String organizationId,
    required String memberId,
    required Set<String> newRoleIds,
    Set<String> previousRoleIds = const {},
  }) async {
    final link = ref.keepAlive();

    try {
      state = const AsyncValue.loading();

      final toRemove = previousRoleIds.difference(newRoleIds);
      final toAdd = newRoleIds.difference(previousRoleIds);

      await _removeRoles(
        organizationId: organizationId,
        memberId: memberId,
        roleIds: toRemove,
      );

      await _addRoles(
        organizationId: organizationId,
        memberId: memberId,
        roleIds: toAdd,
      );

      state = const AsyncData(null);
    } finally {
      link.close();
    }
  }

  Future<void> _removeRoles({
    required String organizationId,
    required String memberId,
    required Set<String> roleIds,
  }) async {
    final repo = ref.read(organizationRoleRepositoryProvider);
    for (final roleId in roleIds) {
      await repo.removeRoleMember(
        organizationId: organizationId,
        roleId: roleId,
        memberId: memberId,
      );
    }
  }

  Future<void> _addRoles({
    required String organizationId,
    required String memberId,
    required Set<String> roleIds,
  }) async {
    final repo = ref.read(organizationRoleRepositoryProvider);
    for (final roleId in roleIds) {
      await repo.addRoleMember(
        organizationId: organizationId,
        roleId: roleId,
        memberId: memberId,
      );
    }
  }
}
