import 'package:convoquei_app/core/theme/app_theme.dart';
import 'package:convoquei_app/core/widgets/modals/multi_select_modal.dart';
import 'package:convoquei_app/features/organizations/events/models/enums/organization_event_assignment_mode.dart';
import 'package:convoquei_app/features/organizations/events/models/enums/organization_event_call_mode.dart';
import 'package:convoquei_app/features/organizations/events/widgets/create_event_shared_widgets.dart';
import 'package:convoquei_app/features/organizations/members/models/organization_group_model.dart';
import 'package:convoquei_app/features/organizations/members/models/requests/find_all_organization_groups_request.dart';
import 'package:convoquei_app/features/organizations/members/repositories/organization_groups_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CreateEventGroupSelection {
  final String id;
  final String name;
  final String emoji;

  const CreateEventGroupSelection({
    required this.id,
    required this.name,
    required this.emoji,
  });
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
}

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
          _GroupItemTile(group: g, isSelected: isSelected, onTap: onTap),
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
                      'Como a equipe será formada?',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Defina quem será convocado e a regra padrão de aprovação para este evento.',
                      style: Theme.of(context).textTheme.bodySmall,
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
            _AssignmentModeCard(
              mode: OrganizationEventAssignmentMode.manual,
              selected: data.assignmentMode == OrganizationEventAssignmentMode.manual,
              locked: false,
              title: 'Aprovação Manual',
              description:
                  'O membro diz que está disponível, mas você decide quem entra e aprova a escala final.',
              icon: Icons.shield_rounded,
              iconColor: AppTheme.primaryColor,
              onTap: () => onChanged(
                  data.copyWith(assignmentMode: OrganizationEventAssignmentMode.manual)),
            ),
            _AssignmentModeCard(
              mode: OrganizationEventAssignmentMode.automatic,
              selected:
                  data.assignmentMode == OrganizationEventAssignmentMode.automatic,
              locked: !canUseAutoSchedule,
              title: 'Escala Automática',
              description:
                  'Os membros que aceitarem a convocação serão escalados automaticamente, e a escala será encerrada no tempo configurado.',
              icon: Icons.rocket_launch_rounded,
              iconColor: const Color(0xFF10B981),
              onTap: () => onChanged(data.copyWith(
                  assignmentMode: OrganizationEventAssignmentMode.automatic)),
            ),
            if (!canUseAutoSchedule) const _AutoScheduleLockedInfo(),
          ],
        ),
        const SizedBox(height: 16),

        // ── Escopo de convocação ─────────────────────────────────────────────
        StepCard(
          children: [
            const FieldLabel(label: 'Quem será convocado?'),
            _ScopeToggle(
              callMode: data.callMode,
              onChanged: (v) => onChanged(data.copyWith(callMode: v)),
            ),
            if (data.callMode == OrganizationEventCallMode.onlySpecifiedGroupMembers) ...[
              _SelectedGroupsGrid(
                selected: data.selectedGroups,
                onRemove: _toggleGroup,
              ),
              _AddGroupButton(
                onTap: () => _showAddGroupSheet(context, ref),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PRIVATE HELPERS
// ─────────────────────────────────────────────────────────────────────────────

class _AssignmentModeCard extends StatelessWidget {
  final OrganizationEventAssignmentMode mode;
  final bool selected;
  final bool locked;
  final String title;
  final String description;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  const _AssignmentModeCard({
    required this.mode,
    required this.selected,
    required this.locked,
    required this.title,
    required this.description,
    required this.icon,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: locked ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: locked ? const Color(0xFFF8FAFC) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: !locked && selected
                ? AppTheme.primaryColor
                : const Color(0xFFE2E8F0),
            width: !locked && selected ? 2 : 1,
          ),
        ),
        child: Opacity(
          opacity: locked ? 0.55 : 1.0,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Radio / lock indicator
              if (locked)
                Container(
                  width: 18,
                  height: 18,
                  margin: const EdgeInsets.only(top: 1),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFCBD5E1),
                      width: 2,
                    ),
                  ),
                )
              else
                Container(
                  width: 18,
                  height: 18,
                  margin: const EdgeInsets.only(top: 1),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected
                          ? AppTheme.primaryColor
                          : const Color(0xFFCBD5E1),
                      width: 2,
                    ),
                  ),
                  child: selected
                      ? Center(
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppTheme.primaryColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                        )
                      : null,
                ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(icon, color: iconColor, size: 18),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            title,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                        ),
                        if (locked)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE2E8F0),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.lock_outline_rounded,
                                    size: 9,
                                    color: AppTheme.textSecondary),
                                SizedBox(width: 3),
                                Text(
                                  'Não disponível',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AutoScheduleLockedInfo extends StatelessWidget {
  const _AutoScheduleLockedInfo();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F9FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFBAE6FD)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded,
              size: 14, color: Color(0xFF0284C7)),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'A Escala Automática fecha a janela de disponibilidade no horário configurado e define as escalas sem intervenção manual. Este recurso ainda não está ativo nesta organização.',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 10,
                color: Color(0xFF0369A1),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScopeToggle extends StatelessWidget {
  final OrganizationEventCallMode callMode;
  final ValueChanged<OrganizationEventCallMode> onChanged;

  const _ScopeToggle({required this.callMode, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          _ToggleOption(
            label: 'Todos',
            active: callMode == OrganizationEventCallMode.allOrganizationMembers,
            onTap: () => onChanged(OrganizationEventCallMode.allOrganizationMembers),
          ),
          _ToggleOption(
            label: 'Grupos Específicos',
            active: callMode == OrganizationEventCallMode.onlySpecifiedGroupMembers,
            onTap: () => onChanged(OrganizationEventCallMode.onlySpecifiedGroupMembers),
          ),
        ],
      ),
    );
  }
}

class _ToggleOption extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _ToggleOption(
      {required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
            border: Border.all(
              color: active ? const Color(0xFFE2E8F0) : Colors.transparent,
            ),
            boxShadow: active
                ? const [
                    BoxShadow(color: Color(0x0A000000), blurRadius: 4)
                  ]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              color: active ? AppTheme.textPrimary : AppTheme.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _SelectedGroupsGrid extends StatelessWidget {
  final List<CreateEventGroupSelection> selected;
  final ValueChanged<CreateEventGroupSelection> onRemove;

  const _SelectedGroupsGrid(
      {required this.selected, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    if (selected.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Text(
          'Nenhum grupo selecionado. Adicione abaixo.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 3.2,
      ),
      itemCount: selected.length,
      itemBuilder: (_, i) {
        final group = selected[i];
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: const [
              BoxShadow(color: Color(0x08000000), blurRadius: 4),
            ],
          ),
          child: Row(
            children: [
              Text(group.emoji, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  group.name,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              GestureDetector(
                onTap: () => onRemove(group),
                child: const Icon(Icons.close_rounded,
                    size: 16, color: Color(0xFF94A3B8)),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AddGroupButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AddGroupButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFEFF6FF),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: AppTheme.primaryColor.withOpacity(0.3),
              style: BorderStyle.solid),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_rounded,
                color: AppTheme.primaryColor, size: 18),
            const SizedBox(width: 6),
            Text(
              'Adicionar Grupo',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppTheme.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GroupItemTile extends StatelessWidget {
  final OrganizationGroupModel group;
  final bool isSelected;
  final VoidCallback onTap;

  const _GroupItemTile({
    required this.group,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor.withOpacity(0.06)
              : Colors.transparent,
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Text(
                group.emoji,
                style: const TextStyle(fontSize: 20),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                group.name,
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primaryColor : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isSelected
                      ? AppTheme.primaryColor
                      : const Color(0xFFCBD5E1),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check_rounded,
                      size: 14, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
