import 'package:convoquei_app/core/models/paged_response_model.dart';
import 'package:convoquei_app/core/network/base_repository.dart';
import 'package:convoquei_app/core/providers/providers.dart';
import 'package:convoquei_app/features/organizations/members/models/requests/find_all_organization_members_request.dart';
import 'package:convoquei_app/features/organizations/shared/models/organization_invite_model.dart';
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

  Future<OrganizationMemberModel> kickMember(
    String organizationId,
    String memberId,
  ) async {
    final data = await apiClient.delete(
      '/v1/organizations/$organizationId/members/$memberId',
    );

    return OrganizationMemberModel.fromJson(data);
  }

  Future<OrganizationMemberModel> updateMemberGroups(
    String organizationId,
    String memberId,
    List<String> groupIds,
  ) async {
    final data = await apiClient.put(
      '/v1/organizations/$organizationId/members/$memberId/groups',
      data: {'groupIds': groupIds},
    );

    return OrganizationMemberModel.fromJson(data);
  }

  Future<OrganizationInviteModel> inviteMemberByEmail(
    String organizationId,
    String email,
  ) async {
    final data = await apiClient.post(
      '/v1/organizations/$organizationId/invites',
      data: {'email': email},
    );

    return OrganizationInviteModel.fromJson(data);
  }
}

final organizationMembersRepositoryProvider =
    Provider<OrganizationMembersRepository>((ref) {
      final apiClient = ref.watch(apiClientProvider);
      return OrganizationMembersRepository(apiClient: apiClient);
    });
