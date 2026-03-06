import 'package:convoquei_app/core/models/paged_response_model.dart';
import 'package:convoquei_app/core/network/base_repository.dart';
import 'package:convoquei_app/core/providers/providers.dart';
import 'package:convoquei_app/features/organizations/shared/models/OrganizationRolePermissionModel.dart';
import 'package:convoquei_app/features/organizations/shared/models/organization_role_member_model.dart';
import 'package:convoquei_app/features/organizations/shared/models/organization_role_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OrganizationRoleRepository extends BaseRepository {
  OrganizationRoleRepository({required super.apiClient});

  Future<PagedResponseModel<OrganizationRoleMemberModel>>
  getOrganizationRoleMembers({
    required String organizationId,
    required String roleId,
    int page = 0,
    int pageSize = 100,
  }) async {
    final data = await apiClient.get(
      '/v1/organizations/$organizationId/roles/$roleId/members',
      queryParameters: {'page': page, 'size': pageSize},
    );

    return PagedResponseModel<OrganizationRoleMemberModel>.fromJson(
      data,
      (json) => OrganizationRoleMemberModel.fromJson(json),
    );
  }

  Future<PagedResponseModel<OrganizationRoleModel>> getOrganizationRoles({
    required String organizationId,
    int page = 0,
    int pageSize = 10,
  }) async {
    final data = await apiClient.get(
      '/v1/organizations/$organizationId/roles',
      queryParameters: {'page': page, 'size': pageSize},
    );

    return PagedResponseModel<OrganizationRoleModel>.fromJson(
      data,
      (json) => OrganizationRoleModel.fromJson(json),
    );
  }

  Future<List<OrganizationRolePermissionModel>> getAvaliablePermissions({
    required String organizationId,
  }) async {
    final data = await apiClient.get(
      '/v1/organizations/$organizationId/roles/permissions',
    );

    return (data as List)
        .map((json) => OrganizationRolePermissionModel.fromJson(json))
        .toList();
  }

  Future<OrganizationRoleModel> updateRolePermissions({
    required String organizationId,
    required String roleId,
    required List<String> permissions,
  }) async {
    final data = await apiClient.put(
      '/v1/organizations/$organizationId/roles/$roleId/permissions',
      data: {'permissions': permissions},
    );

    return OrganizationRoleModel.fromJson(data);
  }

  Future<void> deleteRole({
    required String organizationId,
    required String roleId,
  }) async {
    await apiClient.delete(
      '/v1/organizations/$organizationId/roles/$roleId',
    );
  }

  Future<void> removeRoleMember({
    required String organizationId,
    required String roleId,
    required String memberId,
  }) async {
    await apiClient.delete(
      '/v1/organizations/$organizationId/roles/$roleId/members/$memberId',
    );
  }

  Future<OrganizationRoleModel> createRole({
    required String organizationId,
    required String name,
    List<String> permissions = const [],
  }) async {
    final data = await apiClient.post(
      '/v1/organizations/$organizationId/roles',
      data: {'name': name, 'permissions': permissions},
    );
    return OrganizationRoleModel.fromJson(data);
  }
}

final organizationRoleRepositoryProvider = Provider<OrganizationRoleRepository>(
  (ref) {
    final apiClient = ref.watch(apiClientProvider);
    return OrganizationRoleRepository(apiClient: apiClient);
  },
);
