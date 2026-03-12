import 'package:convoquei_app/features/organizations/events/models/organization_event_details_model.dart';
import 'package:convoquei_app/features/organizations/events/models/requests/update_organization_event_request.dart';
import 'package:convoquei_app/features/organizations/events/repositories/organization_events_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'update_event_provider.g.dart';

@riverpod
class UpdateEventNotifier extends _$UpdateEventNotifier {
  @override
  FutureOr<void> build() {}

  Future<OrganizationEventDetailsModel> save({
    required String organizationId,
    required String eventId,
    required UpdateOrganizationEventRequest request,
  }) async {
    return ref.read(organizationEventsRepositoryProvider).updateEvent(
          organizationId: organizationId,
          eventId: eventId,
          request: request,
        );
  }
}
