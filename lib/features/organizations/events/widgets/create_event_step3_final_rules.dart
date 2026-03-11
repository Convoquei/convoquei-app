import 'package:convoquei_app/core/theme/app_theme.dart';
import 'package:convoquei_app/features/organizations/events/models/enums/organization_event_assignment_mode.dart';
import 'package:convoquei_app/features/organizations/events/models/enums/organization_event_function_call_mode.dart';
import 'package:convoquei_app/core/widgets/modals/multi_select_modal.dart';
import 'package:convoquei_app/features/organizations/events/widgets/create_event_shared_widgets.dart';
import 'package:convoquei_app/features/organizations/members/models/organization_function_model.dart';
import 'package:convoquei_app/features/organizations/members/models/requests/find_all_organization_functions_request.dart';
import 'package:convoquei_app/features/organizations/members/repositories/organization_functions_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ─────────────────────────────────────────────────────────────────────────────
// DATA MODELS
// ─────────────────────────────────────────────────────────────────────────────

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
    this.functionCallMode = OrganizationEventFunctionCallMode.allMembersWithFunctionLimits,
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
}

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

    await MultiSelectModal.show<OrganizationFunctionModel>(
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
          _FunctionItemTile(function: fn, isSelected: isSelected, onTap: onTap),
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
                const Icon(Icons.hourglass_top_rounded,
                    color: Color(0xFFF59E0B), size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('Bloqueio de Disponibilidade',
                      style: Theme.of(context).textTheme.titleSmall),
                ),
                if (!canUseAutoSchedule)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.lock_outline_rounded,
                            size: 9, color: AppTheme.textSecondary),
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
            Text(
              'Com quanto tempo antes do evento a disponibilidade dos membros deve ser bloqueada e, se necessário, escalar os disponíveis?',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Opacity(
              opacity: canUseAutoSchedule ? 1.0 : 0.45,
              child: IgnorePointer(
                ignoring: !canUseAutoSchedule,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
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
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFCBD5E1),
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
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFCBD5E1),
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
                          const Icon(Icons.manage_accounts_rounded,
                              color: AppTheme.primaryColor, size: 20),
                          const SizedBox(width: 8),
                          Text('Regras por Função',
                              style: Theme.of(context).textTheme.titleSmall),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Defina vagas, limites ou sorteios específicos por função.',
                        style: Theme.of(context).textTheme.bodySmall,
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
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'PARTICIPAÇÃO NO EVENTO',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textSecondary,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _RestrictionModeOption(
                      label: 'Apenas as funções abaixo',
                      description:
                          'Membros sem estas funções serão ignorados e não receberão a convocação.',
                      selected: data.functionCallMode ==
                          OrganizationEventFunctionCallMode.onlyMembersWithListedFunctions,
                      onTap: () => onChanged(data.copyWith(
                          functionCallMode: OrganizationEventFunctionCallMode.onlyMembersWithListedFunctions)),
                    ),
                    const SizedBox(height: 10),
                    _RestrictionModeOption(
                      label: 'Todos os convocados',
                      description:
                          'Todos serão convocados, mas as regras abaixo se aplicam às funções específicas.',
                      selected: data.functionCallMode ==
                          OrganizationEventFunctionCallMode.allMembersWithFunctionLimits,
                      onTap: () => onChanged(data.copyWith(
                          functionCallMode: OrganizationEventFunctionCallMode.allMembersWithFunctionLimits)),
                    ),
                  ],
                ),
              ),

              // Lista de regras
              for (int i = 0; i < data.functionRules.length; i++)
                _FunctionRuleCard(
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
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: const Color(0xFFCBD5E1),
                        style: BorderStyle.solid),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.add_rounded,
                          color: AppTheme.textSecondary, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        'Adicionar Regra de Função',
                        style: Theme.of(context).textTheme.labelMedium,
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

// ─────────────────────────────────────────────────────────────────────────────
// PRIVATE HELPERS
// ─────────────────────────────────────────────────────────────────────────────

class _FunctionAssignmentOption extends StatelessWidget {
  final bool selected;
  final bool locked;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _FunctionAssignmentOption({
    required this.selected,
    this.locked = false,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: locked ? null : onTap,
      behavior: HitTestBehavior.opaque,
      child: Opacity(
        opacity: locked ? 0.55 : 1.0,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: !locked && selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: !locked && selected
                  ? AppTheme.primaryColor
                  : const Color(0xFFE2E8F0),
              width: !locked && selected ? 1.5 : 1,
            ),
            boxShadow: !locked && selected
                ? const [BoxShadow(color: Color(0x08000000), blurRadius: 4)]
                : null,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Radio / lock indicator
              Container(
                width: 18,
                height: 18,
                margin: const EdgeInsets.only(top: 1),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: !locked && selected
                        ? AppTheme.primaryColor
                        : const Color(0xFFCBD5E1),
                    width: 2,
                  ),
                ),
                child: !locked && selected
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
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(icon, size: 14, color: iconColor),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            title,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: !locked && selected
                                  ? AppTheme.textPrimary
                                  : AppTheme.textSecondary,
                            ),
                          ),
                        ),
                        if (locked)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE2E8F0),
                              borderRadius: BorderRadius.circular(5),
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
                    const SizedBox(height: 3),
                    Text(
                      description,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 10,
                        color: AppTheme.textSecondary,
                        height: 1.4,
                      ),
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

class _RestrictionModeOption extends StatelessWidget {
  final String label;
  final String description;
  final bool selected;
  final VoidCallback onTap;

  const _RestrictionModeOption({
    required this.label,
    required this.description,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 18,
            height: 18,
            margin: const EdgeInsets.only(top: 1),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: selected ? AppTheme.primaryColor : const Color(0xFFCBD5E1),
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
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 2),
                Text(description,
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FunctionRuleCard extends StatelessWidget {
  final FunctionRuleData rule;
  final bool canUseAutoSchedule;
  final ValueChanged<FunctionRuleData> onChanged;
  final VoidCallback onRemove;

  const _FunctionRuleCard({
    required this.rule,
    required this.canUseAutoSchedule,
    required this.onChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final maxLabel = rule.max == null ? '∞' : '${rule.max}';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [BoxShadow(color: Color(0x08000000), blurRadius: 6)],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // ── Header da função ─────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
            child: Row(
              children: [
                Text(rule.emoji, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(rule.name,
                      style: Theme.of(context).textTheme.titleSmall),
                ),
                IconButton(
                  onPressed: onRemove,
                  icon: const Icon(Icons.delete_outline_rounded,
                      color: Color(0xFFEF4444), size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),

          // ── Mín / Máx ────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Expanded(
                  child: _MinMaxControl(
                    label: 'Mínimo necessário',
                    value: rule.min,
                    displayValue: '${rule.min}',
                    onDecrement: rule.min > 0
                        ? () => onChanged(rule.copyWith(min: rule.min - 1))
                        : null,
                    onIncrement: () =>
                        onChanged(rule.copyWith(min: rule.min + 1)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MinMaxControl(
                    label: 'Máximo permitido',
                    value: rule.max ?? 0,
                    displayValue: maxLabel,
                    onDecrement: rule.max != null && rule.max! > 0
                        ? () => onChanged(
                            rule.max == 1
                                ? rule.copyWith(clearMax: true)
                                : rule.copyWith(max: rule.max! - 1))
                        : null,
                    onIncrement: () => onChanged(
                      rule.max == null
                          ? rule.copyWith(max: 1)
                          : rule.copyWith(max: rule.max! + 1),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Modo de escalação da função ──────────────────────────────────
          Container(
            color: const Color(0xFFF8FAFC),
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ESCALAÇÃO DESTA FUNÇÃO',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textSecondary,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 10),
                _FunctionAssignmentOption(
                  selected: rule.assignmentMode == OrganizationEventAssignmentMode.manual,
                  icon: Icons.shield_rounded,
                  iconColor: AppTheme.primaryColor,
                  title: 'Aprovação manual',
                  description:
                      'O líder decide quem entra nesta função, mesmo que o evento use escala automática para os demais.',
                  onTap: () => onChanged(
                      rule.copyWith(assignmentMode: OrganizationEventAssignmentMode.manual)),
                ),
                const SizedBox(height: 6),
                _FunctionAssignmentOption(
                  selected: rule.assignmentMode == OrganizationEventAssignmentMode.automatic,
                  locked: !canUseAutoSchedule,
                  icon: Icons.rocket_launch_rounded,
                  iconColor: const Color(0xFF10B981),
                  title: 'Escala automática',
                  description: rule.max != null
                      ? 'No fecho da escala, os primeiros ${rule.max} disponíveis desta função serão escalados automaticamente.'
                      : 'No fecho da escala, todos os disponíveis desta função serão escalados automaticamente.',
                  onTap: () => onChanged(
                      rule.copyWith(assignmentMode: OrganizationEventAssignmentMode.automatic)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MinMaxControl extends StatelessWidget {
  final String label;
  final int value;
  final String displayValue;
  final VoidCallback? onDecrement;
  final VoidCallback onIncrement;

  const _MinMaxControl({
    required this.label,
    required this.value,
    required this.displayValue,
    required this.onDecrement,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: AppTheme.textSecondary,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 7),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              _CounterBtn(
                icon: Icons.remove_rounded,
                onTap: onDecrement,
              ),
              Expanded(
                child: Text(
                  displayValue,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              _CounterBtn(
                icon: Icons.add_rounded,
                onTap: onIncrement,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CounterBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _CounterBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: onTap != null ? Colors.white : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(9),
          boxShadow: onTap != null
              ? const [BoxShadow(color: Color(0x0A000000), blurRadius: 4)]
              : null,
        ),
        child: Icon(
          icon,
          size: 16,
          color: onTap != null ? AppTheme.textSecondary : const Color(0xFFCBD5E1),
        ),
      ),
    );
  }
}

class _FunctionItemTile extends StatelessWidget {
  final OrganizationFunctionModel function;
  final bool isSelected;
  final VoidCallback onTap;

  const _FunctionItemTile({
    required this.function,
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
                function.emoji,
                style: const TextStyle(fontSize: 20),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                function.name,
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
