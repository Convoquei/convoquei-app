import 'dart:async';

import 'package:convoquei_app/features/organizations/members/providers/function_members_paged_provider.dart';
import 'package:convoquei_app/features/organizations/members/providers/list_all_functions_query_provider.dart';
import 'package:convoquei_app/features/organizations/members/repositories/organization_functions_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final clearFunctionMembersProvider =
    AsyncNotifierProvider.autoDispose<ClearFunctionMembersNotifier, void>(
      ClearFunctionMembersNotifier.new,
    );

class ClearFunctionMembersNotifier extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() async {}

  Future<void> clear({
    required String organizationId,
    required String functionId,
  }) async {
    final link = ref.keepAlive();

    try {
      state = const AsyncValue.loading();

      final repo = ref.read(organizationFunctionsRepositoryProvider);

      state = await AsyncValue.guard(() async {
        await repo.clearFunctionMembers(organizationId, functionId);
      });

      if (!ref.mounted) return;

      ref.read(functionMembersPagedProvider(functionId).notifier).clearAll();
      ref.read(functionsPagedProvider.notifier).clearMemberCount(functionId);
    } finally {
      link.close();
    }
  }
}
