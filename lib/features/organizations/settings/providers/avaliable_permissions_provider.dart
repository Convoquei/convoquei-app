import 'package:convoquei_app/features/organizations/shared/models/OrganizationRolePermissionModel.dart';
import 'package:convoquei_app/features/organizations/shared/repositories/organization_role_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final avaliablePermissionsProvider = FutureProvider
    .autoDispose
    .family<List<OrganizationRolePermissionModel>, String>((ref, organizationId) async {
      final repo = ref.read(organizationRoleRepositoryProvider);

      final result = await repo.getAvaliablePermissions(
        organizationId: organizationId,
      );

      return result;
    });