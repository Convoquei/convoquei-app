import 'package:convoquei_app/features/organizations/events/models/enums/organization_event_membership_availability_status.dart';
import 'package:convoquei_app/features/organizations/events/models/enums/organization_event_membership_status.dart';
import 'package:convoquei_app/features/organizations/events/models/enums/organization_event_status.dart';

class EventsFilter {
  final String? name;
  final DateTime? startAfter;
  final DateTime? startBefore;

  /// Status de escala do participante.
  final List<OrganizationEventMembershipStatus>? membershipStatus;

  /// Status de disponibilidade do participante no evento.
  final List<OrganizationEventMembershipAvailabilityStatus>? availabilityStatus;

  /// Status do evento (scheduled, inProgress, completed, canceled).
  final List<OrganizationEventStatus>? eventStatus;

  const EventsFilter({
    this.name,
    this.startAfter,
    this.startBefore,
    this.membershipStatus,
    this.availabilityStatus,
    this.eventStatus,
  });

  @override
  bool operator ==(Object other) =>
      other is EventsFilter &&
      other.name == name &&
      other.startAfter == startAfter &&
      other.startBefore == startBefore &&
      _listEquals(other.membershipStatus, membershipStatus) &&
      _listEquals(other.availabilityStatus, availabilityStatus) &&
      _listEquals(other.eventStatus, eventStatus);

  @override
  int get hashCode => Object.hash(
        name,
        startAfter,
        startBefore,
        Object.hashAll(membershipStatus ?? []),
        Object.hashAll(availabilityStatus ?? []),
        Object.hashAll(eventStatus ?? []),
      );

  static bool _listEquals(List? a, List? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
