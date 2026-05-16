import 'dart:async';

import 'package:convoquei_app/features/organizations/groups/models/organization_group_model.dart';
import 'package:convoquei_app/features/organizations/groups/providers/list_all_groups_query_provider.dart';
import 'package:convoquei_app/features/organizations/groups/repositories/organization_groups_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final createGroupProvider =
    AsyncNotifierProvider.autoDispose<CreateGroupNotifier, void>(
      CreateGroupNotifier.new,
    );

class CreateGroupNotifier extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() async {}

  Future<OrganizationGroupModel> create({
    required String organizationId,
    required String name,
    required String emoji,
  }) async {
    final link = ref.keepAlive();

    try {
      state = const AsyncValue.loading();

      final repo = ref.read(organizationGroupsRepositoryProvider);
      final created = await repo.createGroup(
        organizationId: organizationId,
        name: name,
        emoji: emoji,
      );

      if (ref.mounted) {
        ref.read(groupsPagedProvider.notifier).reset();
      }

      state = const AsyncValue.data(null);
      return created;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    } finally {
      link.close();
    }
  }
}
