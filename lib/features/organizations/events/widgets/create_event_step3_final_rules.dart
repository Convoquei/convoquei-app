import 'package:convoquei_app/design_system/ds.dart';
import 'package:convoquei_app/features/organizations/events/models/enums/organization_event_assignment_mode.dart';
import 'package:convoquei_app/features/organizations/events/models/enums/organization_event_function_call_mode.dart';
import 'package:convoquei_app/features/organizations/events/models/event_form_step3_data.dart';
import 'package:convoquei_app/features/organizations/events/widgets/create_event_shared_widgets.dart';
import 'package:convoquei_app/features/organizations/events/widgets/function_item_tile.dart';
import 'package:convoquei_app/features/organizations/events/widgets/function_restriction_mode_option.dart';
import 'package:convoquei_app/features/organizations/events/widgets/function_rule_card.dart';
import 'package:convoquei_app/features/organizations/members/models/organization_function_model.dart';
import 'package:convoquei_app/features/organizations/members/models/requests/find_all_organization_functions_request.dart';
import 'package:convoquei_app/features/organizations/members/repositories/organization_functions_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'package:convoquei_app/features/organizations/events/models/event_form_step3_data.dart';

// ─────────────────────────────────────────────────────────────────────────────
// WIDGET
// ─────────────────────────────────────────────────────────────────────────────

class CreateEventStep3FinalRules extends ConsumerWidget {
  final String organizationId;
  final bool canUseAutoSchedule;
  final OrganizationEventAssignmentMode defaultAssignmentMode;
  final CreateEventStep3Data data;
  final ValueChanged<CreateEventStep3Data> onChanged;

  const CreateEventStep3FinalRules({
    super.key,
    required this.organizationId,
    required this.canUseAutoSchedule,
    required this.defaultAssignmentMode,
    required this.data,
    required this.onChanged,
  });

  Future<void> _showAddFunctionSheet(BuildContext context, WidgetRef ref) async {
    final alreadyAdded = data.functionRules.map((r) => r.functionId).toSet();

    await DSMultiSelectModal.show<OrganizationFunctionModel>(
      context,
      title: 'Selecionar Funções',
      fetcher: (r) async {
        final repo = r.read(organizationFunctionsRepositoryProvider);
        final result = await repo.findAllFunctions(
          organizationId,
          FindAllOrganizationFunctionsRequest(page: 0, size: 100),
        );
        return result.items;
      },
      idExtractor: (fn) => fn.id,
      initialSelectedIds: alreadyAdded,
      itemBuilder: (fn, isSelected, onTap) =>
          FunctionItemTile(function: fn, isSelected: isSelected, onTap: onTap),
      onSave: (selectedIds) async {
        final repo = ref.read(organizationFunctionsRepositoryProvider);
        final result = await repo.findAllFunctions(
          organizationId,
          FindAllOrganizationFunctionsRequest(page: 0, size: 100),
        );
        // Merge: keep existing rules' settings, add new, remove deselected
        final existing = {for (final r in data.functionRules) r.functionId: r};
        final merged = result.items
            .where((fn) => selectedIds.contains(fn.id))
            .map(
              (fn) => existing[fn.id] ??
                  FunctionRuleData(
                    functionId: fn.id,
                    name: fn.name,
                    emoji: fn.emoji,
                    assignmentMode: defaultAssignmentMode,
                  ),
            )
            .toList();
        onChanged(data.copyWith(functionRules: merged));
      },
    );
  }

  void _updateRule(int index, FunctionRuleData updated) {
    final rules = [...data.functionRules];
    rules[index] = updated;
    onChanged(data.copyWith(functionRules: rules));
  }

  void _removeRule(int index) {
    final rules = [...data.functionRules]..removeAt(index);
    onChanged(data.copyWith(functionRules: rules));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Fecho da escala ─────────────────────────────────────────────────
        StepCard(
          children: [
            Row(
              children: [
                Icon(Icons.hourglass_top_rounded,
                    color: context.colors.warning, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('Bloqueio de Disponibilidade',
                      style: context.textStyles.titleSmall),
                ),
                if (!canUseAutoSchedule)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: context.colors.border,
                      borderRadius: DSRadius.all(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.lock_outline_rounded,
                            size: 9, color: context.colors.textSecondary),
                        const SizedBox(width: 3),
                        Text(
                          'Não disponível',
                          style: context.textStyles.labelSmall?.copyWith(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: context.colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            Text(
              'Com quanto tempo antes do evento a disponibilidade dos membros deve ser bloqueada e, se necessário, escalar os disponíveis?',
              style: context.textStyles.bodySmall,
            ),
            Opacity(
              opacity: canUseAutoSchedule ? 1.0 : 0.45,
              child: IgnorePointer(
                ignoring: !canUseAutoSchedule,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
                  decoration: BoxDecoration(
                    color: context.colors.surfaceSubtle,
                    borderRadius: DSRadius.allLg,
                    border: Border.all(color: context.colors.border),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      NumberSpinner(
                        value: data.deadlineDays,
                        label: 'Dias',
                        min: 0,
                        max: 30,
                        onChanged: (v) =>
                            onChanged(data.copyWith(deadlineDays: v)),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            bottom: 20, left: 6, right: 6),
                        child: Text(
                          ':',
                          style: context.textStyles.displayMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: context.colors.border,
                          ),
                        ),
                      ),
                      NumberSpinner(
                        value: data.deadlineHours,
                        label: 'Horas',
                        min: 0,
                        max: 23,
                        onChanged: (v) =>
                            onChanged(data.copyWith(deadlineHours: v)),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            bottom: 20, left: 6, right: 6),
                        child: Text(
                          ':',
                          style: context.textStyles.displayMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: context.colors.border,
                          ),
                        ),
                      ),
                      NumberSpinner(
                        value: data.deadlineMinutes,
                        label: 'Minutos',
                        min: 0,
                        max: 59,
                        step: 1,
                        onChanged: (v) =>
                            onChanged(data.copyWith(deadlineMinutes: v)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // ── Regras por Função ─────────────────────────────────────────────
        StepCard(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.manage_accounts_rounded,
                              color: context.colors.primary, size: 20),
                          const SizedBox(width: 8),
                          Text('Regras por Função',
                              style: context.textStyles.titleSmall),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Defina vagas, limites ou sorteios específicos por função.',
                        style: context.textStyles.bodySmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                StepToggle(
                  value: data.hasFunctionRules,
                  onChanged: (v) =>
                      onChanged(data.copyWith(hasFunctionRules: v)),
                ),
              ],
            ),
            if (data.hasFunctionRules) ...[
              // Modo de restrição
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: context.colors.surfaceSubtle,
                  borderRadius: DSRadius.all(14),
                  border: Border.all(color: context.colors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PARTICIPAÇÃO NO EVENTO',
                      style: context.textStyles.labelSmall?.copyWith(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: context.colors.textSecondary,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 12),
                    FunctionRestrictionModeOption(
                      label: 'Apenas as funções abaixo',
                      description:
                          'Membros sem estas funções serão ignorados e não receberão a convocação.',
                      selected: data.functionCallMode ==
                          OrganizationEventFunctionCallMode
                              .onlyMembersWithListedFunctions,
                      onTap: () => onChanged(data.copyWith(
                          functionCallMode: OrganizationEventFunctionCallMode
                              .onlyMembersWithListedFunctions)),
                    ),
                    const SizedBox(height: 10),
                    FunctionRestrictionModeOption(
                      label: 'Todos os convocados',
                      description:
                          'Todos serão convocados, mas as regras abaixo se aplicam às funções específicas.',
                      selected: data.functionCallMode ==
                          OrganizationEventFunctionCallMode
                              .allMembersWithFunctionLimits,
                      onTap: () => onChanged(data.copyWith(
                          functionCallMode: OrganizationEventFunctionCallMode
                              .allMembersWithFunctionLimits)),
                    ),
                  ],
                ),
              ),

              // Lista de regras
              for (int i = 0; i < data.functionRules.length; i++)
                FunctionRuleCard(
                  rule: data.functionRules[i],
                  canUseAutoSchedule: canUseAutoSchedule,
                  onChanged: (updated) => _updateRule(i, updated),
                  onRemove: () => _removeRule(i),
                ),

              // Botão adicionar
              GestureDetector(
                onTap: () => _showAddFunctionSheet(context, ref),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    borderRadius: DSRadius.all(14),
                    border: Border.all(color: context.colors.border),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_rounded,
                          color: context.colors.textSecondary, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        'Adicionar Regra de Função',
                        style: context.textStyles.labelMedium,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
