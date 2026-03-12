import 'package:convoquei_app/core/theme/app_theme.dart';
import 'package:convoquei_app/core/widgets/modals/multi_select_modal.dart';
import 'package:convoquei_app/features/organizations/events/models/enums/organization_event_assignment_mode.dart';
import 'package:convoquei_app/features/organizations/events/models/enums/organization_event_call_mode.dart';
import 'package:convoquei_app/features/organizations/events/models/event_form_step2_data.dart';
import 'package:convoquei_app/features/organizations/events/widgets/assignment_mode_card.dart';
import 'package:convoquei_app/features/organizations/events/widgets/create_event_shared_widgets.dart';
import 'package:convoquei_app/features/organizations/events/widgets/event_add_group_button.dart';
import 'package:convoquei_app/features/organizations/events/widgets/event_auto_schedule_locked_info.dart';
import 'package:convoquei_app/features/organizations/events/widgets/event_scope_toggle.dart';
import 'package:convoquei_app/features/organizations/events/widgets/event_selected_groups_grid.dart';
import 'package:convoquei_app/features/organizations/events/widgets/group_item_tile.dart';
import 'package:convoquei_app/features/organizations/members/models/organization_group_model.dart';
import 'package:convoquei_app/features/organizations/members/models/requests/find_all_organization_groups_request.dart';
import 'package:convoquei_app/features/organizations/members/repositories/organization_groups_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'package:convoquei_app/features/organizations/events/models/event_form_step2_data.dart';

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// WIDGET
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class CreateEventStep2TeamScale extends ConsumerWidget {
  final String organizationId;
  final bool canUseAutoSchedule;
  final CreateEventStep2Data data;
  final ValueChanged<CreateEventStep2Data> onChanged;

  const CreateEventStep2TeamScale({
    super.key,
    required this.organizationId,
    required this.canUseAutoSchedule,
    required this.data,
    required this.onChanged,
  });

  void _toggleGroup(CreateEventGroupSelection group) {
    final current = List<CreateEventGroupSelection>.from(data.selectedGroups);
    if (current.any((g) => g.id == group.id)) {
      current.removeWhere((g) => g.id == group.id);
    } else {
      current.add(group);
    }
    onChanged(data.copyWith(selectedGroups: current));
  }

  Future<void> _showAddGroupSheet(BuildContext context, WidgetRef ref) async {
    await MultiSelectModal.show<OrganizationGroupModel>(
      context,
      title: 'Selecionar Grupos',
      fetcher: (r) async {
        final repo = r.read(organizationGroupsRepositoryProvider);
        final result = await repo.findAllGroups(
          organizationId,
          FindAllOrganizationGroupsRequest(page: 0, size: 100),
        );
        return result.items;
      },
      idExtractor: (g) => g.id,
      initialSelectedIds: data.selectedGroups.map((g) => g.id).toSet(),
      itemBuilder: (g, isSelected, onTap) =>
          GroupItemTile(group: g, isSelected: isSelected, onTap: onTap),
      onSave: (selectedIds) async {
        final repo = ref.read(organizationGroupsRepositoryProvider);
        final result = await repo.findAllGroups(
          organizationId,
          FindAllOrganizationGroupsRequest(page: 0, size: 100),
        );
        final mapped = result.items
            .where((g) => selectedIds.contains(g.id))
            .map(
              (g) => CreateEventGroupSelection(
                id: g.id,
                name: g.name,
                emoji: g.emoji,
              ),
            )
            .toList();
        onChanged(data.copyWith(selectedGroups: mapped));
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // â”€â”€ Info banner â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF7ED),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFFED7AA)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.groups_rounded,
                  color: AppTheme.secondaryColor, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Como a equipe serÃ¡ formada?',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Defina quem serÃ¡ convocado e a regra padrÃ£o de aprovaÃ§Ã£o para este evento.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // â”€â”€ Regra de aprovaÃ§Ã£o â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
        StepCard(
          children: [
            const FieldLabel(label: 'Regra de AprovaÃ§Ã£o PadrÃ£o'),
            AssignmentModeCard(
              mode: OrganizationEventAssignmentMode.manual,
              selected: data.assignmentMode == OrganizationEventAssignmentMode.manual,
              locked: false,
              title: 'AprovaÃ§Ã£o Manual',
              description:
                  'O membro diz que estÃ¡ disponÃ­vel, mas vocÃª decide quem entra e aprova a escala final.',
              icon: Icons.shield_rounded,
              iconColor: AppTheme.primaryColor,
              onTap: () => onChanged(
                  data.copyWith(assignmentMode: OrganizationEventAssignmentMode.manual)),
            ),
            AssignmentModeCard(
              mode: OrganizationEventAssignmentMode.automatic,
              selected:
                  data.assignmentMode == OrganizationEventAssignmentMode.automatic,
              locked: !canUseAutoSchedule,
              title: 'Escala AutomÃ¡tica',
              description:
                  'Os membros que aceitarem a convocaÃ§Ã£o serÃ£o escalados automaticamente, e a escala serÃ¡ encerrada no tempo configurado.',
              icon: Icons.rocket_launch_rounded,
              iconColor: AppTheme.successColor,
              onTap: () => onChanged(data.copyWith(
                  assignmentMode: OrganizationEventAssignmentMode.automatic)),
            ),
            if (!canUseAutoSchedule) const EventAutoScheduleLockedInfo(),
          ],
        ),
        const SizedBox(height: 16),

        // â”€â”€ Escopo de convocaÃ§Ã£o â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
        StepCard(
          children: [
            const FieldLabel(label: 'Quem serÃ¡ convocado?'),
            EventScopeToggle(
              callMode: data.callMode,
              onChanged: (v) => onChanged(data.copyWith(callMode: v)),
            ),
            if (data.callMode == OrganizationEventCallMode.onlySpecifiedGroupMembers) ...[
              EventSelectedGroupsGrid(
                selected: data.selectedGroups,
                onRemove: _toggleGroup,
              ),
              EventAddGroupButton(
                onTap: () => _showAddGroupSheet(context, ref),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

