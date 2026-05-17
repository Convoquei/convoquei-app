import 'package:convoquei_app/features/organizations/events/models/enums/organization_event_assignment_mode.dart';
import 'package:convoquei_app/features/organizations/events/models/enums/organization_event_function_call_mode.dart';
import 'package:convoquei_app/features/organizations/events/models/enums/organization_event_membership_availability_status.dart';
import 'package:convoquei_app/features/organizations/events/models/enums/organization_event_membership_status.dart';
import 'package:convoquei_app/features/organizations/events/models/enums/organization_event_status.dart';

class EventCalledFunctionModel {
  final String id;
  final String name;
  final String emoji;
  final int minMembers;
  final int? maxMembers;
  final OrganizationEventAssignmentMode assignmentMode;

  EventCalledFunctionModel({
    required this.id,
    required this.name,
    required this.emoji,
    required this.minMembers,
    this.maxMembers,
    required this.assignmentMode,
  });

  factory EventCalledFunctionModel.fromJson(Map<String, dynamic> json) {
    return EventCalledFunctionModel(
      id: json['id'] as String,
      name: json['name'] as String,
      emoji: json['emoji'] as String,
      minMembers: json['minMembers'] as int,
      maxMembers: json['maxMembers'] as int?,
      assignmentMode: OrganizationEventAssignmentMode.fromCode(
        json['assignmentMode'] as String,
      ),
    );
  }
}

class OrganizationEventMembershipModel {
  final String id;
  final String name;
  final String description;
  final String location;
  final DateTime startTime;
  final DateTime endTime;
  final OrganizationEventStatus status;
  final int availabilityLockBeforeStartInMinutes;
  final int availabilityLockEpochSeconds;
  final int participantsCount;
  final bool allowAssignment;
  final OrganizationEventAssignmentMode assignmentMode;
  final OrganizationEventMembershipAvailabilityStatus?
  membershipAvailabilityStatus;
  final OrganizationEventMembershipStatus? membershipStatus;
  final String? membershipFunctionId;
  final String? membershipFunctionName;
  final String? membershipFunctionEmoji;
  final OrganizationEventFunctionCallMode? functionCallMode;
  final List<EventCalledFunctionModel> calledFunctions;

  Duration get durationBeforeStartEvent =>
      Duration(seconds: availabilityLockEpochSeconds);

  OrganizationEventMembershipModel({
    required this.id,
    required this.name,
    required this.description,
    required this.location,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.availabilityLockBeforeStartInMinutes,
    required this.availabilityLockEpochSeconds,
    required this.participantsCount,
    required this.allowAssignment,
    required this.assignmentMode,
    this.membershipAvailabilityStatus,
    this.membershipStatus,
    this.membershipFunctionId,
    this.membershipFunctionName,
    this.membershipFunctionEmoji,
    this.functionCallMode,
    this.calledFunctions = const [],
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
      availabilityLockBeforeStartInMinutes:
          json['availabilityLockBeforeStartInMinutes'] as int,
      availabilityLockEpochSeconds: json['availabilityLockEpochSeconds'] as int,
      allowAssignment: json['allowAssignment'] as bool,
      participantsCount: json['participantsCount'] as int,
      assignmentMode: OrganizationEventAssignmentMode.fromCode(
        json['assignmentMode'] as String,
      ),
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
      membershipFunctionId: json['membershipFunctionId'] as String?,
      membershipFunctionName: json['membershipFunctionName'] as String?,
      membershipFunctionEmoji: json['membershipFunctionEmoji'] as String?,
      functionCallMode: json['functionCallMode'] != null
          ? OrganizationEventFunctionCallMode.fromCode(
              json['functionCallMode'] as String,
            )
          : null,
      calledFunctions:
          (json['calledFunctions'] as List<dynamic>?)
              ?.map(
                (e) => EventCalledFunctionModel.fromJson(
                  e as Map<String, dynamic>,
                ),
              )
              .toList() ??
          [],
    );
  }
}
