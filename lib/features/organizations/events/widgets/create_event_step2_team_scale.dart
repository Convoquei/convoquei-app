import 'package:convoquei_app/design_system/ds.dart';
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
import 'package:convoquei_app/features/organizations/groups/models/organization_group_model.dart';
import 'package:convoquei_app/features/organizations/groups/models/requests/find_all_organization_groups_request.dart';
import 'package:convoquei_app/features/organizations/groups/repositories/organization_groups_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'package:convoquei_app/features/organizations/events/models/event_form_step2_data.dart';

// ─────────────────────────────────────────────────────────────────────────────
// WIDGET
// ─────────────────────────────────────────────────────────────────────────────

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
    await DSMultiSelectModal.show<OrganizationGroupModel>(
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
        // ── Info banner ──────────────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.colors.warningTint,
            borderRadius: DSRadius.allLg,
            border: Border.all(
                color: context.colors.warning.withValues(alpha: 0.4)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.groups_rounded,
                  color: context.colors.warning, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Como a equipe será formada?',
                      style: context.textStyles.titleSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Defina quem será convocado e a regra padrão de aprovação para este evento.',
                      style: context.textStyles.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // ── Regra de aprovação ───────────────────────────────────────────────
        StepCard(
          children: [
            const FieldLabel(label: 'Regra de Aprovação Padrão'),
            AssignmentModeCard(
              mode: OrganizationEventAssignmentMode.manual,
              selected:
                  data.assignmentMode == OrganizationEventAssignmentMode.manual,
              locked: false,
              title: 'Aprovação Manual',
              description:
                  'O membro diz que está disponível, mas você decide quem entra e aprova a escala final.',
              icon: Icons.shield_rounded,
              iconColor: context.colors.primary,
              onTap: () => onChanged(data.copyWith(
                  assignmentMode: OrganizationEventAssignmentMode.manual)),
            ),
            AssignmentModeCard(
              mode: OrganizationEventAssignmentMode.automatic,
              selected: data.assignmentMode ==
                  OrganizationEventAssignmentMode.automatic,
              locked: !canUseAutoSchedule,
              title: 'Escala Automática',
              description:
                  'Os membros que aceitarem a convocação serão escalados automaticamente, e a escala será encerrada no tempo configurado.',
              icon: Icons.rocket_launch_rounded,
              iconColor: context.colors.success,
              onTap: () => onChanged(data.copyWith(
                  assignmentMode: OrganizationEventAssignmentMode.automatic)),
            ),
            if (!canUseAutoSchedule) const EventAutoScheduleLockedInfo(),
          ],
        ),
        const SizedBox(height: 16),

        // ── Escopo de convocação ─────────────────────────────────────────────
        StepCard(
          children: [
            const FieldLabel(label: 'Quem será convocado?'),
            EventScopeToggle(
              callMode: data.callMode,
              onChanged: (v) => onChanged(data.copyWith(callMode: v)),
            ),
            if (data.callMode ==
                OrganizationEventCallMode.onlySpecifiedGroupMembers) ...[
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
