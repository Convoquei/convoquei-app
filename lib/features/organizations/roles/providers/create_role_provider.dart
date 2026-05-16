import 'dart:async';

import 'package:convoquei_app/features/organizations/roles/providers/list_roles_organization_provider.dart';
import 'package:convoquei_app/features/organizations/shared/models/organization_role_model.dart';
import 'package:convoquei_app/features/organizations/shared/repositories/organization_role_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final createRoleProvider =
    AsyncNotifierProvider.autoDispose<CreateRoleNotifier, void>(
      CreateRoleNotifier.new,
    );

class CreateRoleNotifier extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() async {}

  Future<OrganizationRoleModel> execute({
    required String organizationId,
    required String name,
  }) async {
    final link = ref.keepAlive();

    try {
      state = const AsyncLoading();

      late OrganizationRoleModel created;

      state = await AsyncValue.guard(() async {
        created = await ref
            .read(organizationRoleRepositoryProvider)
            .createRole(organizationId: organizationId, name: name);
      });

      if (state.hasError) throw state.error!;

      if (!ref.mounted) return created;

      ref.read(rolesProvider.notifier).reset();

      return created;
    } finally {
      link.close();
    }
  }
}
