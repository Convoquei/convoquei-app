import 'dart:async';

import 'package:convoquei_app/features/organizations/members/providers/list_all_members_query_provider.dart';
import 'package:convoquei_app/features/organizations/members/repositories/organization_members_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final kickOrganizationMemberProvider =
    AsyncNotifierProvider.autoDispose<KickMemberNotifier, void>(
      KickMemberNotifier.new,
    );

class KickMemberNotifier extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() async {}

  Future<void> kick({
    required String organizationId,
    required String memberId,
  }) async {
    final link = ref.keepAlive();

    try {
      state = const AsyncValue.loading();

      final repo = ref.read(organizationMembersRepositoryProvider);

      state = await AsyncValue.guard(() async {
        await repo.kickMember(organizationId, memberId);
      });

      if (!ref.mounted) return;

      ref.read(membersPagedProvider.notifier).removeMember(memberId);
    } finally {
      link.close(); // ✅ sempre executa, erro ou não
    }
  }
}
