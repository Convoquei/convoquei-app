import 'package:convoquei_app/features/organizations/events/models/enums/organization_event_assignment_mode.dart';
import 'package:convoquei_app/features/organizations/events/models/enums/organization_event_call_mode.dart';
import 'package:convoquei_app/features/organizations/events/models/enums/organization_event_function_call_mode.dart';
import 'package:convoquei_app/features/organizations/events/models/event_form_step2_data.dart';
import 'package:convoquei_app/features/organizations/events/models/event_form_step3_data.dart';
import 'package:convoquei_app/features/organizations/events/models/requests/create_organization_event_request.dart';

class UpdateOrganizationEventRequest {
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
  final String? dressCodeDescription;
  final List<String>? dressCodeColors;

  const UpdateOrganizationEventRequest.fromFields({
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
    this.dressCodeDescription,
    this.dressCodeColors,
  });

  factory UpdateOrganizationEventRequest.fromSteps({
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

    return UpdateOrganizationEventRequest.fromFields(
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
        if (dressCodeDescription != null) 'dressCodeDescription': dressCodeDescription,
        if (dressCodeColors != null) 'dressCodeColors': dressCodeColors,
      };
}
