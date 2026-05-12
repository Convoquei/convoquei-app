import 'package:convoquei_app/core/services/toast_feedback_service.dart';
import 'package:convoquei_app/core/theme/app_theme.dart';
import 'package:convoquei_app/core/widgets/action_button.dart';
import 'package:convoquei_app/core/widgets/base_modal_stateful_widget.dart';
import 'package:convoquei_app/core/widgets/header_modal_title_subtitle.dart';
import 'package:convoquei_app/features/home/widgets/action_tile.dart';
import 'package:convoquei_app/features/organizations/events/models/enums/organization_event_membership_availability_status.dart';
import 'package:convoquei_app/features/organizations/events/models/enums/organization_event_membership_status.dart';
import 'package:convoquei_app/features/organizations/events/models/organization_event_details_model.dart';
import 'package:convoquei_app/features/organizations/events/providers/manage_participant_provider.dart';
import 'package:convoquei_app/features/organizations/events/providers/find_event_details_by_id_provider.dart';
import 'package:convoquei_app/features/organizations/events/widgets/event_participant_tile.dart';
import 'package:convoquei_app/features/organizations/shared/widgets/expanded_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Aba "Pessoas" da tela de detalhes do evento.
///
/// Seções:
/// 1. Aguardando Escalação — [awaitingAssignment] ou [awaitingDraw]
/// 2. Escalados             — [assigned]
/// 3. Não Escalados         — [notAssigned] + disponíveis
/// 4. Não Confirmados       — não responderam (primeiro) + indisponíveis (final)
class EventParticipantsView extends ConsumerWidget {
  final String organizationId;
  final String eventId;
  final String currentMemberId;
  final bool canManageEvents;
  final List<OrganizationEventParticipantModel> participants;

  const EventParticipantsView({
    super.key,
    required this.organizationId,
    required this.eventId,
    required this.currentMemberId,
    required this.canManageEvents,
    required this.participants,
  });

  // ── Agrupamentos ─────────────────────────────────────────────────────────────

  List<OrganizationEventParticipantModel> get _awaitingAssignment =>
      participants
          .where((p) =>
              p.status == OrganizationEventMembershipStatus.awaitingAssignment ||
              p.status == OrganizationEventMembershipStatus.awaitingDraw)
          .toList();

  List<OrganizationEventParticipantModel> get _assigned => participants
      .where((p) => p.status == OrganizationEventMembershipStatus.assigned)
      .toList();

  List<OrganizationEventParticipantModel> get _notAssigned => participants
      .where((p) =>
          p.status == OrganizationEventMembershipStatus.notAssigned &&
          p.availabilityStatus ==
              OrganizationEventMembershipAvailabilityStatus.available)
      .toList();

  /// Não responderam primeiro, indisponíveis no final.
  List<OrganizationEventParticipantModel> get _semConfirmacao {
    final notAnswered = participants
        .where((p) =>
            p.availabilityStatus ==
            OrganizationEventMembershipAvailabilityStatus.notAnswered)
        .toList();
    final unavailable = participants
        .where((p) =>
            p.availabilityStatus ==
            OrganizationEventMembershipAvailabilityStatus.unavailable)
        .toList();
    return [...notAnswered, ...unavailable];
  }

  // ── Handlers ─────────────────────────────────────────────────────────────────

  void _handleApprove(BuildContext context, WidgetRef ref, String membershipId) async {
    try {
      await ref.read(manageParticipantProvider.notifier).approveAssignment(
            organizationId: organizationId,
            eventId: eventId,
            participantId: membershipId,
          );
      ref.invalidate(findEventDetailsByIdProvider(
          organizationId: organizationId, eventId: eventId));
    } catch (_) {
      if (!context.mounted) return;
      ToastFeedbackService.showToast(
          context, 'Não foi possível escalar o membro.', ToastType.error);
    }
  }

  void _handleReject(BuildContext context, WidgetRef ref, String membershipId) async {
    try {
      await ref.read(manageParticipantProvider.notifier).reject(
            organizationId: organizationId,
            eventId: eventId,
            membershipId: membershipId,
          );
      ref.invalidate(findEventDetailsByIdProvider(
          organizationId: organizationId, eventId: eventId));
    } catch (_) {
      if (!context.mounted) return;
      ToastFeedbackService.showToast(
          context, 'Não foi possível rejeitar o membro.', ToastType.error);
    }
  }

  void _handleRemove(BuildContext context, WidgetRef ref, String membershipId) async {
    try {
      await ref.read(manageParticipantProvider.notifier).removeAssignment(
            organizationId: organizationId,
            eventId: eventId,
            participantId: membershipId,
          );
      ref.invalidate(findEventDetailsByIdProvider(
          organizationId: organizationId, eventId: eventId));
    } catch (_) {
      if (!context.mounted) return;
      ToastFeedbackService.showToast(
          context, 'Não foi possível remover o membro da escala.', ToastType.error);
    }
  }

  void _handleAssign(BuildContext context, WidgetRef ref, String membershipId) async {
    try {
      await ref.read(manageParticipantProvider.notifier).assign(
            organizationId: organizationId,
            eventId: eventId,
            membershipId: membershipId,
          );
      ref.invalidate(findEventDetailsByIdProvider(
          organizationId: organizationId, eventId: eventId));
    } catch (_) {
      if (!context.mounted) return;
      ToastFeedbackService.showToast(
          context, 'Não foi possível escalar o membro.', ToastType.error);
    }
  }

  void _handleLeave(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(manageParticipantProvider.notifier).removeOwn(
            organizationId: organizationId,
            eventId: eventId,
          );
      ref.invalidate(findEventDetailsByIdProvider(
          organizationId: organizationId, eventId: eventId));
    } catch (_) {
      if (!context.mounted) return;
      ToastFeedbackService.showToast(
          context, 'Não foi possível sair da escala.', ToastType.error);
    }
  }

  void _handleNotify(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(manageParticipantProvider.notifier).notifyParticipants(
            organizationId: organizationId,
            eventId: eventId,
          );
      if (!context.mounted) return;
      ToastFeedbackService.showToast(
          context, 'Notificação enviada com sucesso!', ToastType.success);
    } catch (_) {
      if (!context.mounted) return;
      ToastFeedbackService.showToast(
          context, 'Não foi possível enviar a notificação.', ToastType.error);
    }
  }

  void _showAwaitingSheet(
      BuildContext context, WidgetRef ref, OrganizationEventParticipantModel p) {
    _ParticipantManageModal.show(
      context,
      participant: p,
      actions: [
        _ParticipantAction(
          icon: Icons.check_circle_rounded,
          label: 'Escalar membro',
          description: 'Confirmar disponibilidade e adicionar à escala',
          iconColor: AppTheme.successColor,
          iconBgColor: const Color(0xFFECFDF5),
          onTap: () => _handleApprove(context, ref, p.membershipId),
        ),
        _ParticipantAction(
          icon: Icons.cancel_rounded,
          label: 'Rejeitar membro',
          description: 'Remover da fila de disponíveis',
          destructive: true,
          onTap: () => _handleReject(context, ref, p.membershipId),
        ),
      ],
    );
  }

  void _showAssignedSheet(
      BuildContext context, WidgetRef ref, OrganizationEventParticipantModel p) {
    _ParticipantManageModal.show(
      context,
      participant: p,
      actions: [
        _ParticipantAction(
          icon: Icons.person_remove_rounded,
          label: 'Remover da escala',
          description: 'Desfazer a escalação deste membro',
          destructive: true,
          onTap: () => _handleRemove(context, ref, p.membershipId),
        ),
      ],
    );
  }

  void _showNotAssignedSheet(
      BuildContext context, WidgetRef ref, OrganizationEventParticipantModel p) {
    _ParticipantManageModal.show(
      context,
      participant: p,
      actions: [
        _ParticipantAction(
          icon: Icons.how_to_reg_rounded,
          label: 'Escalar membro',
          description: 'Adicionar manualmente à escala do evento',
          iconColor: AppTheme.primaryColor,
          iconBgColor: const Color(0xFFEFF6FF),
          onTap: () => _handleAssign(context, ref, p.membershipId),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final awaiting = _awaitingAssignment;
    final assigned = _assigned;
    final notAssigned = _notAssigned;
    final semConfirmacao = _semConfirmacao;
    final notAnsweredCount = semConfirmacao
        .where((p) =>
            p.availabilityStatus ==
            OrganizationEventMembershipAvailabilityStatus.notAnswered)
        .length;

    return Column(
      children: [
        // ── 1. Aguardando Escalação ────────────────────────────────────────────
        ExpandedCard(
          leading: _SectionIcon(
            bgColor: const Color(0xFFFFF7ED),
            iconColor: AppTheme.secondaryColor,
            icon: Icons.pan_tool_rounded,
          ),
          title: 'Aguardando Escalação',
          description: _label(awaiting.length, 'disponíveis'),
          initiallyExpanded: awaiting.isNotEmpty,
          children: awaiting.isEmpty
              ? [const _EmptySection()]
              : awaiting
                  .map((p) => EventParticipantTile(
                        participant: p,
                        trailing: canManageEvents
                            ? _ManageButton(
                                onTap: () => _showAwaitingSheet(context, ref, p),
                              )
                            : p.membershipId == currentMemberId
                                ? _LeaveButton(
                                    onLeave: () => _handleLeave(context, ref))
                                : null,
                      ))
                  .toList(),
        ),
        const SizedBox(height: 12),

        // ── 2. Escalados ──────────────────────────────────────────────────────
        ExpandedCard(
          leading: _SectionIcon(
            bgColor: const Color(0xFFECFDF5),
            iconColor: AppTheme.successColor,
            icon: Icons.check_circle_rounded,
          ),
          title: 'Escalados',
          description: _label(assigned.length, 'confirmados'),
          initiallyExpanded: assigned.isNotEmpty,
          children: assigned.isEmpty
              ? [const _EmptySection()]
              : assigned
                  .map((p) => EventParticipantTile(
                        participant: p,
                        functionColor: AppTheme.successColor,
                        trailing: canManageEvents
                            ? _ManageButton(
                                onTap: () => _showAssignedSheet(context, ref, p),
                              )
                            : null,
                      ))
                  .toList(),
        ),
        const SizedBox(height: 12),

        // ── 3. Não Escalados ──────────────────────────────────────────────────
        ExpandedCard(
          leading: _SectionIcon(
            bgColor: const Color(0xFFF1F5F9),
            iconColor: AppTheme.textSecondary,
            icon: Icons.person_outline_rounded,
          ),
          title: 'Não Escalados',
          description: _label(notAssigned.length, 'disponíveis'),
          initiallyExpanded: false,
          children: notAssigned.isEmpty
              ? [const _EmptySection()]
              : notAssigned
                  .map((p) => EventParticipantTile(
                        participant: p,
                        trailing: canManageEvents
                            ? _ManageButton(
                                onTap: () => _showNotAssignedSheet(context, ref, p),
                              )
                            : null,
                      ))
                  .toList(),
        ),
        const SizedBox(height: 12),

        // ── 4. Não Confirmados (não responderam + indisponíveis) ──────────────
        ExpandedCard(
          leading: _SectionIcon(
            bgColor: const Color(0xFFF8FAFC),
            iconColor: AppTheme.textSecondary,
            icon: Icons.help_outline_rounded,
          ),
          title: 'Não Confirmados',
          description: _label(semConfirmacao.length, 'convocados'),
          initiallyExpanded: false,
          children: [
            if (semConfirmacao.isEmpty)
              const _EmptySection()
            else
              ...semConfirmacao.map((p) => EventParticipantTile(
                    participant: p,
                    strikethrough: p.availabilityStatus ==
                        OrganizationEventMembershipAvailabilityStatus.unavailable,
                  )),
            if (notAnsweredCount > 0 && canManageEvents)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: ActionButton(
                  label: 'Notificar Quem Não Respondeu',
                  icon: Icons.notifications_rounded,
                  schema: ActionButtonSchema.secondary,
                  size: ActionButtonSize.sm,
                  onPressed: () => _handleNotify(context, ref),
                ),
              ),
          ],
        ),
      ],
    );
  }

  static String _label(int count, String pluralSuffix) {
    if (count == 0) return 'Nenhum membro';
    return '$count ${count == 1 ? 'membro' : pluralSuffix}';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PARTICIPANT MANAGE MODAL
// ─────────────────────────────────────────────────────────────────────────────

class _ParticipantAction {
  final IconData icon;
  final String label;
  final String description;
  final Color? iconColor;
  final Color? iconBgColor;
  final bool destructive;
  final VoidCallback onTap;

  const _ParticipantAction({
    required this.icon,
    required this.label,
    required this.description,
    this.iconColor,
    this.iconBgColor,
    this.destructive = false,
    required this.onTap,
  });
}

class _ParticipantManageModal extends BaseModalStatefulWidget {
  final OrganizationEventParticipantModel participant;
  final List<_ParticipantAction> actions;

  const _ParticipantManageModal({
    required this.participant,
    required this.actions,
  });

  static Future<void> show(
    BuildContext context, {
    required OrganizationEventParticipantModel participant,
    required List<_ParticipantAction> actions,
  }) =>
      BaseModalStatefulWidget.show(
        context,
        _ParticipantManageModal(participant: participant, actions: actions),
      );

  @override
  State<_ParticipantManageModal> createState() =>
      _ParticipantManageModalState();
}

class _ParticipantManageModalState
    extends BaseModalState<_ParticipantManageModal> {
  @override
  Widget? get titleWidget => HeaderModalTitleSubtitle(
        title: 'Gerenciar participante',
        subtitle: widget.participant.name,
      );

  @override
  List<Widget> buildBody(BuildContext context) {
    return [
      ...widget.actions.map(
        (action) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ActionTile(
            icon: action.icon,
            title: action.label,
            description: action.description,
            iconColor: action.iconColor,
            iconBgColor: action.iconBgColor,
            destructive: action.destructive,
            onTap: () {
              BaseModalStatefulWidget.hide(context);
              action.onTap();
            },
          ),
        ),
      ),
      const SizedBox(height: 8),
    ];
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ACTION WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

class _ManageButton extends StatelessWidget {
  final VoidCallback onTap;

  const _ManageButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Icon(
          Icons.more_vert_rounded,
          color: AppTheme.textSecondary,
          size: 18,
        ),
      ),
    );
  }
}

class _LeaveButton extends StatelessWidget {
  final VoidCallback onLeave;

  const _LeaveButton({required this.onLeave});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onLeave,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF2F2),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.errorColor.withValues(alpha: 0.3)),
        ),
        child: Text(
          'Sair',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppTheme.errorColor,
                fontWeight: FontWeight.w700,
              ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HELPERS
// ─────────────────────────────────────────────────────────────────────────────

class _SectionIcon extends StatelessWidget {
  final Color bgColor;
  final Color iconColor;
  final IconData icon;

  const _SectionIcon({
    required this.bgColor,
    required this.iconColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: iconColor, size: 20),
    );
  }
}

class _EmptySection extends StatelessWidget {
  const _EmptySection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Center(
        child: Text(
          'Nenhum membro nesta seção.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ),
    );
  }
}
