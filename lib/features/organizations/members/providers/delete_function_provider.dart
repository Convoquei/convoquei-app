import 'dart:async';

import 'package:convoquei_app/features/organizations/members/providers/list_all_functions_query_provider.dart';
import 'package:convoquei_app/features/organizations/members/repositories/organization_functions_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final deleteFunctionProvider =
    AsyncNotifierProvider.autoDispose<DeleteFunctionNotifier, void>(
      DeleteFunctionNotifier.new,
    );

class DeleteFunctionNotifier extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() async {}

  Future<void> delete({
    required String organizationId,
    required String functionId,
  }) async {
    final link = ref.keepAlive();

    try {
      state = const AsyncValue.loading();

      final repo = ref.read(organizationFunctionsRepositoryProvider);

      state = await AsyncValue.guard(() async {
        await repo.deleteFunction(organizationId, functionId);
      });

      if (!ref.mounted) return;

      ref.read(functionsPagedProvider.notifier).reset();
    } finally {
      link.close();
    }
  }
}
