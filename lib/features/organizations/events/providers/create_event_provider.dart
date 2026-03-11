import 'package:convoquei_app/features/organizations/events/models/orgnaization_event_membership_model.dart';
import 'package:convoquei_app/features/organizations/events/models/requests/create_organization_event_request.dart';
import 'package:convoquei_app/features/organizations/events/repositories/organization_events_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'create_event_provider.g.dart';

@riverpod
class CreateEventNotifier extends _$CreateEventNotifier {
  @override
  FutureOr<void> build() {}

  Future<OrganizationEventMembershipModel> create({
    required String organizationId,
    required CreateOrganizationEventRequest request,
  }) async {
    return ref.read(organizationEventsRepositoryProvider).createEvent(
          organizationId: organizationId,
          request: request,
        );
  }
}
