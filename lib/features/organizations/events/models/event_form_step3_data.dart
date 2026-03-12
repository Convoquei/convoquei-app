import 'package:flutter/foundation.dart';
import 'package:convoquei_app/features/organizations/events/models/enums/organization_event_assignment_mode.dart';
import 'package:convoquei_app/features/organizations/events/models/enums/organization_event_function_call_mode.dart';

class FunctionRuleData {
  final String functionId;
  final String name;
  final String emoji;
  final int min;

  /// null = sem limite (∞)
  final int? max;
  final OrganizationEventAssignmentMode assignmentMode;

  const FunctionRuleData({
    required this.functionId,
    required this.name,
    required this.emoji,
    this.min = 1,
    this.max,
    this.assignmentMode = OrganizationEventAssignmentMode.manual,
  });

  FunctionRuleData copyWith({
    int? min,
    int? max,
    bool clearMax = false,
    OrganizationEventAssignmentMode? assignmentMode,
  }) {
    return FunctionRuleData(
      functionId: functionId,
      name: name,
      emoji: emoji,
      min: min ?? this.min,
      max: clearMax ? null : max ?? this.max,
      assignmentMode: assignmentMode ?? this.assignmentMode,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FunctionRuleData &&
          functionId == other.functionId &&
          min == other.min &&
          max == other.max &&
          assignmentMode == other.assignmentMode;

  @override
  int get hashCode => Object.hash(functionId, min, max, assignmentMode);
}

class CreateEventStep3Data {
  final int deadlineDays;
  final int deadlineHours;
  final int deadlineMinutes;
  final bool hasFunctionRules;
  final OrganizationEventFunctionCallMode functionCallMode;
  final List<FunctionRuleData> functionRules;

  const CreateEventStep3Data({
    this.deadlineDays = 0,
    this.deadlineHours = 6,
    this.deadlineMinutes = 0,
    this.hasFunctionRules = false,
    this.functionCallMode =
        OrganizationEventFunctionCallMode.allMembersWithFunctionLimits,
    this.functionRules = const [],
  });

  bool get isValid => true; // Passo 3 sempre válido — regras são opcionais

  CreateEventStep3Data copyWith({
    int? deadlineDays,
    int? deadlineHours,
    int? deadlineMinutes,
    bool? hasFunctionRules,
    OrganizationEventFunctionCallMode? functionCallMode,
    List<FunctionRuleData>? functionRules,
  }) {
    return CreateEventStep3Data(
      deadlineDays: deadlineDays ?? this.deadlineDays,
      deadlineHours: deadlineHours ?? this.deadlineHours,
      deadlineMinutes: deadlineMinutes ?? this.deadlineMinutes,
      hasFunctionRules: hasFunctionRules ?? this.hasFunctionRules,
      functionCallMode: functionCallMode ?? this.functionCallMode,
      functionRules: functionRules ?? this.functionRules,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreateEventStep3Data &&
          deadlineDays == other.deadlineDays &&
          deadlineHours == other.deadlineHours &&
          deadlineMinutes == other.deadlineMinutes &&
          hasFunctionRules == other.hasFunctionRules &&
          functionCallMode == other.functionCallMode &&
          listEquals(functionRules, other.functionRules);

  @override
  int get hashCode => Object.hash(
        deadlineDays,
        deadlineHours,
        deadlineMinutes,
        hasFunctionRules,
        functionCallMode,
        Object.hashAll(functionRules),
      );
}
