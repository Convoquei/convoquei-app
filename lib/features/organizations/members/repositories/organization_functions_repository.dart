import 'package:convoquei_app/core/models/paged_response_model.dart';
import 'package:convoquei_app/core/network/base_repository.dart';
import 'package:convoquei_app/core/providers/providers.dart';
import 'package:convoquei_app/features/organizations/members/models/organization_function_member_model.dart';
import 'package:convoquei_app/features/organizations/members/models/organization_function_model.dart';
import 'package:convoquei_app/features/organizations/members/models/requests/find_all_organization_functions_request.dart';
import 'package:convoquei_app/features/organizations/members/models/requests/find_function_members_request.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OrganizationFunctionsRepository extends BaseRepository {
  OrganizationFunctionsRepository({required super.apiClient});

  Future<PagedResponseModel<OrganizationFunctionModel>> findAllFunctions(
    String organizationId,
    FindAllOrganizationFunctionsRequest request,
  ) async {
    final data = await apiClient.get(
      '/v1/organizations/$organizationId/functions',
      queryParameters: request.toJson(),
    );

    return PagedResponseModel.fromJson(
      data,
      (item) => OrganizationFunctionModel.fromJson(item),
    );
  }

  Future<PagedResponseModel<OrganizationFunctionMemberModel>> findFunctionMembers(
    String organizationId,
    String functionId,
    FindFunctionMembersRequest request,
  ) async {
    final data = await apiClient.get(
      '/v1/organizations/$organizationId/functions/$functionId/members',
      queryParameters: request.toJson(),
    );

    return PagedResponseModel.fromJson(
      data,
      (item) => OrganizationFunctionMemberModel.fromJson(item),
    );
  }

  Future<OrganizationFunctionModel> createFunction({
    required String organizationId,
    required String name,
    required String emoji,
  }) async {
    final data = await apiClient.post(
      '/v1/organizations/$organizationId/functions',
      data: {'name': name, 'emoji': emoji},
    );
    return OrganizationFunctionModel.fromJson(data);
  }

  Future<void> deleteFunction(
    String organizationId,
    String functionId,
  ) async {
    await apiClient.delete(
      '/v1/organizations/$organizationId/functions/$functionId',
    );
  }

  Future<void> deleteFunctionMember(
    String organizationId,
    String functionId,
    String memberId,
  ) async {
    await apiClient.delete(
      '/v1/organizations/$organizationId/functions/$functionId/members/$memberId',
    );
  }

  Future<void> clearFunctionMembers(
    String organizationId,
    String functionId,
  ) async {
    await apiClient.delete(
      '/v1/organizations/$organizationId/functions/$functionId/members',
    );
  }

  Future<void> addFunctionMember(
    String organizationId,
    String functionId,
  ) async {
    await apiClient.post(
      '/v1/organizations/$organizationId/functions/$functionId/members',
    );
  }
}

final organizationFunctionsRepositoryProvider =
    Provider<OrganizationFunctionsRepository>((ref) {
      final apiClient = ref.watch(apiClientProvider);
      return OrganizationFunctionsRepository(apiClient: apiClient);
    });
