import 'package:convoquei_app/core/services/toast_feedback_service.dart';
import 'package:convoquei_app/core/theme/app_theme.dart';
import 'package:convoquei_app/core/widgets/action_button.dart';
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
      BuildContext context, WidgetRef ref, String membershipId) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _ParticipantActionsSheet(
        actions: [
          _SheetAction(
            icon: Icons.check_circle_rounded,
            label: 'Escalar membro',
            color: AppTheme.successColor,
            onTap: () {
              Navigator.of(context).pop();
              _handleApprove(context, ref, membershipId);
            },
          ),
          _SheetAction(
            icon: Icons.cancel_rounded,
            label: 'Rejeitar membro',
            color: AppTheme.errorColor,
            onTap: () {
              Navigator.of(context).pop();
              _handleReject(context, ref, membershipId);
            },
          ),
        ],
      ),
    );
  }

  void _showAssignedSheet(
      BuildContext context, WidgetRef ref, String membershipId) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _ParticipantActionsSheet(
        actions: [
          _SheetAction(
            icon: Icons.person_remove_rounded,
            label: 'Remover da escala',
            color: AppTheme.errorColor,
            onTap: () {
              Navigator.of(context).pop();
              _handleRemove(context, ref, membershipId);
            },
          ),
        ],
      ),
    );
  }

  void _showNotAssignedSheet(
      BuildContext context, WidgetRef ref, String membershipId) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _ParticipantActionsSheet(
        actions: [
          _SheetAction(
            icon: Icons.how_to_reg_rounded,
            label: 'Escalar membro',
            color: AppTheme.primaryColor,
            onTap: () {
              Navigator.of(context).pop();
              _handleAssign(context, ref, membershipId);
            },
          ),
        ],
      ),
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
                                onTap: () => _showAwaitingSheet(
                                    context, ref, p.membershipId),
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
                                onTap: () => _showAssignedSheet(
                                    context, ref, p.membershipId),
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
                                onTap: () => _showNotAssignedSheet(
                                    context, ref, p.membershipId),
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
// PARTICIPANT ACTIONS SHEET
// ─────────────────────────────────────────────────────────────────────────────

class _SheetAction {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback onTap;

  const _SheetAction({
    required this.icon,
    required this.label,
    this.color,
    required this.onTap,
  });
}

class _ParticipantActionsSheet extends StatelessWidget {
  final List<_SheetAction> actions;

  const _ParticipantActionsSheet({required this.actions});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          for (int i = 0; i < actions.length; i++) ...[
            if (i > 0) const Divider(indent: 16, endIndent: 16),
            _SheetActionTile(action: actions[i]),
          ],
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _SheetActionTile extends StatelessWidget {
  final _SheetAction action;

  const _SheetActionTile({required this.action});

  @override
  Widget build(BuildContext context) {
    final color = action.color ?? AppTheme.textPrimary;
    return ListTile(
      leading: Icon(action.icon, color: color),
      title: Text(
        action.label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(color: color),
      ),
      onTap: action.onTap,
    );
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
