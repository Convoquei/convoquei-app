import 'package:convoquei_app/core/models/paged_response_model.dart';
import 'package:convoquei_app/core/network/base_repository.dart';
import 'package:convoquei_app/core/providers/providers.dart';
import 'package:convoquei_app/features/organizations/events/models/orgnaization_event_membership_model.dart';
import 'package:convoquei_app/features/organizations/events/models/requests/find_all_events_organization_membership_request.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OrganizationEventsRepository extends BaseRepository {
  OrganizationEventsRepository({required super.apiClient});

  Future<PagedResponseModel<OrganizationEventMembershipModel>> findAllEvents({
    required String organizationId,
    required FindAllEventsOrganizationMembershipRequest request
}) async {
    final queryParameters = request.toJson();

    final data = await apiClient.get(
      '/v1/organizations/$organizationId/events',
      queryParameters: queryParameters,
    );

    return PagedResponseModel<OrganizationEventMembershipModel>.fromJson(
      data,
      (json) => OrganizationEventMembershipModel.fromJson(json),
    );
  }

  Future<OrganizationEventMembershipModel> answerAvailability({
    required String organizationId,
    required String eventId,
    required bool available,
  }) async {
    final data = await apiClient.patch(
      '/v1/organizations/$organizationId/events/$eventId/availability',
      data: {'available': available},
    );

    return OrganizationEventMembershipModel.fromJson(
      data as Map<String, dynamic>,
    );
  }

  Future<OrganizationEventMembershipModel> removeAvailability({
    required String organizationId,
    required String eventId,
  }) async {
    final data = await apiClient.delete(
      '/v1/organizations/$organizationId/events/$eventId/availability',
    );

    return OrganizationEventMembershipModel.fromJson(
      data as Map<String, dynamic>,
    );
  }
}

final organizationEventsRepositoryProvider = Provider<OrganizationEventsRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return OrganizationEventsRepository(apiClient: apiClient);
});