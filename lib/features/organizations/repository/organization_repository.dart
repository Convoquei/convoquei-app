import 'package:convoquei_app/core/models/paged_response_model.dart';
import 'package:convoquei_app/core/network/api_client.dart';
import 'package:convoquei_app/features/organizations/models/organization_invite_model.dart';
import 'package:convoquei_app/features/organizations/models/organization_model.dart';
import 'package:convoquei_app/features/organizations/models/requests/find_invites_user_request_model.dart';
import 'package:convoquei_app/features/organizations/models/requests/organization_request_model.dart';

class OrganizationRepository {
  final ApiClient _apiClient;

  const OrganizationRepository({required ApiClient apiClient})
    : _apiClient = apiClient;

  Future<PagedResponseModel<OrganizationModel>> findAll(
    OrganizationRequestModel request,
  ) async {
    final data = await _apiClient.get<Map<String, dynamic>>(
      '/v1/organizations',
      queryParameters: request.toJson(),
    );
    return PagedResponseModel.fromJson(
      data,
      (item) => OrganizationModel.fromJson(item),
    );
  }

  Future<PagedResponseModel<OrganizationInviteModel>> findAllInvitesByUser(
    FindInvitesUserRequestModel request,
  ) async {
    final data = await _apiClient.get<Map<String, dynamic>>(
      '/v1/users/me/invites',
      queryParameters: request.toJson(),
    );
    return PagedResponseModel.fromJson(
      data,
      (item) => OrganizationInviteModel.fromJson(item),
    );
  }

  Future<void> acceptInvite(String inviteId) async {
    await _apiClient.post('/v1/users/me/invites/$inviteId/accept');
  }

  Future<void> declineInvite(String inviteId) async {
    await _apiClient.post('/v1/users/me/invites/$inviteId/decline');
  }

  Future<OrganizationModel> create({
    required String name,
    required String type,
  }) async {
    final data = await _apiClient.post<Map<String, dynamic>>(
      '/v1/organizations',
      data: {'name': name, 'type': type},
    );
    return OrganizationModel.fromJson(data);
  }
}
