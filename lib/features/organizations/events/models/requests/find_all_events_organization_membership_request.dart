import 'package:convoquei_app/core/models/base_paged_request.dart';
import 'package:convoquei_app/core/utils/date_locale_pt.dart';
import 'package:convoquei_app/features/organizations/events/models/enums/organization_event_membership_status.dart';

class FindAllEventsOrganizationMembershipRequest extends BasePagedRequest {
  String? name;
  DateTime? startAfter;
  DateTime? startBefore;
  List<OrganizationEventMembershipStatus>? status;

  FindAllEventsOrganizationMembershipRequest({
    required super.page,
    required super.size,
    this.name,
    this.startAfter,
    this.startBefore,
    this.status,
  });

  @override
  Map<String, dynamic> toJson() {
    final data = super.toJson();
    if (name != null) data['name'] = name;
    if (startAfter != null) {
      data['startAfter'] = toApiInstant(startAfter!);
    }

    if (startBefore != null) {
      data['startBefore'] = toApiInstant(startBefore!);
    }

    if (status != null && status!.isNotEmpty) {
      data['participantStatus'] = status!.map((s) => s.toCode()).toList();
    }
    return data;
  }
}