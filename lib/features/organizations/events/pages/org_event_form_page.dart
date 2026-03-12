import 'package:convoquei_app/core/widgets/wizzard_page.dart';
import 'package:convoquei_app/features/organizations/events/widgets/create_event_step1_basic_info.dart';
import 'package:convoquei_app/features/organizations/events/widgets/create_event_step2_team_scale.dart';
import 'package:convoquei_app/features/organizations/events/widgets/create_event_step3_final_rules.dart';
import 'package:convoquei_app/features/organizations/shared/providers/selected_organization_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Wizard de formulário de evento — compartilhado entre criação e edição.
///
/// As únicas propriedades que diferem entre os dois fluxos são:
/// - [finishLabel]: label do botão final ("Criar Evento" / "Salvar Alterações")
/// - [onSave]: callback assíncrono que executa a ação (create / update)
///
/// Os dados iniciais são opcionais: em branco para criação, pré-preenchidos
/// a partir de [OrganizationEventDetailsModel] para edição.
class OrgEventFormPage extends ConsumerStatefulWidget {
  final String organizationId;

  // ── As únicas duas propriedades que mudam entre criar e editar ──────────
  final String finishLabel;
  final Future<bool> Function({
    required CreateEventStep1Data step1,
    required CreateEventStep2Data step2,
    required CreateEventStep3Data step3,
  }) onSave;

  // ── Dados iniciais (em branco por padrão, pré-preenchidos em edição) ────
  final CreateEventStep1Data initialStep1;
  final CreateEventStep2Data initialStep2;
  final CreateEventStep3Data initialStep3;

  const OrgEventFormPage({
    super.key,
    required this.organizationId,
    required this.finishLabel,
    required this.onSave,
    this.initialStep1 = const CreateEventStep1Data(),
    this.initialStep2 = const CreateEventStep2Data(),
    this.initialStep3 = const CreateEventStep3Data(),
  });

  @override
  ConsumerState<OrgEventFormPage> createState() => _OrgEventFormPageState();
}

class _OrgEventFormPageState extends ConsumerState<OrgEventFormPage> {
  late CreateEventStep1Data _step1;
  late CreateEventStep2Data _step2;
  late CreateEventStep3Data _step3;

  @override
  void initState() {
    super.initState();
    _step1 = widget.initialStep1;
    _step2 = widget.initialStep2;
    _step3 = widget.initialStep3;
  }

  Future<bool> _onFinish() => widget.onSave(
        step1: _step1,
        step2: _step2,
        step3: _step3,
      );

  @override
  Widget build(BuildContext context) {
    final org = ref.watch(selectedOrganizationProvider);
    final canUseAutoSchedule = org?.hasAutoScheduleFeature ?? false;

    return WizardPage(
      steps: const ['O Básico', 'Equipe e Escala', 'Regras Finais'],
      finishLabel: widget.finishLabel,
      onFinish: () => Navigator.of(context).pop(),
      stepConfigs: [
        WizardStepConfig(canAdvance: _step1.isValid),
        WizardStepConfig(canAdvance: _step2.isValid),
        WizardStepConfig(
          canAdvance: _step3.isValid,
          loadingLabel: '${widget.finishLabel}...',
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
