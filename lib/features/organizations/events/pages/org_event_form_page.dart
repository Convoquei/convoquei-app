import 'package:convoquei_app/core/network/exceptions/api_exception.dart';
import 'package:convoquei_app/core/services/toast_feedback_service.dart';
import 'package:convoquei_app/core/theme/app_theme.dart';
import 'package:convoquei_app/core/widgets/action_button.dart';
import 'package:convoquei_app/features/organizations/events/widgets/create_event_step1_basic_info.dart';
import 'package:convoquei_app/features/organizations/events/widgets/create_event_step2_team_scale.dart';
import 'package:convoquei_app/features/organizations/events/widgets/create_event_step3_final_rules.dart';
import 'package:convoquei_app/features/organizations/shared/providers/selected_organization_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Formulário de evento — compartilhado entre criação e edição.
///
/// Exibe todos os campos em uma página scrollável organizada em três seções.
/// Quando [readOnly] = true, os campos ficam não-interativos e
/// [readOnlyMessage] aparece em um banner de aviso no topo.
class OrgEventFormPage extends ConsumerStatefulWidget {
  final String organizationId;
  final String title;
  final String finishLabel;
  final Future<bool> Function({
    required CreateEventStep1Data step1,
    required CreateEventStep2Data step2,
    required CreateEventStep3Data step3,
  })
  onSave;
  final CreateEventStep1Data initialStep1;
  final CreateEventStep2Data initialStep2;
  final CreateEventStep3Data initialStep3;
  final bool readOnly;
  final String? readOnlyMessage;

  const OrgEventFormPage({
    super.key,
    required this.organizationId,
    required this.title,
    required this.finishLabel,
    required this.onSave,
    this.initialStep1 = const CreateEventStep1Data(),
    this.initialStep2 = const CreateEventStep2Data(),
    this.initialStep3 = const CreateEventStep3Data(),
    this.readOnly = false,
    this.readOnlyMessage,
  });

  @override
  ConsumerState<OrgEventFormPage> createState() => _OrgEventFormPageState();
}

class _OrgEventFormPageState extends ConsumerState<OrgEventFormPage> {
  late CreateEventStep1Data _step1;
  late CreateEventStep2Data _step2;
  late CreateEventStep3Data _step3;
  bool _isLoading = false;

  bool get _canSave =>
      !widget.readOnly &&
      _step1.isValid &&
      _step2.isValid &&
      _step3.isValid &&
      !_isLoading;

  @override
  void initState() {
    super.initState();
    _step1 = widget.initialStep1;
    _step2 = widget.initialStep2;
    _step3 = widget.initialStep3;
  }

  Future<void> _submit() async {
    if (!_canSave) return;
    setState(() => _isLoading = true);
    try {
      final success = await widget.onSave(
        step1: _step1,
        step2: _step2,
        step3: _step3,
      );
      if (success && mounted) Navigator.of(context).pop();
    } on ApiException catch (e) {
      if (mounted) {
        ToastFeedbackService.showToast(context, e.userMessage, ToastType.error);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final canUseAutoSchedule =
        ref.watch(selectedOrganizationProvider)?.hasAutoScheduleFeature ??
        false;

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (widget.readOnly && widget.readOnlyMessage != null) ...[
                    _ReadOnlyBanner(message: widget.readOnlyMessage!),
                    const SizedBox(height: 16),
                  ],
                  IgnorePointer(
                    ignoring: widget.readOnly,
                    child: Opacity(
                      opacity: widget.readOnly ? 0.55 : 1.0,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _SectionHeader(
                            icon: Icons.info_outline_rounded,
                            label: 'Informações Básicas',
                          ),
                          const SizedBox(height: 12),
                          CreateEventStep1BasicInfo(
                            data: _step1,
                            onChanged: (d) => setState(() => _step1 = d),
                          ),
                          const SizedBox(height: 28),
                          _SectionHeader(
                            icon: Icons.groups_rounded,
                            label: 'Equipe e Convocação',
                          ),
                          const SizedBox(height: 12),
                          CreateEventStep2TeamScale(
                            organizationId: widget.organizationId,
                            canUseAutoSchedule: canUseAutoSchedule,
                            data: _step2,
                            onChanged: (d) => setState(() => _step2 = d),
                          ),
                          const SizedBox(height: 28),
                          _SectionHeader(
                            icon: Icons.tune_rounded,
                            label: 'Regras Avançadas',
                          ),
                          const SizedBox(height: 12),
                          CreateEventStep3FinalRules(
                            organizationId: widget.organizationId,
                            canUseAutoSchedule: canUseAutoSchedule,
                            defaultAssignmentMode: _step2.assignmentMode,
                            data: _step3,
                            onChanged: (d) => setState(() => _step3 = d),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (!widget.readOnly)
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: ActionButton(
                  label: widget.finishLabel,
                  icon: Icons.check_rounded,
                  isLoading: _isLoading,
                  onPressed: _canSave ? _submit : null,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Read-Only Banner ─────────────────────────────────────────────────────────

class _ReadOnlyBanner extends StatelessWidget {
  final String message;

  const _ReadOnlyBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFED7AA)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.lock_outline_rounded,
            size: 16,
            color: AppTheme.warningColor,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.secondaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Section Header ───────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SectionHeader({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.primaryColor),
        const SizedBox(width: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(width: 10),
        const Expanded(child: Divider()),
      ],
    );
  }
}
