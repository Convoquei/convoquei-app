import 'package:convoquei_app/features/organizations/events/models/enums/organization_event_membership_availability_status.dart';
import 'package:convoquei_app/features/organizations/events/models/orgnaization_event_membership_model.dart';
import 'package:convoquei_app/features/organizations/events/models/requests/find_all_events_organization_membership_request.dart';
import 'package:convoquei_app/features/organizations/events/repositories/organization_events_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'next_pending_availability_event_provider.g.dart';

@riverpod
Future<OrganizationEventMembershipModel?> nextPendingAvailabilityEvent(
  Ref ref,
  String organizationId,
) async {
  final result = await ref
      .read(organizationEventsRepositoryProvider)
      .findAllEvents(
        organizationId: organizationId,
        request: FindAllEventsOrganizationMembershipRequest(
          page: 0,
          size: 1,
          availabilityStatus: [
            OrganizationEventMembershipAvailabilityStatus.notAnswered,
          ],
          startAfter: DateTime.now(),
        ),
      );
  return result.items.isEmpty ? null : result.items.first;
}
