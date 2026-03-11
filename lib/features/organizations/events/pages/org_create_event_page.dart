import 'package:convoquei_app/core/network/exceptions/api_exception.dart';
import 'package:convoquei_app/core/services/toast_feedback_service.dart';
import 'package:convoquei_app/core/widgets/wizzard_page.dart';
import 'package:convoquei_app/features/organizations/events/models/requests/create_organization_event_request.dart';
import 'package:convoquei_app/features/organizations/events/providers/create_event_provider.dart';
import 'package:convoquei_app/features/organizations/events/providers/find_all_events_membership_provider.dart';
import 'package:convoquei_app/features/organizations/events/models/events_filter_model.dart';
import 'package:convoquei_app/features/organizations/events/widgets/create_event_step1_basic_info.dart';
import 'package:convoquei_app/features/organizations/events/widgets/create_event_step2_team_scale.dart';
import 'package:convoquei_app/features/organizations/events/widgets/create_event_step3_final_rules.dart';
import 'package:convoquei_app/features/organizations/shared/providers/selected_organization_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OrgCreateEventPage extends ConsumerStatefulWidget {
  final String organizationId;

  const OrgCreateEventPage({super.key, required this.organizationId});

  @override
  ConsumerState<OrgCreateEventPage> createState() => _OrgCreateEventPageState();
}

class _OrgCreateEventPageState extends ConsumerState<OrgCreateEventPage> {
  var _step1 = const CreateEventStep1Data();
  var _step2 = const CreateEventStep2Data();
  var _step3 = const CreateEventStep3Data();

  Future<bool> _onFinish() async {
    final request = CreateOrganizationEventRequest.fromSteps(
      name: _step1.name,
      description: _step1.description,
      location: _step1.location,
      startDate: _step1.startAt!,
      endDate: _step1.endAt!,
      step2: _step2,
      step3: _step3,
    );

    try {
      await ref.read(createEventProvider.notifier).create(
            organizationId: widget.organizationId,
            request: request,
          );

      if (!mounted) return false;

      // Reinicia a listagem para refletir o novo evento.
      ref.read(eventMembershipProvider.notifier).reset(
            widget.organizationId,
            const EventsFilter(),
          );

      ToastFeedbackService.showToast(
        context,
        'Evento criado com sucesso!',
        ToastType.success,
      );

      return true;
    } on ApiException catch (e) {
      if (!mounted) return false;

      ToastFeedbackService.showToast(
        context,
        e.userMessage,
        ToastType.error,
      );

      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final org = ref.watch(selectedOrganizationProvider);
    final canUseAutoSchedule = org?.hasAutoScheduleFeature ?? false;

    return WizardPage(
      steps: const ['O Básico', 'Equipe e Escala', 'Regras Finais'],
      finishLabel: 'Criar Evento',
      onFinish: () => Navigator.of(context).pop(),
      stepConfigs: [
        WizardStepConfig(canAdvance: _step1.isValid),
        WizardStepConfig(canAdvance: _step2.isValid),
        WizardStepConfig(
          canAdvance: _step3.isValid,
          loadingLabel: 'Criando evento...',
          onNext: _onFinish,
        ),
      ],
      children: [
        CreateEventStep1BasicInfo(
          data: _step1,
          onChanged: (d) => setState(() => _step1 = d),
        ),
        CreateEventStep2TeamScale(
          organizationId: widget.organizationId,
          canUseAutoSchedule: canUseAutoSchedule,
          data: _step2,
          onChanged: (d) => setState(() => _step2 = d),
        ),
        CreateEventStep3FinalRules(
          organizationId: widget.organizationId,
          canUseAutoSchedule: canUseAutoSchedule,
          defaultAssignmentMode: _step2.assignmentMode,
          data: _step3,
          onChanged: (d) => setState(() => _step3 = d),
        ),
      ],
    );
  }
}
