import 'dart:async';

import 'package:convoquei_app/features/organizations/roles/providers/list_members_in_role_provider.dart';
import 'package:convoquei_app/features/organizations/shared/repositories/organization_role_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final removeRoleMemberProvider =
    AsyncNotifierProvider.autoDispose<RemoveRoleMemberNotifier, void>(
      RemoveRoleMemberNotifier.new,
    );

class RemoveRoleMemberNotifier extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() async {}

  Future<void> execute({
    required String organizationId,
    required String roleId,
    required String memberId,
  }) async {
    final link = ref.keepAlive();

    try {
      state = const AsyncLoading();

      state = await AsyncValue.guard(() async {
        await ref
            .read(organizationRoleRepositoryProvider)
            .removeRoleMember(
              organizationId: organizationId,
              roleId: roleId,
              memberId: memberId,
            );
      });

      if (state.hasError) throw state.error!;

      if (!ref.mounted) return;

      ref.invalidate(
        roleMembersProvider((
          organizationId: organizationId,
          roleId: roleId,
        )),
      );
    } finally {
      link.close();
    }
  }
}
