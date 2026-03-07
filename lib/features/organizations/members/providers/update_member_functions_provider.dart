import 'dart:async';

import 'package:convoquei_app/features/organizations/members/repositories/organization_members_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final updateMemberFunctionsProvider =
    AsyncNotifierProvider.autoDispose<UpdateMemberFunctionsNotifier, void>(
      UpdateMemberFunctionsNotifier.new,
    );

class UpdateMemberFunctionsNotifier extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() async {}

  Future<void> execute({
    required String organizationId,
    required String memberId,
    required List<String> functionIds,
  }) async {
    final link = ref.keepAlive();

    try {
      state = const AsyncValue.loading();

      final repo = ref.read(organizationMembersRepositoryProvider);

      await repo.updateMemberFunctions(
        organizationId,
        memberId,
        functionIds,
      );

      if (!ref.mounted) return;

      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    } finally {
      link.close();
    }
  }
}
