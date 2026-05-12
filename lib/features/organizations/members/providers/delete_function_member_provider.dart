import 'dart:async';

import 'package:convoquei_app/features/organizations/members/providers/function_members_paged_provider.dart';
import 'package:convoquei_app/features/organizations/members/providers/list_all_functions_query_provider.dart';
import 'package:convoquei_app/features/organizations/members/repositories/organization_functions_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final deleteFunctionMemberProvider =
    AsyncNotifierProvider.autoDispose<DeleteFunctionMemberNotifier, void>(
      DeleteFunctionMemberNotifier.new,
    );

class DeleteFunctionMemberNotifier extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() async {}

  Future<void> remove({
    required String organizationId,
    required String functionId,
    required String memberId,
  }) async {
    final link = ref.keepAlive();

    try {
      state = const AsyncValue.loading();

      final repo = ref.read(organizationFunctionsRepositoryProvider);

      state = await AsyncValue.guard(() async {
        await repo.deleteFunctionMember(organizationId, functionId, memberId);
      });

      if (!ref.mounted) return;

      ref
          .read(functionMembersPagedProvider(functionId).notifier)
          .removeMember(memberId);
      ref.read(functionsProvider.notifier).decrementMemberCount(functionId);
    } finally {
      link.close();
    }
  }
}
