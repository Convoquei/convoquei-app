import 'package:convoquei_app/core/network/exceptions/api_exception.dart';
import 'package:convoquei_app/core/services/toast_feedback_service.dart';
import 'package:convoquei_app/core/widgets/app_loading_info.dart';
import 'package:convoquei_app/core/widgets/app_loading_screen.dart';
import 'package:convoquei_app/core/widgets/error_retry_state.dart';
import 'package:convoquei_app/features/organizations/events/models/enums/organization_event_call_mode.dart';
import 'package:convoquei_app/features/organizations/events/models/enums/organization_event_function_call_mode.dart';
import 'package:convoquei_app/features/organizations/events/models/enums/organization_event_status.dart';
import 'package:convoquei_app/features/organizations/events/models/organization_event_details_model.dart';
import 'package:convoquei_app/features/organizations/events/models/requests/update_organization_event_request.dart';
import 'package:convoquei_app/features/organizations/events/pages/org_event_form_page.dart';
import 'package:convoquei_app/features/organizations/events/providers/find_event_details_by_id_provider.dart';
import 'package:convoquei_app/features/organizations/events/providers/update_event_provider.dart';
import 'package:convoquei_app/features/organizations/events/widgets/create_event_step1_basic_info.dart';
import 'package:convoquei_app/features/organizations/events/widgets/create_event_step2_team_scale.dart';
import 'package:convoquei_app/features/organizations/events/widgets/create_event_step3_final_rules.dart';
import 'package:convoquei_app/features/organizations/shared/models/enums/organization_permission.dart';
import 'package:convoquei_app/features/organizations/shared/providers/organization_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OrgEditEventPage extends ConsumerWidget {
  final String organizationId;
  final String eventId;

  const OrgEditEventPage({
    super.key,
    required this.organizationId,
    required this.eventId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailsAsync = ref.watch(
      findEventDetailsByIdProvider(
        organizationId: organizationId,
        eventId: eventId,
      ),
    );

    final canManageEvents = ref
            .watch(currentUserMembershipOrganizationProvider(organizationId))
            .asData
            ?.value
            .hasPermission(OrganizationPermissionEnum.manageEvents) ??
        false;

    return detailsAsync.when(
      loading: () => const AppLoadingScreen(
        content: AppLoadingInfo(
          label: 'Carregando evento...',
          description: 'Buscando dados para edição',
        ),
        skeleton: AppLoadingSkeleton.details,
      ),
      error: (_, _) => Scaffold(
        appBar: AppBar(),
        body: ErrorRetryState(
          icon: Icons.event_busy_rounded,
          message: 'Não foi possível carregar o evento',
          description: 'Verifique sua conexão e tente novamente.',
          onRetry: () => ref.invalidate(
            findEventDetailsByIdProvider(
              organizationId: organizationId,
              eventId: eventId,
            ),
          ),
        ),
      ),
      data: (details) {
        final readOnly = !canManageEvents ||
            details.status != OrganizationEventStatus.scheduled;
        final readOnlyMessage = _readOnlyMessage(details.status, canManageEvents);

        return OrgEventFormPage(
          organizationId: organizationId,
          title: 'Editar Evento',
          finishLabel: 'Salvar Alterações',
          readOnly: readOnly,
          readOnlyMessage: readOnlyMessage,
          initialStep1: _step1FromDetails(details),
          initialStep2: _step2FromDetails(details),
          initialStep3: _step3FromDetails(details),
          onSave: ({required step1, required step2, required step3}) async {
            final request = UpdateOrganizationEventRequest.fromSteps(
              name: step1.name,
              description: step1.description,
              location: step1.location,
              startDate: step1.startAt!,
              endDate: step1.endAt!,
              step2: step2,
              step3: step3,
            );

            try {
              await ref.read(updateEventProvider.notifier).save(
                    organizationId: organizationId,
                    eventId: eventId,
                    request: request,
                  );

              if (!context.mounted) return false;

              ref.invalidate(
                findEventDetailsByIdProvider(
                  organizationId: organizationId,
                  eventId: eventId,
                ),
              );

              ToastFeedbackService.showToast(
                context,
                'Evento atualizado com sucesso!',
                ToastType.success,
              );

              return true;
            } on ApiException catch (e) {
              if (!context.mounted) return false;
              ToastFeedbackService.showToast(
                  context, e.userMessage, ToastType.error);
              return false;
            }
          },
        );
      },
    );
  }

  static String? _readOnlyMessage(
      OrganizationEventStatus status, bool canManageEvents) {
    if (!canManageEvents) {
      return 'Você não tem permissão para editar este evento.';
    }
    return switch (status) {
      OrganizationEventStatus.scheduled => null,
      OrganizationEventStatus.inProgress =>
        'Não é possível editar um evento em andamento.',
      OrganizationEventStatus.completed =>
        'Não é possível editar um evento já finalizado.',
      OrganizationEventStatus.canceled =>
        'Não é possível editar um evento cancelado.',
    };
  }

  // ── Conversão OrganizationEventDetailsModel → step data ──────────────────

  static CreateEventStep1Data _step1FromDetails(OrganizationEventDetailsModel d) {
    return CreateEventStep1Data(
      name: d.name,
      description: d.description,
      location: d.location,
      startAt: d.startAt,
      endAt: d.endAt,
    );
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
    final lock = d.availabilityLockBeforeStartInMinutes;
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
      deadlineDays: lock ~/ (24 * 60),
      deadlineHours: (lock % (24 * 60)) ~/ 60,
      deadlineMinutes: lock % 60,
      hasFunctionRules: functionRules.isNotEmpty,
      functionCallMode: d.functionCallMode ??
          OrganizationEventFunctionCallMode.allMembersWithFunctionLimits,
      functionRules: functionRules,
    );
  }
}
