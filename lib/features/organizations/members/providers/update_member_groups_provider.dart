import 'dart:async';

import 'package:convoquei_app/features/organizations/members/providers/list_all_groups_query_provider.dart';
import 'package:convoquei_app/features/organizations/members/providers/list_all_members_query_provider.dart';
import 'package:convoquei_app/features/organizations/members/repositories/organization_members_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final updateMemberGroupsProvider =
    AsyncNotifierProvider.autoDispose<UpdateMemberGroupsNotifier, void>(
      UpdateMemberGroupsNotifier.new,
    );

class UpdateMemberGroupsNotifier extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() async {}

  Future<void> execute({
    required String organizationId,
    required String memberId,
    required List<String> groupIds,
  }) async {
    final link = ref.keepAlive();

    try {
      state = const AsyncValue.loading();

      final repo = ref.read(organizationMembersRepositoryProvider);

      final updated = await repo.updateMemberGroups(
        organizationId,
        memberId,
        groupIds,
      );

      if (!ref.mounted) return;

      ref.read(membersPagedProvider.notifier).updateMember(updated);

      ref.read(groupsPagedProvider.notifier).reset();

      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    } finally {
      link.close();
    }
  }
}
