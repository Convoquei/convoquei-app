import 'package:convoquei_app/core/models/paged_response_model.dart';
import 'package:convoquei_app/core/network/base_repository.dart';
import 'package:convoquei_app/core/providers/providers.dart' show apiClientProvider;
import 'package:convoquei_app/features/organizations/events/models/organization_event_details_model.dart';
import 'package:convoquei_app/features/organizations/events/models/orgnaization_event_membership_model.dart';
import 'package:convoquei_app/features/organizations/events/models/requests/create_organization_event_request.dart';
import 'package:convoquei_app/features/organizations/events/models/requests/find_all_events_organization_membership_request.dart';
import 'package:convoquei_app/features/organizations/events/models/requests/update_organization_event_request.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'organization_events_repository.g.dart';

class OrganizationEventsRepository extends BaseRepository {
  OrganizationEventsRepository({required super.apiClient});

  Future<OrganizationEventMembershipModel> createEvent({
    required String organizationId,
    required CreateOrganizationEventRequest request,
  }) async {
    final data = await apiClient.post(
      '/v1/organizations/$organizationId/events',
      data: request.toJson(),
    );

    return OrganizationEventMembershipModel.fromJson(
      data as Map<String, dynamic>,
    );
  }

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
    String? functionId,
  }) async {
    final data = await apiClient.patch(
      '/v1/organizations/$organizationId/events/$eventId/availability',
      data: {
        'available': available,
        if (functionId != null) 'functionId': functionId,
      },
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

  Future<OrganizationEventMembershipModel> findEventById({
    required String organizationId,
    required String eventId,
  }) async {
    final data = await apiClient.get(
      '/v1/organizations/$organizationId/events/$eventId',
    );

    return OrganizationEventMembershipModel.fromJson(
      data as Map<String, dynamic>,
    );
  }

  Future<OrganizationEventDetailsModel> updateEvent({
    required String organizationId,
    required String eventId,
    required UpdateOrganizationEventRequest request,
  }) async {
    final data = await apiClient.patch(
      '/v1/organizations/$organizationId/events/$eventId',
      data: request.toJson(),
    );

    return OrganizationEventDetailsModel.fromJson(
      data as Map<String, dynamic>,
    );
  }

  Future<OrganizationEventDetailsModel> findEventDetailsById({
    required String organizationId,
    required String eventId,
  }) async {
    final data = await apiClient.get(
      '/v1/organizations/$organizationId/events/$eventId/details',
    );

    return OrganizationEventDetailsModel.fromJson(
      data as Map<String, dynamic>,
    );
  }

  Future<void> assignParticipant({
    required String organizationId,
    required String eventId,
    required String membershipId,
  }) async {
    await apiClient.patch(
      '/v1/organizations/$organizationId/events/$eventId/participants/$membershipId/assign',
    );
  }

  Future<void> rejectParticipant({
    required String organizationId,
    required String eventId,
    required String membershipId,
  }) async {
    await apiClient.patch(
      '/v1/organizations/$organizationId/events/$eventId/participants/$membershipId/reject',
    );
  }

  Future<void> removeAssignedParticipant({
    required String organizationId,
    required String eventId,
    required String membershipId,
  }) async {
    await apiClient.delete(
      '/v1/organizations/$organizationId/events/$eventId/participants/$membershipId',
    );
  }

  Future<void> notifyEventParticipants({
    required String organizationId,
    required String eventId,
  }) async {
    await apiClient.post(
      '/v1/organizations/$organizationId/events/$eventId/participants/notify',
    );
  }
}

@riverpod
OrganizationEventsRepository organizationEventsRepository(Ref ref) {
  return OrganizationEventsRepository(apiClient: ref.watch(apiClientProvider));
}