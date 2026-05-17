import 'package:convoquei_app/features/organizations/events/models/enums/organization_event_assignment_mode.dart';
import 'package:convoquei_app/features/organizations/events/models/enums/organization_event_call_mode.dart';
import 'package:convoquei_app/features/organizations/events/models/enums/organization_event_function_call_mode.dart';
import 'package:convoquei_app/features/organizations/events/models/enums/organization_event_membership_availability_status.dart';
import 'package:convoquei_app/features/organizations/events/models/enums/organization_event_membership_status.dart';
import 'package:convoquei_app/features/organizations/events/models/enums/organization_event_status.dart';

class OrganizationEventCalledGroupModel {
  final String id;
  final String name;
  final String icon;

  OrganizationEventCalledGroupModel({
    required this.id,
    required this.name,
    required this.icon,
  });

  factory OrganizationEventCalledGroupModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return OrganizationEventCalledGroupModel(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String,
    );
  }
}

class OrganizationEventCalledFunctionDetailsModel {
  final String functionId;
  final String functionName;
  final String icon;
  final int minMembers;
  final int? maxMembers;
  final OrganizationEventAssignmentMode assignmentMode;

  OrganizationEventCalledFunctionDetailsModel({
    required this.functionId,
    required this.functionName,
    required this.icon,
    required this.minMembers,
    this.maxMembers,
    required this.assignmentMode,
  });

  factory OrganizationEventCalledFunctionDetailsModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return OrganizationEventCalledFunctionDetailsModel(
      functionId: json['functionId'] as String,
      functionName: json['functionName'] as String,
      icon: json['icon'] as String,
      minMembers: json['minMembers'] as int,
      maxMembers: json['maxMembers'] as int?,
      assignmentMode: OrganizationEventAssignmentMode.fromCode(
        json['assignmentMode'] as String,
      ),
    );
  }
}

class OrganizationEventParticipantModel {
  final String participantId;
  final String memberId;
  final String name;
  final String? avatarUrl;
  final String? function;
  final OrganizationEventMembershipStatus status;
  final OrganizationEventMembershipAvailabilityStatus availabilityStatus;
  final DateTime updatedAt;

  OrganizationEventParticipantModel({
    required this.participantId,
    required this.memberId,
    required this.name,
    this.avatarUrl,
    this.function,
    required this.status,
    required this.availabilityStatus,
    required this.updatedAt,
  });

  factory OrganizationEventParticipantModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return OrganizationEventParticipantModel(
      participantId: json['participantId'] as String,
      memberId: json['memberId'] as String,
      name: json['name'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      function: json['function'] as String?,
      status: OrganizationEventMembershipStatus.fromCode(
        json['status'] as String,
      ),
      availabilityStatus:
          OrganizationEventMembershipAvailabilityStatus.fromCode(
            json['availabilityStatus'] as String,
          ),
      updatedAt: DateTime.parse(json['updatedAt'] as String).toLocal(),
    );
  }
}

class OrganizationEventDetailsModel {
  final String id;
  final String name;
  final String description;
  final String location;
  final OrganizationEventStatus status;
  final DateTime startAt;
  final DateTime endAt;
  final OrganizationEventAssignmentMode assignmentMode;
  final OrganizationEventCallMode callMode;
  final OrganizationEventFunctionCallMode? functionCallMode;
  final int availabilityLockBeforeStartInMinutes;
  final int availabilityLockEpochSeconds;
  final bool allowAssignment;
  final List<OrganizationEventCalledGroupModel> calledGroups;
  final List<OrganizationEventCalledFunctionDetailsModel> calledFunctions;
  final List<OrganizationEventParticipantModel> participants;
  final String? dressCodeDescription;
  final List<String>? dressCodeColors;

  OrganizationEventDetailsModel({
    required this.id,
    required this.name,
    required this.description,
    required this.location,
    required this.status,
    required this.startAt,
    required this.endAt,
    required this.assignmentMode,
    required this.callMode,
    this.functionCallMode,
    required this.availabilityLockBeforeStartInMinutes,
    required this.availabilityLockEpochSeconds,
    required this.allowAssignment,
    this.calledGroups = const [],
    this.calledFunctions = const [],
    this.participants = const [],
    this.dressCodeDescription,
    this.dressCodeColors,
  });

  factory OrganizationEventDetailsModel.fromJson(Map<String, dynamic> json) {
    return OrganizationEventDetailsModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      location: json['location'] as String,
      status: OrganizationEventStatus.fromCode(json['status'] as String),
      startAt: DateTime.parse(json['startAt'] as String).toLocal(),
      endAt: DateTime.parse(json['endAt'] as String).toLocal(),
      assignmentMode: OrganizationEventAssignmentMode.fromCode(
        json['assignmentMode'] as String,
      ),
      callMode: OrganizationEventCallMode.fromCode(json['callMode'] as String),
      functionCallMode: json['functionCallMode'] != null
          ? OrganizationEventFunctionCallMode.fromCode(
              json['functionCallMode'] as String,
            )
          : null,
      availabilityLockBeforeStartInMinutes:
          json['availabilityLockBeforeStartInMinutes'] as int,
      availabilityLockEpochSeconds: json['availabilityLockEpochSeconds'] as int,
      allowAssignment: json['allowAssignment'] as bool,
      calledGroups:
          (json['calledGroups'] as List<dynamic>?)
              ?.map(
                (e) => OrganizationEventCalledGroupModel.fromJson(
                  e as Map<String, dynamic>,
                ),
              )
              .toList() ??
          [],
      calledFunctions:
          (json['calledFunctions'] as List<dynamic>?)
              ?.map(
                (e) => OrganizationEventCalledFunctionDetailsModel.fromJson(
                  e as Map<String, dynamic>,
                ),
              )
              .toList() ??
          [],
      participants:
          (json['participants'] as List<dynamic>?)
              ?.map(
                (e) => OrganizationEventParticipantModel.fromJson(
                  e as Map<String, dynamic>,
                ),
              )
              .toList() ??
          [],
      dressCodeDescription: json['dressCodeDescription'] as String?,
      dressCodeColors: (json['dressCodeColors'] as List<dynamic>?)
          ?.cast<String>(),
    );
  }
}
