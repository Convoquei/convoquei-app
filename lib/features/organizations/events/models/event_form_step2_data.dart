import 'package:flutter/foundation.dart';
import 'package:convoquei_app/features/organizations/events/models/enums/organization_event_assignment_mode.dart';
import 'package:convoquei_app/features/organizations/events/models/enums/organization_event_call_mode.dart';

class CreateEventGroupSelection {
  final String id;
  final String name;
  final String emoji;

  const CreateEventGroupSelection({
    required this.id,
    required this.name,
    required this.emoji,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreateEventGroupSelection &&
          id == other.id &&
          name == other.name &&
          emoji == other.emoji;

  @override
  int get hashCode => Object.hash(id, name, emoji);
}

class CreateEventStep2Data {
  final OrganizationEventAssignmentMode assignmentMode;
  final OrganizationEventCallMode callMode;
  final List<CreateEventGroupSelection> selectedGroups;

  const CreateEventStep2Data({
    this.assignmentMode = OrganizationEventAssignmentMode.manual,
    this.callMode = OrganizationEventCallMode.allOrganizationMembers,
    this.selectedGroups = const [],
  });

  bool get isValid =>
      callMode == OrganizationEventCallMode.allOrganizationMembers ||
      selectedGroups.isNotEmpty;

  CreateEventStep2Data copyWith({
    OrganizationEventAssignmentMode? assignmentMode,
    OrganizationEventCallMode? callMode,
    List<CreateEventGroupSelection>? selectedGroups,
  }) {
    return CreateEventStep2Data(
      assignmentMode: assignmentMode ?? this.assignmentMode,
      callMode: callMode ?? this.callMode,
      selectedGroups: selectedGroups ?? this.selectedGroups,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreateEventStep2Data &&
          assignmentMode == other.assignmentMode &&
          callMode == other.callMode &&
          listEquals(selectedGroups, other.selectedGroups);

  @override
  int get hashCode => Object.hash(
        assignmentMode,
        callMode,
        Object.hashAll(selectedGroups),
      );
}
