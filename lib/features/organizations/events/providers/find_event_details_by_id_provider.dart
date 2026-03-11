import 'package:convoquei_app/features/organizations/events/models/organization_event_details_model.dart';
import 'package:convoquei_app/features/organizations/events/repositories/organization_events_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'find_event_details_by_id_provider.g.dart';

@riverpod
Future<OrganizationEventDetailsModel> findEventDetailsById(
  Ref ref, {
  required String organizationId,
  required String eventId,
}) async {
  return ref.read(organizationEventsRepositoryProvider).findEventDetailsById(
        organizationId: organizationId,
        eventId: eventId,
      );
}
