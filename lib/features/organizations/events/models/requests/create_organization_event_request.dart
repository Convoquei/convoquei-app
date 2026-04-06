import 'package:convoquei_app/features/organizations/events/models/enums/organization_event_assignment_mode.dart';
import 'package:convoquei_app/features/organizations/events/models/enums/organization_event_call_mode.dart';
import 'package:convoquei_app/features/organizations/events/models/enums/organization_event_function_call_mode.dart';
import 'package:convoquei_app/features/organizations/events/models/event_form_step2_data.dart';
import 'package:convoquei_app/features/organizations/events/models/event_form_step3_data.dart';

class CalledFunctionPayload {
  final String id;
  final int minMembers;
  final int? maxMembers;
  final OrganizationEventAssignmentMode assignmentMode;

  const CalledFunctionPayload({
    required this.id,
    required this.minMembers,
    this.maxMembers,
    required this.assignmentMode,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'minMembers': minMembers,
        if (maxMembers != null) 'maxMembers': maxMembers,
        'assignmentMode': assignmentMode.toCode(),
      };
}

class CreateOrganizationEventRequest {
  final String name;
  final String description;
  final String location;
  final OrganizationEventAssignmentMode assignmentMode;
  final OrganizationEventCallMode callMode;
  final OrganizationEventFunctionCallMode? functionCallMode;
  final int availabilityLockBeforeStartInMinutes;
  final List<CalledFunctionPayload> calledFunctionIds;
  final List<String> calledGroupIds;
  final DateTime startDate;
  final DateTime endDate;

  const CreateOrganizationEventRequest._({
    required this.name,
    required this.description,
    required this.location,
    required this.assignmentMode,
    required this.callMode,
    this.functionCallMode,
    required this.availabilityLockBeforeStartInMinutes,
    required this.calledFunctionIds,
    required this.calledGroupIds,
    required this.startDate,
    required this.endDate,
  });

  factory CreateOrganizationEventRequest.fromSteps({
    required String name,
    required String description,
    required String location,
    required DateTime startDate,
    required DateTime endDate,
    required CreateEventStep2Data step2,
    required CreateEventStep3Data step3,
  }) {
    final callMode = step2.callMode;

    final calledGroupIds =
        callMode == OrganizationEventCallMode.allOrganizationMembers
            ? <String>[]
            : step2.selectedGroups.map((g) => g.id).toList();

    final lockMinutes = step3.deadlineDays * 24 * 60 +
        step3.deadlineHours * 60 +
        step3.deadlineMinutes;

    final functionCallMode =
        step3.hasFunctionRules ? step3.functionCallMode : null;

    final calledFunctions = step3.hasFunctionRules
        ? step3.functionRules
            .map(
              (r) => CalledFunctionPayload(
                id: r.functionId,
                minMembers: r.min,
                maxMembers: r.max,
                assignmentMode: r.assignmentMode,
              ),
            )
            .toList()
        : <CalledFunctionPayload>[];

    return CreateOrganizationEventRequest._(
      name: name,
      description: description,
      location: location,
      assignmentMode: step2.assignmentMode,
      callMode: callMode,
      functionCallMode: functionCallMode,
      availabilityLockBeforeStartInMinutes: lockMinutes,
      calledFunctionIds: calledFunctions,
      calledGroupIds: calledGroupIds,
      startDate: startDate,
      endDate: endDate,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'location': location,
        'assignmentMode': assignmentMode.toCode(),
        'callMode': callMode.toCode(),
        'functionCallMode': functionCallMode?.toCode(),
        'availabilityLockBeforeStartInMinutes':
            availabilityLockBeforeStartInMinutes,
        'calledFunctionIds': calledFunctionIds.map((f) => f.toJson()).toList(),
        'calledGroupIds': calledGroupIds,
        'startDate': startDate.toUtc().toIso8601String(),
        'endDate': endDate.toUtc().toIso8601String(),
      };
}
