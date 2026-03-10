import 'package:convoquei_app/features/organizations/events/models/enums/organization_event_membership_status.dart';

class EventsFilter {
  final String? name;
  final DateTime? startAfter;
  final DateTime? startBefore;
  final List<OrganizationEventMembershipStatus>? status;

  const EventsFilter({
    this.name,
    this.startAfter,
    this.startBefore,
    this.status,
  });

  @override
  bool operator ==(Object other) =>
      other is EventsFilter &&
      other.name == name &&
      other.startAfter == startAfter &&
      other.startBefore == startBefore &&
      _listEquals(other.status, status);

  @override
  int get hashCode =>
      Object.hash(name, startAfter, startBefore, Object.hashAll(status ?? []));

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
