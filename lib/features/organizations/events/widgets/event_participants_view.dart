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
/// Agrupa participantes em quatro seções colapsáveis via [ExpandedCard].
/// Exibe botões de ação contextuais com base em [canManageEvents] e [currentMemberId].
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

  List<OrganizationEventParticipantModel> get _awaitingApproval =>
      participants
          .where((p) =>
              p.status == OrganizationEventMembershipStatus.awaitingAssignment ||
              p.status == OrganizationEventMembershipStatus.awaitingDraw)
          .toList();

  List<OrganizationEventParticipantModel> get _assigned => participants
      .where((p) => p.status == OrganizationEventMembershipStatus.assigned)
      .toList();

  List<OrganizationEventParticipantModel> get _notAnswered => participants
      .where((p) =>
          p.availabilityStatus ==
          OrganizationEventMembershipAvailabilityStatus.notAnswered)
      .toList();

  List<OrganizationEventParticipantModel> get _unavailable => participants
      .where((p) =>
          p.availabilityStatus ==
          OrganizationEventMembershipAvailabilityStatus.unavailable)
      .toList();

  void _handleAssign(BuildContext context, WidgetRef ref, String membershipId) async {
    try {
      await ref.read(manageParticipantProvider.notifier).assign(
            organizationId: organizationId,
            eventId: eventId,
            membershipId: membershipId,
          );
      ref.invalidate(findEventDetailsByIdProvider(
        organizationId: organizationId,
        eventId: eventId,
      ));
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
        organizationId: organizationId,
        eventId: eventId,
      ));
    } catch (_) {
      if (!context.mounted) return;
      ToastFeedbackService.showToast(
          context, 'Não foi possível rejeitar o membro.', ToastType.error);
    }
  }

  void _handleRemoveAssigned(
      BuildContext context, WidgetRef ref, String membershipId) async {
    try {
      await ref.read(manageParticipantProvider.notifier).removeAssigned(
            organizationId: organizationId,
            eventId: eventId,
            membershipId: membershipId,
          );
      ref.invalidate(findEventDetailsByIdProvider(
        organizationId: organizationId,
        eventId: eventId,
      ));
    } catch (_) {
      if (!context.mounted) return;
      ToastFeedbackService.showToast(
          context, 'Não foi possível remover o membro da escala.', ToastType.error);
    }
  }

  void _handleRemoveOwn(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(manageParticipantProvider.notifier).removeOwn(
            organizationId: organizationId,
            eventId: eventId,
          );
      ref.invalidate(findEventDetailsByIdProvider(
        organizationId: organizationId,
        eventId: eventId,
      ));
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final awaiting = _awaitingApproval;
    final assigned = _assigned;
    final notAnswered = _notAnswered;
    final unavailable = _unavailable;

    return Column(
      children: [
        // ── Aguardando Aprovação ────────────────────────────────────────────
        ExpandedCard(
          leading: _SectionIcon(
            bgColor: const Color(0xFFFFF7ED),
            iconColor: AppTheme.secondaryColor,
            icon: Icons.pan_tool_rounded,
          ),
          title: 'Aguardando Aprovação',
          description: _memberLabel(awaiting.length, 'disponíveis'),
          initiallyExpanded: awaiting.isNotEmpty,
          children: awaiting.isEmpty
              ? [const _EmptySection()]
              : awaiting
                  .map((p) => EventParticipantTile(
                        participant: p,
                        trailing: canManageEvents
                            ? _ApprovalActions(
                                onApprove: () =>
                                    _handleAssign(context, ref, p.membershipId),
                                onReject: () =>
                                    _handleReject(context, ref, p.membershipId),
                              )
                            : p.membershipId == currentMemberId
                                ? _LeaveButton(
                                    onLeave: () =>
                                        _handleRemoveOwn(context, ref),
                                  )
                                : null,
                      ))
                  .toList(),
        ),
        const SizedBox(height: 12),

        // ── Escalados ───────────────────────────────────────────────────────
        ExpandedCard(
          leading: _SectionIcon(
            bgColor: const Color(0xFFECFDF5),
            iconColor: AppTheme.successColor,
            icon: Icons.check_circle_rounded,
          ),
          title: 'Escalados',
          description: _memberLabel(assigned.length, 'confirmados'),
          initiallyExpanded: assigned.isNotEmpty,
          children: assigned.isEmpty
              ? [const _EmptySection()]
              : assigned
                  .map((p) => EventParticipantTile(
                        participant: p,
                        functionColor: AppTheme.successColor,
                        trailing: canManageEvents
                            ? _RemoveButton(
                                onRemove: () => _handleRemoveAssigned(
                                    context, ref, p.membershipId),
                              )
                            : null,
                      ))
                  .toList(),
        ),
        const SizedBox(height: 12),

        // ── Não Responderam ─────────────────────────────────────────────────
        ExpandedCard(
          leading: _SectionIcon(
            bgColor: const Color(0xFFEFF6FF),
            iconColor: AppTheme.infoColor,
            icon: Icons.schedule_rounded,
          ),
          title: 'Não Responderam',
          description: _memberLabel(notAnswered.length, 'convocados'),
          initiallyExpanded: false,
          children: [
            if (notAnswered.isEmpty)
              const _EmptySection()
            else
              ...notAnswered.map((p) => EventParticipantTile(participant: p)),
            if (notAnswered.isNotEmpty && canManageEvents)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: ActionButton(
                  label: 'Notificar Todos',
                  icon: Icons.notifications_rounded,
                  schema: ActionButtonSchema.secondary,
                  size: ActionButtonSize.sm,
                  onPressed: () => _handleNotify(context, ref),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),

        // ── Indisponíveis ───────────────────────────────────────────────────
        ExpandedCard(
          leading: _SectionIcon(
            bgColor: const Color(0xFFF1F5F9),
            iconColor: AppTheme.errorColor,
            icon: Icons.person_remove_rounded,
          ),
          title: 'Indisponíveis',
          description: _memberLabel(unavailable.length, 'membros'),
          initiallyExpanded: false,
          children: unavailable.isEmpty
              ? [const _EmptySection()]
              : unavailable
                  .map((p) => EventParticipantTile(
                        participant: p,
                        strikethrough: true,
                      ))
                  .toList(),
        ),
      ],
    );
  }

  static String _memberLabel(int count, String pluralSuffix) {
    if (count == 0) return 'Nenhum membro';
    return '$count ${count == 1 ? 'membro' : pluralSuffix}';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ACTION WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

class _ApprovalActions extends StatelessWidget {
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const _ApprovalActions({required this.onApprove, required this.onReject});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ActionIcon(
          icon: Icons.check_rounded,
          color: AppTheme.successColor,
          bgColor: const Color(0xFFECFDF5),
          onTap: onApprove,
        ),
        const SizedBox(width: 6),
        _ActionIcon(
          icon: Icons.close_rounded,
          color: AppTheme.errorColor,
          bgColor: const Color(0xFFFEF2F2),
          onTap: onReject,
        ),
      ],
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
          border: Border.all(color: AppTheme.errorColor.withOpacity(0.3)),
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

class _RemoveButton extends StatelessWidget {
  final VoidCallback onRemove;

  const _RemoveButton({required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return _ActionIcon(
      icon: Icons.remove_rounded,
      color: AppTheme.errorColor,
      bgColor: const Color(0xFFFEF2F2),
      onTap: onRemove,
    );
  }
}

class _ActionIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color bgColor;
  final VoidCallback onTap;

  const _ActionIcon({
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Icon(icon, color: color, size: 16),
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
