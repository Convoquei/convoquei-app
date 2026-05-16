import 'dart:async';

import 'package:convoquei_app/features/organizations/groups/providers/group_participants_paged_provider.dart';
import 'package:convoquei_app/features/organizations/groups/providers/list_all_groups_query_provider.dart';
import 'package:convoquei_app/features/organizations/groups/repositories/organization_groups_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final clearGroupParticipantsProvider =
    AsyncNotifierProvider.autoDispose<ClearGroupParticipantsNotifier, void>(
      ClearGroupParticipantsNotifier.new,
    );

class ClearGroupParticipantsNotifier extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() async {}

  Future<void> clear({
    required String organizationId,
    required String groupId,
  }) async {
    final link = ref.keepAlive();

    try {
      state = const AsyncValue.loading();

      final repo = ref.read(organizationGroupsRepositoryProvider);

      state = await AsyncValue.guard(() async {
        await repo.clearGroupParticipants(organizationId, groupId);
      });

      if (!ref.mounted) return;

      ref.read(groupParticipantsPagedProvider(groupId).notifier).clearAll();
      ref.read(groupsPagedProvider.notifier).clearParticipantCount(groupId);
    } finally {
      link.close();
    }
  }
}
