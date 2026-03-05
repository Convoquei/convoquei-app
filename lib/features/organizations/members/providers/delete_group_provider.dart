import 'dart:async';

import 'package:convoquei_app/features/organizations/members/providers/list_all_groups_query_provider.dart';
import 'package:convoquei_app/features/organizations/members/repositories/organization_groups_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final deleteGroupProvider =
    AsyncNotifierProvider.autoDispose<DeleteGroupNotifier, void>(
      DeleteGroupNotifier.new,
    );

class DeleteGroupNotifier extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() async {}

  Future<void> delete({
    required String organizationId,
    required String groupId,
  }) async {
    final link = ref.keepAlive();

    try {
      state = const AsyncValue.loading();

      final repo = ref.read(organizationGroupsRepositoryProvider);

      state = await AsyncValue.guard(() async {
        await repo.deleteGroup(organizationId, groupId);
      });

      if (!ref.mounted) return;

      ref.read(groupsPagedProvider.notifier).reset();
    } finally {
      link.close();
    }
  }
}
