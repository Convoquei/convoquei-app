import 'dart:async';

import 'package:convoquei_app/features/organizations/members/models/organization_function_model.dart';
import 'package:convoquei_app/features/organizations/members/providers/list_all_functions_query_provider.dart';
import 'package:convoquei_app/features/organizations/members/repositories/organization_functions_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final createFunctionProvider =
    AsyncNotifierProvider.autoDispose<CreateFunctionNotifier, void>(
      CreateFunctionNotifier.new,
    );

class CreateFunctionNotifier extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() async {}

  Future<OrganizationFunctionModel> create({
    required String organizationId,
    required String name,
    required String emoji,
  }) async {
    final link = ref.keepAlive();

    try {
      state = const AsyncValue.loading();

      final repo = ref.read(organizationFunctionsRepositoryProvider);
      final created = await repo.createFunction(
        organizationId: organizationId,
        name: name,
        emoji: emoji,
      );

      if (ref.mounted) {
        ref.read(functionsPagedProvider.notifier).reset();
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
