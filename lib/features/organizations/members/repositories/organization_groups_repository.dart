import 'package:convoquei_app/core/models/paged_response_model.dart';
import 'package:convoquei_app/core/network/base_repository.dart';
import 'package:convoquei_app/core/providers/providers.dart';
import 'package:convoquei_app/features/organizations/members/models/organization_group_model.dart';
import 'package:convoquei_app/features/organizations/members/models/requests/find_all_organization_groups_request.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OrganizationGroupsRepository extends BaseRepository {
  OrganizationGroupsRepository({required super.apiClient});

  Future<PagedResponseModel<OrganizationGroupModel>> findAllGroups(String organizationId, FindAllOrganizationGroupsRequest request) async {
    final data = await apiClient.get(
      '/v1/organizations/$organizationId/groups',
      queryParameters: request.toJson(),
    );

    return PagedResponseModel.fromJson(
      data,
      (item) => OrganizationGroupModel.fromJson(item),
    );
  }
}

final organizationGroupsRepositoryProvider =
    Provider<OrganizationGroupsRepository>((ref) {
      final apiClient = ref.watch(apiClientProvider);
      return OrganizationGroupsRepository(apiClient: apiClient);
    });
