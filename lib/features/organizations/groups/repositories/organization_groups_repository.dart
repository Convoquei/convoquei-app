import 'package:convoquei_app/core/models/paged_response_model.dart';
import 'package:convoquei_app/core/network/base_repository.dart';
import 'package:convoquei_app/core/providers/providers.dart' show apiClientProvider;
import 'package:convoquei_app/features/organizations/groups/models/organization_group_model.dart';
import 'package:convoquei_app/features/organizations/groups/models/organization_group_participant_model.dart';
import 'package:convoquei_app/features/organizations/groups/models/requests/find_all_organization_groups_request.dart';
import 'package:convoquei_app/features/organizations/groups/models/requests/find_group_participants_request.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'organization_groups_repository.g.dart';

class OrganizationGroupsRepository extends BaseRepository {
  OrganizationGroupsRepository({required super.apiClient});

  Future<PagedResponseModel<OrganizationGroupModel>> findAllGroups(
    String organizationId,
    FindAllOrganizationGroupsRequest request,
  ) async {
    final data = await apiClient.get(
      '/v1/organizations/$organizationId/groups',
      queryParameters: request.toJson(),
    );

    return PagedResponseModel.fromJson(
      data,
      (item) => OrganizationGroupModel.fromJson(item),
    );
  }

  Future<PagedResponseModel<OrganizationGroupParticipantModel>>
  findGroupParticipants(
    String organizationId,
    String groupId,
    FindGroupParticipantsRequest request,
  ) async {
    final data = await apiClient.get(
      '/v1/organizations/$organizationId/groups/$groupId/participants',
      queryParameters: request.toJson(),
    );

    return PagedResponseModel.fromJson(
      data,
      (item) => OrganizationGroupParticipantModel.fromJson(item),
    );
  }

  Future<void> clearGroupParticipants(
    String organizationId,
    String groupId,
  ) async {
    await apiClient.delete(
      '/v1/organizations/$organizationId/groups/$groupId/participants',
    );
  }

  Future<void> deleteGroup(
    String organizationId,
    String groupId,
  ) async {
    await apiClient.delete(
      '/v1/organizations/$organizationId/groups/$groupId',
    );
  }

  Future<void> deleteGroupParticipant(
    String organizationId,
    String groupId,
    String participantId,
  ) async {
    await apiClient.delete(
      '/v1/organizations/$organizationId/groups/$groupId/participants/$participantId',
    );
  }

  Future<OrganizationGroupModel> createGroup({
    required String organizationId,
    required String name,
    required String emoji,
  }) async {
    final data = await apiClient.post(
      '/v1/organizations/$organizationId/groups',
      data: {'name': name, 'emoji': emoji},
    );
    return OrganizationGroupModel.fromJson(data);
  }
}

@riverpod
OrganizationGroupsRepository organizationGroupsRepository(Ref ref) {
  return OrganizationGroupsRepository(apiClient: ref.watch(apiClientProvider));
}
