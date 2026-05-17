import 'package:convoquei_app/core/services/toast_feedback_service.dart';
import 'package:convoquei_app/design_system/ds.dart';
import 'package:convoquei_app/features/organizations/events/models/enums/organization_event_membership_availability_status.dart';
import 'package:convoquei_app/features/organizations/events/models/enums/organization_event_membership_status.dart';
import 'package:convoquei_app/features/organizations/events/models/organization_event_details_model.dart';
import 'package:convoquei_app/features/organizations/events/providers/answer_availability_provider.dart';
import 'package:convoquei_app/features/organizations/events/providers/find_event_details_by_id_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum _PersonalStatus { assigned, awaitingApproval, available, unavailable, notAnswered }

class EventDetailPersonalStatusCard extends ConsumerStatefulWidget {
  const EventDetailPersonalStatusCard({
    super.key,
    required this.organizationId,
    required this.eventId,
    required this.currentMemberId,
    required this.participants,
  });

  final String organizationId;
  final String eventId;
  final String currentMemberId;
  final List<OrganizationEventParticipantModel> participants;

  @override
  ConsumerState<EventDetailPersonalStatusCard> createState() =>
      _EventDetailPersonalStatusCardState();
}

class _EventDetailPersonalStatusCardState
    extends ConsumerState<EventDetailPersonalStatusCard> {
  bool _loading = false;

  _PersonalStatus get _status {
    final me = widget.participants
        .where((p) => p.membershipId == widget.currentMemberId)
        .firstOrNull;

    if (me == null) return _PersonalStatus.notAnswered;

    if (me.status == OrganizationEventMembershipStatus.assigned) {
      return _PersonalStatus.assigned;
    }
    if (me.status == OrganizationEventMembershipStatus.awaitingAssignment ||
        me.status == OrganizationEventMembershipStatus.awaitingDraw) {
      return _PersonalStatus.awaitingApproval;
    }
    if (me.availabilityStatus ==
        OrganizationEventMembershipAvailabilityStatus.unavailable) {
      return _PersonalStatus.unavailable;
    }
    if (me.availabilityStatus ==
        OrganizationEventMembershipAvailabilityStatus.available) {
      return _PersonalStatus.available;
    }
    return _PersonalStatus.notAnswered;
  }

  Future<void> _markAvailable() async {
    setState(() => _loading = true);
    try {
      await ref.read(answerAvailabilityProvider.notifier).answer(
            organizationId: widget.organizationId,
            eventId: widget.eventId,
            available: true,
          );
      if (!mounted) return;
      ref.invalidate(findEventDetailsByIdProvider(
        organizationId: widget.organizationId,
        eventId: widget.eventId,
      ));
    } catch (_) {
      if (!mounted) return;
      ToastFeedbackService.showToast(
          context, 'Não foi possível registrar disponibilidade.', ToastType.error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = _status;
    final config = _statusConfig(context, status);

    return DSCard(
      padding: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: config.tint,
                shape: BoxShape.circle,
              ),
              child: Icon(config.icon, size: 18, color: config.color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Minha Escala',
                    style: context.textStyles.labelSmall.copyWith(
                      color: context.colors.textSecondary,
                    ),
                  ),
                  Text(
                    config.label,
                    style: context.textStyles.labelMedium.copyWith(
                      color: context.colors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            if (status == _PersonalStatus.notAnswered)
              DSButton(
                label: 'Disponibilizar-me',
                size: DSButtonSize.xs,
                fullWidth: false,
                isLoading: _loading,
                onPressed: _markAvailable,
              ),
          ],
        ),
      ),
    );
  }

  ({IconData icon, Color color, Color tint, String label}) _statusConfig(
    BuildContext context,
    _PersonalStatus status,
  ) =>
      switch (status) {
        _PersonalStatus.assigned => (
          icon: Icons.check_circle_rounded,
          color: context.colors.success,
          tint: context.colors.successTint,
          label: 'Você está escalado',
        ),
        _PersonalStatus.awaitingApproval => (
          icon: Icons.hourglass_top_rounded,
          color: context.colors.warning,
          tint: context.colors.warningTint,
          label: 'Aguardando aprovação',
        ),
        _PersonalStatus.available => (
          icon: Icons.thumb_up_rounded,
          color: context.colors.info,
          tint: context.colors.infoTint,
          label: 'Disponível — aguardando escala',
        ),
        _PersonalStatus.unavailable => (
          icon: Icons.block_rounded,
          color: context.colors.danger,
          tint: context.colors.dangerTint,
          label: 'Você informou indisponibilidade',
        ),
        _PersonalStatus.notAnswered => (
          icon: Icons.help_outline_rounded,
          color: context.colors.textSecondary,
          tint: context.colors.surfaceSubtle,
          label: 'Você ainda não respondeu',
        ),
      };
}
