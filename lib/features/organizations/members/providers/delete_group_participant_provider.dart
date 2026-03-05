import 'dart:async';

import 'package:convoquei_app/features/organizations/members/providers/group_participants_paged_provider.dart';
import 'package:convoquei_app/features/organizations/members/providers/list_all_groups_query_provider.dart';
import 'package:convoquei_app/features/organizations/members/repositories/organization_groups_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final deleteGroupParticipantProvider =
    AsyncNotifierProvider.autoDispose<DeleteGroupParticipantNotifier, void>(
      DeleteGroupParticipantNotifier.new,
    );

class DeleteGroupParticipantNotifier extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() async {}

  Future<void> remove({
    required String organizationId,
    required String groupId,
    required String participantId,
  }) async {
    final link = ref.keepAlive();

    try {
      state = const AsyncValue.loading();

      final repo = ref.read(organizationGroupsRepositoryProvider);

      state = await AsyncValue.guard(() async {
        await repo.deleteGroupParticipant(
          organizationId,
          groupId,
          participantId,
        );
      });

      if (!ref.mounted) return;

      ref
          .read(groupParticipantsPagedProvider(groupId).notifier)
          .removeParticipant(participantId);
      ref.read(groupsPagedProvider.notifier).decrementParticipantCount(groupId);
    } finally {
      link.close();
    }
  }
}
