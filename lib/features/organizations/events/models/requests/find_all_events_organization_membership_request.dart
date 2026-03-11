import 'package:convoquei_app/core/models/base_paged_request.dart';
import 'package:convoquei_app/core/utils/date_locale_pt.dart';
import 'package:convoquei_app/features/organizations/events/models/enums/organization_event_membership_status.dart';
import 'package:convoquei_app/features/organizations/events/models/enums/organization_event_status.dart';

class FindAllEventsOrganizationMembershipRequest extends BasePagedRequest {
  String? name;
  DateTime? startAfter;
  DateTime? startBefore;

  /// Status de escala do participante (filtra pela relação membro↔evento).
  List<OrganizationEventMembershipStatus>? membershipStatus;

  /// Status do próprio evento (scheduled, inProgress, completed, canceled).
  List<OrganizationEventStatus>? eventStatus;

  FindAllEventsOrganizationMembershipRequest({
    required super.page,
    required super.size,
    this.name,
    this.startAfter,
    this.startBefore,
    this.membershipStatus,
    this.eventStatus,
  });

  @override
  Map<String, dynamic> toJson() {
    final data = super.toJson();
    if (name != null) data['name'] = name;
    if (startAfter != null) data['startAfter'] = toApiInstant(startAfter!);
    if (startBefore != null) data['startBefore'] = toApiInstant(startBefore!);
    if (membershipStatus != null && membershipStatus!.isNotEmpty) {
      data['participantStatus'] = membershipStatus!.map((s) => s.toCode()).toList();
    }
    if (eventStatus != null && eventStatus!.isNotEmpty) {
      data['eventStatus'] = eventStatus!.map((s) => s.toCode()).toList();
    }
    return data;
  }
}