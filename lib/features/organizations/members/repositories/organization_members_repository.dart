import 'package:convoquei_app/core/models/paged_response_model.dart';
import 'package:convoquei_app/core/network/base_repository.dart';
import 'package:convoquei_app/core/providers/providers.dart';
import 'package:convoquei_app/features/organizations/members/models/requests/find_all_organization_members_request.dart';
import 'package:convoquei_app/features/organizations/shared/models/organization_member_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OrganizationMembersRepository extends BaseRepository {
  OrganizationMembersRepository({required super.apiClient});

  Future<PagedResponseModel<OrganizationMemberModel>> findAllMembers(
    String organizationId,
    FindAllOrganizationMembersRequest request,
  ) async {
    final data = await apiClient.get(
      '/v1/organizations/$organizationId/members',
      queryParameters: request.toJson(),
    );

    return PagedResponseModel.fromJson(
      data,
      (item) => OrganizationMemberModel.fromJson(item),
    );
  }
}

final organizationMembersRepositoryProvider =
    Provider<OrganizationMembersRepository>((ref) {
      final apiClient = ref.watch(apiClientProvider);
      return OrganizationMembersRepository(apiClient: apiClient);
    });
