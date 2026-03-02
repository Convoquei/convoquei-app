import 'package:convoquei_app/core/models/paged_response_model.dart';
import 'package:convoquei_app/core/network/api_client.dart';
import 'package:convoquei_app/features/organizations/models/organization_model.dart';
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
}
