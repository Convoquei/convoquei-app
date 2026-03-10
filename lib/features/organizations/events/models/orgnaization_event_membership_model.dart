import 'package:convoquei_app/features/organizations/events/models/enums/organization_event_assignment_mode.dart';
import 'package:convoquei_app/features/organizations/events/models/enums/organization_event_membership_availability_status.dart';
import 'package:convoquei_app/features/organizations/events/models/enums/organization_event_membership_status.dart';
import 'package:convoquei_app/features/organizations/events/models/enums/organization_event_status.dart';

class OrganizationEventMembershipModel {
  final String id;
  final String name;
  final String description;
  final String location;
  final DateTime startTime;
  final DateTime endTime;
  final OrganizationEventStatus status;
  final int availabilityLockBeforeStartMinutes;
  final int availabilityLockEpochSeconds;
  final int participantsCount;
  final bool allowAssignment;
  final OrganizationEventAssignmentMode assignmentMode;
  final OrganizationEventMembershipAvailabilityStatus? membershipAvailabilityStatus;
  final OrganizationEventMembershipStatus? membershipStatus;

  Duration get durationBeforeStartEvent => Duration(seconds: availabilityLockEpochSeconds);

  OrganizationEventMembershipModel({
    required this.id,
    required this.name,
    required this.description,
    required this.location,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.availabilityLockBeforeStartMinutes,
    required this.availabilityLockEpochSeconds,
    required this.participantsCount,
    required this.allowAssignment,
    required this.assignmentMode,
    this.membershipAvailabilityStatus,
    this.membershipStatus,
  });

  factory OrganizationEventMembershipModel.fromJson(Map<String, dynamic> json) {
    return OrganizationEventMembershipModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      location: json['location'] as String,
      startTime: DateTime.parse(json['startTime'] as String).toLocal(),
      endTime: DateTime.parse(json['endTime'] as String).toLocal(),
      status: OrganizationEventStatus.fromCode(json['status'] as String),
      availabilityLockBeforeStartMinutes: json['availabilityLockBeforeStartMinutes'] as int,
      availabilityLockEpochSeconds: json['availabilityLockEpochSeconds'] as int,
      allowAssignment: json['allowAssignment'] as bool,
      participantsCount: json['participantsCount'] as int,
      assignmentMode: OrganizationEventAssignmentMode.fromCode(json['assignmentMode'] as String),
      membershipAvailabilityStatus: json['membershipAvailabilityStatus'] != null
          ? OrganizationEventMembershipAvailabilityStatus.fromCode(
              json['membershipAvailabilityStatus'] as String,
            )
          : null,
      membershipStatus: json['membershipStatus'] != null
          ? OrganizationEventMembershipStatus.fromCode(
              json['membershipStatus'] as String,
            )
          : null,
    );
  }
}
