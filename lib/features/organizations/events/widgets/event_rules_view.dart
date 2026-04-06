import 'package:convoquei_app/core/network/exceptions/api_exception.dart';
import 'package:convoquei_app/core/services/toast_feedback_service.dart';
import 'package:convoquei_app/core/services/user_feedback_service.dart';
import 'package:convoquei_app/features/organizations/events/models/enums/organization_event_call_mode.dart';
import 'package:convoquei_app/features/organizations/events/models/enums/organization_event_function_call_mode.dart';
import 'package:convoquei_app/features/organizations/events/models/enums/organization_event_status.dart';
import 'package:convoquei_app/features/organizations/events/models/organization_event_details_model.dart';
import 'package:convoquei_app/features/organizations/events/models/requests/update_organization_event_request.dart';
import 'package:convoquei_app/features/organizations/events/providers/find_event_details_by_id_provider.dart';
import 'package:convoquei_app/features/organizations/events/providers/update_event_provider.dart';
import 'package:convoquei_app/features/organizations/events/widgets/create_event_step2_team_scale.dart';
import 'package:convoquei_app/features/organizations/events/widgets/create_event_step3_final_rules.dart';
import 'package:convoquei_app/features/organizations/events/widgets/event_rules_read_view.dart';
import 'package:convoquei_app/features/organizations/shared/providers/selected_organization_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Aba "Regras do Evento" da tela de detalhes.
///
/// Exibe o formulário editável apenas quando [canManageEvents] = true
/// **e** o evento está com status SCHEDULED. Nos demais casos exibe
/// [EventRulesReadView] (somente-leitura).
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

  bool get _isDirty =>
      _step2 != _originalStep2 || _step3 != _originalStep3;

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

  void _setStep2(CreateEventStep2Data updated) {
    setState(() => _step2 = updated);
    widget.onDirtyChanged?.call(_isDirty);
  }

  void _setStep3(CreateEventStep3Data updated) {
    setState(() => _step3 = updated);
    widget.onDirtyChanged?.call(_isDirty);
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
      if (mounted) widget.onSavingChanged?.call(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final canEdit = widget.canManageEvents &&
        widget.details.status == OrganizationEventStatus.scheduled;

    if (!canEdit) {
      return EventRulesReadView(details: widget.details);
    }

    final canUseAutoSchedule =
        ref.watch(selectedOrganizationProvider)?.hasAutoScheduleFeature ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CreateEventStep2TeamScale(
          organizationId: widget.organizationId,
          canUseAutoSchedule: canUseAutoSchedule,
          data: _step2,
          onChanged: _setStep2,
        ),
        const SizedBox(height: 16),
        CreateEventStep3FinalRules(
          organizationId: widget.organizationId,
          canUseAutoSchedule: canUseAutoSchedule,
          defaultAssignmentMode: _step2.assignmentMode,
          data: _step3,
          onChanged: _setStep3,
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  // ── Conversores ──────────────────────────────────────────────────────────────

  static CreateEventStep2Data _step2FromDetails(
      OrganizationEventDetailsModel d) {
    final groups = d.calledGroups
        .map((g) => CreateEventGroupSelection(
              id: g.id,
              name: g.name,
              emoji: g.icon,
            ))
        .toList();
    return CreateEventStep2Data(
      assignmentMode: d.assignmentMode,
      callMode: d.callMode,
      selectedGroups:
          d.callMode == OrganizationEventCallMode.allOrganizationMembers
              ? const []
              : groups,
    );
  }

  static CreateEventStep3Data _step3FromDetails(
      OrganizationEventDetailsModel d) {
    final lock = d.availabilityLockBeforeStartInMinutes;
    final rules = d.calledFunctions
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
      deadlineDays: lock ~/ (24 * 60),
      deadlineHours: (lock % (24 * 60)) ~/ 60,
      deadlineMinutes: lock % 60,
      hasFunctionRules: rules.isNotEmpty,
      functionCallMode: d.functionCallMode ??
          OrganizationEventFunctionCallMode.allMembersWithFunctionLimits,
      functionRules: rules,
    );
  }
}
