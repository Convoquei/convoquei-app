import 'package:convoquei_app/core/network/exceptions/api_exception.dart';
import 'package:convoquei_app/core/services/toast_feedback_service.dart';
import 'package:convoquei_app/core/services/user_feedback_service.dart';
import 'package:convoquei_app/core/theme/app_theme.dart';
import 'package:convoquei_app/features/organizations/events/models/enums/organization_event_assignment_mode.dart';
import 'package:convoquei_app/features/organizations/events/models/enums/organization_event_call_mode.dart';
import 'package:convoquei_app/features/organizations/events/models/enums/organization_event_function_call_mode.dart';
import 'package:convoquei_app/features/organizations/events/models/organization_event_details_model.dart';
import 'package:convoquei_app/features/organizations/events/models/requests/update_organization_event_request.dart';
import 'package:convoquei_app/features/organizations/events/providers/find_event_details_by_id_provider.dart';
import 'package:convoquei_app/features/organizations/events/providers/update_event_provider.dart';
import 'package:convoquei_app/features/organizations/events/widgets/assignment_mode_card.dart';
import 'package:convoquei_app/features/organizations/events/widgets/create_event_shared_widgets.dart';
import 'package:convoquei_app/features/organizations/events/models/event_form_step2_data.dart';
import 'package:convoquei_app/features/organizations/events/models/event_form_step3_data.dart';
import 'package:convoquei_app/features/organizations/events/widgets/event_add_group_button.dart';
import 'package:convoquei_app/features/organizations/events/widgets/event_auto_schedule_locked_info.dart';
import 'package:convoquei_app/features/organizations/events/widgets/event_scope_toggle.dart';
import 'package:convoquei_app/features/organizations/events/widgets/event_selected_groups_grid.dart';
import 'package:convoquei_app/features/organizations/events/widgets/function_item_tile.dart';
import 'package:convoquei_app/features/organizations/events/widgets/function_restriction_mode_option.dart';
import 'package:convoquei_app/features/organizations/events/widgets/function_rule_card.dart';
import 'package:convoquei_app/features/organizations/events/widgets/group_item_tile.dart';
import 'package:convoquei_app/features/organizations/members/models/organization_group_model.dart';
import 'package:convoquei_app/features/organizations/members/models/requests/find_all_organization_groups_request.dart';
import 'package:convoquei_app/features/organizations/members/models/requests/find_all_organization_functions_request.dart';
import 'package:convoquei_app/features/organizations/members/repositories/organization_groups_repository.dart';
import 'package:convoquei_app/features/organizations/members/repositories/organization_functions_repository.dart';
import 'package:convoquei_app/features/organizations/shared/providers/selected_organization_provider.dart';
import 'package:convoquei_app/core/widgets/modals/multi_select_modal.dart';
import 'package:convoquei_app/features/organizations/members/models/organization_function_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Aba "Regras do Evento" da tela de detalhes.
///
/// Em modo de leitura (canManageEvents = false): exibe as configurações em
/// modo somente-leitura.
/// Em modo de edição (canManageEvents = true): exibe os mesmos componentes
/// interativos usados na criação do evento, com botão "Salvar Regras".
class EventRulesView extends ConsumerStatefulWidget {
  final String organizationId;
  final bool canManageEvents;
  final OrganizationEventDetailsModel details;
  final ValueChanged<bool>? onDirtyChanged;
  final ValueChanged<bool>? onSavingChanged;

  const EventRulesView({
    super.key,
    required this.organizationId,
    required this.canManageEvents,
    required this.details,
    this.onDirtyChanged,
    this.onSavingChanged,
  });

  @override
  ConsumerState<EventRulesView> createState() => EventRulesViewState();
}

class EventRulesViewState extends ConsumerState<EventRulesView> {
  late CreateEventStep2Data _step2;
  late CreateEventStep2Data _originalStep2;
  late CreateEventStep3Data _step3;
  late CreateEventStep3Data _originalStep3;
  bool _saving = false;

  bool get _isDirty => _step2 != _originalStep2 || _step3 != _originalStep3;

  void _setStep2(CreateEventStep2Data updated) {
    setState(() => _step2 = updated);
    widget.onDirtyChanged?.call(_isDirty);
  }

  void _setStep3(CreateEventStep3Data updated) {
    setState(() => _step3 = updated);
    widget.onDirtyChanged?.call(_isDirty);
  }

  @override
  void initState() {
    super.initState();
    _step2 = _originalStep2 = _step2FromDetails(widget.details);
    _step3 = _originalStep3 = _step3FromDetails(widget.details);
  }

  @override
  void didUpdateWidget(EventRulesView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.details != widget.details) {
      setState(() {
        _step2 = _originalStep2 = _step2FromDetails(widget.details);
        _step3 = _originalStep3 = _step3FromDetails(widget.details);
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) widget.onDirtyChanged?.call(false);
      });
    }
  }

  static CreateEventStep2Data _step2FromDetails(OrganizationEventDetailsModel d) {
    final selectedGroups = d.calledGroups
        .map((g) => CreateEventGroupSelection(id: g.id, name: g.name, emoji: g.icon))
        .toList();
    return CreateEventStep2Data(
      assignmentMode: d.assignmentMode,
      callMode: d.callMode,
      selectedGroups:
          d.callMode == OrganizationEventCallMode.allOrganizationMembers
              ? const []
              : selectedGroups,
    );
  }

  static CreateEventStep3Data _step3FromDetails(OrganizationEventDetailsModel d) {
    final lockMinutes = d.availabilityLockBeforeStartInMinutes;
    final days = lockMinutes ~/ (24 * 60);
    final hours = (lockMinutes % (24 * 60)) ~/ 60;
    final minutes = lockMinutes % 60;
    final functionRules = d.calledFunctions
        .map((fn) => FunctionRuleData(
              functionId: fn.functionId,
              name: fn.functionName,
              emoji: fn.icon,
              min: fn.minMembers,
              max: fn.maxMembers,
              assignmentMode: fn.assignmentMode,
            ))
        .toList();
    return CreateEventStep3Data(
      deadlineDays: days,
      deadlineHours: hours,
      deadlineMinutes: minutes,
      hasFunctionRules: functionRules.isNotEmpty,
      functionCallMode: d.functionCallMode ??
          OrganizationEventFunctionCallMode.allMembersWithFunctionLimits,
      functionRules: functionRules,
    );
  }

  Future<void> _showAddGroupSheet() async {
    await MultiSelectModal.show<OrganizationGroupModel>(
      context,
      title: 'Selecionar Grupos',
      fetcher: (r) async {
        final repo = r.read(organizationGroupsRepositoryProvider);
        final result = await repo.findAllGroups(
          widget.organizationId,
          FindAllOrganizationGroupsRequest(page: 0, size: 100),
        );
        return result.items;
      },
      idExtractor: (g) => g.id,
      initialSelectedIds: _step2.selectedGroups.map((g) => g.id).toSet(),
      itemBuilder: (g, isSelected, onTap) =>
          GroupItemTile(group: g, isSelected: isSelected, onTap: onTap),
      onSave: (selectedIds) async {
        final repo = ref.read(organizationGroupsRepositoryProvider);
        final result = await repo.findAllGroups(
          widget.organizationId,
          FindAllOrganizationGroupsRequest(page: 0, size: 100),
        );
        final mapped = result.items
            .where((g) => selectedIds.contains(g.id))
            .map((g) => CreateEventGroupSelection(id: g.id, name: g.name, emoji: g.emoji))
            .toList();
        if (mounted) _setStep2(_step2.copyWith(selectedGroups: mapped));
      },
    );
  }

  Future<void> _showAddFunctionSheet() async {
    final alreadyAdded = _step3.functionRules.map((r) => r.functionId).toSet();
    await MultiSelectModal.show<OrganizationFunctionModel>(
      context,
      title: 'Selecionar Funções',
      fetcher: (r) async {
        final repo = r.read(organizationFunctionsRepositoryProvider);
        final result = await repo.findAllFunctions(
          widget.organizationId,
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
          widget.organizationId,
          FindAllOrganizationFunctionsRequest(page: 0, size: 100),
        );
        final existing = {for (final r in _step3.functionRules) r.functionId: r};
        final merged = result.items
            .where((fn) => selectedIds.contains(fn.id))
            .map((fn) =>
                existing[fn.id] ??
                FunctionRuleData(
                  functionId: fn.id,
                  name: fn.name,
                  emoji: fn.emoji,
                  assignmentMode: _step2.assignmentMode,
                ))
            .toList();
        if (mounted) _setStep3(_step3.copyWith(functionRules: merged));
      },
    );
  }

  void reset() {
    setState(() {
      _step2 = _originalStep2;
      _step3 = _originalStep3;
    });
    widget.onDirtyChanged?.call(false);
  }

  Future<void> save() async {
    final confirmed = await UserFeedbackService.confirm(
      context,
      title: 'Salvar Regras do Evento',
      message:
          'Tem certeza que deseja salvar as alterações? Isso pode resultar na inclusão ou remoção de participantes do evento.',
      confirmLabel: 'Salvar',
      cancelLabel: 'Cancelar',
    );
    if (!confirmed) return;

    widget.onSavingChanged?.call(true);
    setState(() => _saving = true);
    try {
      final request = UpdateOrganizationEventRequest.fromSteps(
        name: widget.details.name,
        description: widget.details.description,
        location: widget.details.location,
        startDate: widget.details.startAt,
        endDate: widget.details.endAt,
        step2: _step2,
        step3: _step3,
      );
      await ref.read(updateEventProvider.notifier).save(
            organizationId: widget.organizationId,
            eventId: widget.details.id,
            request: request,
          );
      if (!mounted) return;
      setState(() {
        _originalStep2 = _step2;
        _originalStep3 = _step3;
      });
      widget.onDirtyChanged?.call(false);
      ref.invalidate(findEventDetailsByIdProvider(
        organizationId: widget.organizationId,
        eventId: widget.details.id,
      ));
      ToastFeedbackService.showToast(
          context, 'Regras atualizadas com sucesso!', ToastType.success);
    } on ApiException catch (e) {
      if (!mounted) return;
      ToastFeedbackService.showToast(context, e.userMessage, ToastType.error);
    } finally {
      if (mounted) {
        setState(() => _saving = false);
        widget.onSavingChanged?.call(false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final org = ref.watch(selectedOrganizationProvider);
    final canUseAutoSchedule = org?.hasAutoScheduleFeature ?? false;

    if (!widget.canManageEvents) {
      return _ReadOnlyRulesView(details: widget.details);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Regra de aprovação (editável) ──────────────────────────────────
        StepCard(
          children: [
            const FieldLabel(label: 'Regra de Aprovação Padrão'),
            AssignmentModeCard(
              mode: OrganizationEventAssignmentMode.manual,
              selected:
                  _step2.assignmentMode == OrganizationEventAssignmentMode.manual,
              locked: false,
              title: 'Aprovação Manual',
              description:
                  'O membro diz que está disponível, mas você decide quem entra e aprova a escala final.',
              icon: Icons.shield_rounded,
              iconColor: AppTheme.primaryColor,
              onTap: () => _setStep2(_step2.copyWith(
                  assignmentMode: OrganizationEventAssignmentMode.manual)),
            ),
            AssignmentModeCard(
              mode: OrganizationEventAssignmentMode.automatic,
              selected:
                  _step2.assignmentMode == OrganizationEventAssignmentMode.automatic,
              locked: !canUseAutoSchedule,
              title: 'Escala Automática',
              description:
                  'Os membros que aceitarem a convocação serão escalados automaticamente, e a escala será encerrada no tempo configurado.',
              icon: Icons.rocket_launch_rounded,
              iconColor: AppTheme.successColor,
              onTap: () => _setStep2(_step2.copyWith(
                  assignmentMode: OrganizationEventAssignmentMode.automatic)),
            ),
            if (!canUseAutoSchedule) const EventAutoScheduleLockedInfo(),
          ],
        ),
        const SizedBox(height: 16),

        // ── Escopo de convocação (editável) ────────────────────────────────
        StepCard(
          children: [
            const FieldLabel(label: 'Quem foi convocado?'),
            EventScopeToggle(
              callMode: _step2.callMode,
              onChanged: (v) => _setStep2(_step2.copyWith(callMode: v)),
            ),
            if (_step2.callMode ==
                OrganizationEventCallMode.onlySpecifiedGroupMembers) ...[
              EventSelectedGroupsGrid(
                selected: _step2.selectedGroups,
                onRemove: (group) {
                  final updated = _step2.selectedGroups
                      .where((g) => g.id != group.id)
                      .toList();
                  _setStep2(_step2.copyWith(selectedGroups: updated));
                },
              ),
              EventAddGroupButton(onTap: _showAddGroupSheet),
            ],
          ],
        ),
        const SizedBox(height: 16),

        // ── Bloqueio de disponibilidade (editável) ─────────────────────────
        StepCard(
          children: [
            Row(
              children: [
                const Icon(Icons.hourglass_top_rounded,
                    color: AppTheme.warningColor, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Bloqueio de Disponibilidade',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
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
              'Com quanto tempo antes do evento a disponibilidade dos membros deve ser bloqueada?',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Opacity(
              opacity: canUseAutoSchedule ? 1.0 : 0.45,
              child: IgnorePointer(
                ignoring: !canUseAutoSchedule,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      NumberSpinner(
                        value: _step3.deadlineDays,
                        label: 'Dias',
                        min: 0,
                        max: 30,
                        onChanged: (v) =>
                            _setStep3(_step3.copyWith(deadlineDays: v)),
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.only(bottom: 20, left: 6, right: 6),
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
                        value: _step3.deadlineHours,
                        label: 'Horas',
                        min: 0,
                        max: 23,
                        onChanged: (v) =>
                            _setStep3(_step3.copyWith(deadlineHours: v)),
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.only(bottom: 20, left: 6, right: 6),
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
                        value: _step3.deadlineMinutes,
                        label: 'Minutos',
                        min: 0,
                        max: 59,
                        onChanged: (v) =>
                            _setStep3(_step3.copyWith(deadlineMinutes: v)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // ── Regras por Função (editável) ───────────────────────────────────
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
                  value: _step3.hasFunctionRules,
                  onChanged: (v) =>
                      _setStep3(_step3.copyWith(hasFunctionRules: v)),
                ),
              ],
            ),
            if (_step3.hasFunctionRules) ...[
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
                    FunctionRestrictionModeOption(
                      label: 'Apenas as funções abaixo',
                      description:
                          'Membros sem estas funções serão ignorados e não receberão a convocação.',
                      selected: _step3.functionCallMode ==
                          OrganizationEventFunctionCallMode
                              .onlyMembersWithListedFunctions,
                      onTap: () => _setStep3(_step3.copyWith(
                          functionCallMode: OrganizationEventFunctionCallMode
                              .onlyMembersWithListedFunctions)),
                    ),
                    const SizedBox(height: 10),
                    FunctionRestrictionModeOption(
                      label: 'Todos os convocados',
                      description:
                          'Todos serão convocados, mas as regras abaixo se aplicam às funções específicas.',
                      selected: _step3.functionCallMode ==
                          OrganizationEventFunctionCallMode.allMembersWithFunctionLimits,
                      onTap: () => _setStep3(_step3.copyWith(
                          functionCallMode: OrganizationEventFunctionCallMode
                              .allMembersWithFunctionLimits)),
                    ),
                  ],
                ),
              ),
              for (int i = 0; i < _step3.functionRules.length; i++)
                FunctionRuleCard(
                  rule: _step3.functionRules[i],
                  canUseAutoSchedule: canUseAutoSchedule,
                  onChanged: (updated) {
                    final rules = [..._step3.functionRules];
                    rules[i] = updated;
                    _setStep3(_step3.copyWith(functionRules: rules));
                  },
                  onRemove: () {
                    final rules = [..._step3.functionRules]..removeAt(i);
                    _setStep3(_step3.copyWith(functionRules: rules));
                  },
                ),
              GestureDetector(
                onTap: _showAddFunctionSheet,
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
        const SizedBox(height: 24),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// READ-ONLY VIEW
// ─────────────────────────────────────────────────────────────────────────────

class _ReadOnlyRulesView extends StatelessWidget {
  final OrganizationEventDetailsModel details;

  const _ReadOnlyRulesView({required this.details});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Regra de aprovação ──────────────────────────────────────────────
        StepCard(
          children: [
            const FieldLabel(label: 'Regra de Aprovação Padrão'),
            AssignmentModeCard(
              mode: OrganizationEventAssignmentMode.manual,
              selected:
                  details.assignmentMode == OrganizationEventAssignmentMode.manual,
              title: 'Aprovação Manual',
              description:
                  'O membro diz que está disponível, mas você decide quem entra e aprova a escala final.',
              icon: Icons.shield_rounded,
              iconColor: AppTheme.primaryColor,
            ),
            AssignmentModeCard(
              mode: OrganizationEventAssignmentMode.automatic,
              selected:
                  details.assignmentMode ==
                  OrganizationEventAssignmentMode.automatic,
              title: 'Escala Automática',
              description:
                  'Os membros que aceitarem a convocação serão escalados automaticamente, e a escala será encerrada no tempo configurado.',
              icon: Icons.rocket_launch_rounded,
              iconColor: AppTheme.successColor,
            ),
          ],
        ),
        const SizedBox(height: 16),

        // ── Escopo de convocação ────────────────────────────────────────────
        StepCard(
          children: [
            const FieldLabel(label: 'Quem foi convocado?'),
            _ScopeDisplay(
              callMode: details.callMode,
              calledGroups: details.calledGroups,
            ),
          ],
        ),
        const SizedBox(height: 16),

        // ── Bloqueio de disponibilidade ─────────────────────────────────────
        StepCard(
          children: [
            Row(
              children: [
                const Icon(Icons.hourglass_top_rounded,
                    color: AppTheme.warningColor, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Bloqueio de Disponibilidade',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
              ],
            ),
            _DeadlineDisplay(
              minutes: details.availabilityLockBeforeStartInMinutes,
            ),
          ],
        ),

        // ── Regras por função ───────────────────────────────────────────────
        if (details.calledFunctions.isNotEmpty) ...[
          const SizedBox(height: 16),
          StepCard(
            children: [
              const FieldLabel(label: 'Regras por Função'),
              if (details.functionCallMode != null)
                _FunctionCallModeInfo(mode: details.functionCallMode!),
              ...details.calledFunctions
                  .map((fn) => _FunctionRuleDisplayCard(function: fn)),
            ],
          ),
        ],
        const SizedBox(height: 24),
      ],
    );
  }
}

// READ-ONLY HELPERS
// ─────────────────────────────────────────────────────────────────────────────

class _ScopeDisplay extends StatelessWidget {
  final OrganizationEventCallMode callMode;
  final List<OrganizationEventCalledGroupModel> calledGroups;

  const _ScopeDisplay({required this.callMode, required this.calledGroups});

  @override
  Widget build(BuildContext context) {
    if (callMode == OrganizationEventCallMode.allOrganizationMembers) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            const Icon(Icons.groups_rounded, size: 18, color: AppTheme.primaryColor),
            const SizedBox(width: 10),
            Text('Toda a organização',
                style: Theme.of(context).textTheme.labelMedium),
          ],
        ),
      );
    }
    if (calledGroups.isEmpty) {
      return Text('Nenhum grupo especificado.',
          style: Theme.of(context).textTheme.bodySmall);
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
      itemCount: calledGroups.length,
      itemBuilder: (_, i) {
        final group = calledGroups[i];
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              Text(group.icon, style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  group.name,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DeadlineDisplay extends StatelessWidget {
  final int minutes;

  const _DeadlineDisplay({required this.minutes});

  String get _formatted {
    if (minutes == 0) return 'Sem bloqueio configurado';
    final days = minutes ~/ (24 * 60);
    final hours = (minutes % (24 * 60)) ~/ 60;
    final mins = minutes % 60;
    final parts = <String>[];
    if (days > 0) parts.add('$days ${days == 1 ? 'dia' : 'dias'}');
    if (hours > 0) parts.add('$hours ${hours == 1 ? 'hora' : 'horas'}');
    if (mins > 0) parts.add('$mins min');
    return 'Bloqueia ${parts.join(', ')} antes do evento';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          const Icon(Icons.access_time_rounded,
              size: 16, color: AppTheme.warningColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(_formatted, style: Theme.of(context).textTheme.labelMedium),
          ),
        ],
      ),
    );
  }
}

class _FunctionCallModeInfo extends StatelessWidget {
  final OrganizationEventFunctionCallMode mode;

  const _FunctionCallModeInfo({required this.mode});

  @override
  Widget build(BuildContext context) {
    final label =
        mode == OrganizationEventFunctionCallMode.onlyMembersWithListedFunctions
            ? 'Apenas as funções abaixo serão convocadas para o evento.'
            : 'Todos os convocados participam, com limites aplicados por função.';
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Text(label, style: Theme.of(context).textTheme.bodySmall),
    );
  }
}

class _FunctionRuleDisplayCard extends StatelessWidget {
  final OrganizationEventCalledFunctionDetailsModel function;

  const _FunctionRuleDisplayCard({required this.function});

  @override
  Widget build(BuildContext context) {
    final maxLabel = function.maxMembers == null ? '∞' : '${function.maxMembers}';
    final modeLabel =
        function.assignmentMode == OrganizationEventAssignmentMode.manual
            ? 'Manual'
            : 'Automático';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
            child: Row(
              children: [
                Text(function.icon, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(function.functionName,
                      style: Theme.of(context).textTheme.titleSmall),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    modeLabel,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            color: const Color(0xFFF8FAFC),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                Expanded(
                    child: _MinMaxLabel(label: 'Mínimo', value: '${function.minMembers}')),
                const SizedBox(width: 12),
                Expanded(child: _MinMaxLabel(label: 'Máximo', value: maxLabel)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MinMaxLabel extends StatelessWidget {
  final String label;
  final String value;

  const _MinMaxLabel({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: Theme.of(context).textTheme.labelSmall),
        Text(value, style: Theme.of(context).textTheme.titleSmall),
      ],
    );
  }
}
