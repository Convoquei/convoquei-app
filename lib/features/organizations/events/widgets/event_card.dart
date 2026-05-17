import 'package:convoquei_app/design_system/ds.dart';
import 'package:convoquei_app/features/organizations/events/models/enums/organization_event_membership_availability_status.dart';
import 'package:convoquei_app/features/organizations/events/models/enums/organization_event_membership_status.dart';
import 'package:convoquei_app/features/organizations/events/models/enums/organization_event_status.dart';
import 'package:convoquei_app/features/organizations/events/models/orgnaization_event_membership_model.dart';
import 'package:convoquei_app/features/organizations/events/widgets/event_status_badge.dart';
import 'package:convoquei_app/features/organizations/events/widgets/urgent_badge.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// ── Abbreviated weekday names (Mon=1 … Sun=7) ─────────────────────────────────
const _weekdayAbbr = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];

// ─────────────────────────────────────────────────────────────────────────────
// EventCard
// ─────────────────────────────────────────────────────────────────────────────

class EventCard extends StatefulWidget {
  final OrganizationEventMembershipModel? event;
  final bool skeleton;
  final Future<void> Function()? onAvailable;
  final Future<void> Function()? onUnavailable;
  final Future<void> Function()? onLeaveSchedule;
  final VoidCallback? onTap;
  const EventCard({
    super.key,
    this.event,
    this.skeleton = false,
    this.onAvailable,
    this.onUnavailable,
    this.onLeaveSchedule,
    this.onTap,
  }) : assert(
         skeleton || event != null,
         'event is required when skeleton is false',
       );

  @override
  State<EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<EventCard> {
  bool _isLoadingAvailable = false;
  bool _isLoadingUnavailable = false;
  bool _isLoadingLeave = false;

  bool get _isAnyLoading =>
      _isLoadingAvailable || _isLoadingUnavailable || _isLoadingLeave;

  // ── Accent color by membership status ────────────────────────────
  Color _accentColor(BuildContext context) =>
      switch (widget.event!.membershipStatus) {
        OrganizationEventMembershipStatus.assigned => context.colors.primary,
        OrganizationEventMembershipStatus.pending =>
          switch (widget.event!.membershipAvailabilityStatus) {
            OrganizationEventMembershipAvailabilityStatus.available =>
              context.colors.success,
            OrganizationEventMembershipAvailabilityStatus.unavailable =>
              context.colors.danger,
            OrganizationEventMembershipAvailabilityStatus.notAnswered ||
            null => context.colors.warning,
          },
        OrganizationEventMembershipStatus.notAssigned ||
        OrganizationEventMembershipStatus.expired ||
        null => context.colors.border,
        OrganizationEventMembershipStatus.awaitingAssignment =>
          context.colors.info,
        OrganizationEventMembershipStatus.invited => context.colors.warning,
      };

  // ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    if (widget.skeleton) return _EventCardSkeleton();

    final event = widget.event!;
    final isCanceled = event.status == OrganizationEventStatus.canceled;

    final showUrgent =
        !isCanceled &&
        event.availabilityLockBeforeStartInMinutes > 0 &&
        event.availabilityLockEpochSeconds <= 86400 &&
        event.availabilityLockEpochSeconds > 0;

    final showInProgress = event.status == OrganizationEventStatus.inProgress;

    return Opacity(
      opacity: isCanceled ? 0.5 : 1.0,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: DSRadius.allLg,
            border: Border.all(color: context.colors.border),
            boxShadow: DSElevation.sm,
          ),
          clipBehavior: Clip.hardEdge,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Barra de status colorida ──────────────────────
                Container(width: 5, color: _accentColor(context)),

                // ── Coluna de data ────────────────────────────────
                Container(
                  width: 52,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(height: 2),
                      Text(
                        _weekdayAbbr[event.startTime.weekday - 1].toUpperCase(),
                        style: context.textStyles.labelSmall?.copyWith(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: context.colors.textSecondary,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        '${event.startTime.day}',
                        style: context.textStyles.displayMedium?.copyWith(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: context.colors.textPrimary,
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Separador vertical ────────────────────────────
                Container(
                  width: 1,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  color: context.colors.surfaceSubtle,
                ),

                // ── Conteúdo principal ────────────────────────────
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Badges urgente / em andamento ─────────
                        if (showUrgent || showInProgress) ...[
                          Row(
                            children: [
                              if (showUrgent) ...[
                                Flexible(child: UrgentBadge(event: event)),
                                const SizedBox(width: 6),
                              ],
                              if (showInProgress)
                                EventStatusBadge(event.status),
                            ],
                          ),
                          const SizedBox(height: 8),
                        ],

                        // ── Título + hora ─────────────────────────
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                event.name,
                                style: context.textStyles.titleSmall?.copyWith(
                                  decoration: isCanceled
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: context.colors.surfaceSubtle,
                                borderRadius: DSRadius.allSm,
                                border: Border.all(
                                  color: context.colors.border,
                                ),
                              ),
                              child: Text(
                                '${DateFormat('HH:mm').format(event.startTime)} – ${DateFormat('HH:mm').format(event.endTime)}',
                                style: context.textStyles.labelSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: context.colors.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 4),

                        // ── Localização ───────────────────────────
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_rounded,
                              size: 12,
                              color: context.colors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                event.location,
                                style: context.textStyles.bodySmall,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),
                        Divider(height: 1, color: context.colors.surfaceSubtle),
                        const SizedBox(height: 10),

                        // ── Footer de status ──────────────────────
                        _buildFooter(context),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────

  Widget _buildFooter(BuildContext context) {
    final event = widget.event!;

    if (event.status == OrganizationEventStatus.completed ||
        event.status == OrganizationEventStatus.canceled ||
        event.membershipStatus != OrganizationEventMembershipStatus.pending ||
        !event.allowAssignment) {
      return _buildStatusFooter(context);
    }

    return switch (event.membershipAvailabilityStatus) {
      OrganizationEventMembershipAvailabilityStatus.notAnswered =>
        _buildAvailabilityButtons(context),
      OrganizationEventMembershipAvailabilityStatus.available =>
        _buildAvailableConfirmed(context),
      OrganizationEventMembershipAvailabilityStatus.unavailable =>
        _buildUnavailableConfirmed(context),
      null => const SizedBox.shrink(),
    };
  }

  Widget _buildAvailabilityButtons(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Confirme sua disponibilidade',
          style: context.textStyles.labelSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: context.colors.textPrimary,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: DSButton(
                label: 'Disponível',
                icon: Icons.check_rounded,
                outlined: true,
                schema: DSButtonSchema.success,
                size: DSButtonSize.sm,
                isLoading: _isLoadingAvailable,
                onPressed:
                    (widget.onAvailable == null ||
                        (_isAnyLoading && !_isLoadingAvailable))
                    ? null
                    : () async {
                        setState(() => _isLoadingAvailable = true);
                        try {
                          await widget.onAvailable!();
                        } finally {
                          if (mounted)
                            setState(() => _isLoadingAvailable = false);
                        }
                      },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: DSButton(
                label: 'Indisponível',
                icon: Icons.close_rounded,
                outlined: true,
                schema: DSButtonSchema.ghost,
                size: DSButtonSize.sm,
                isLoading: _isLoadingUnavailable,
                onPressed:
                    (widget.onUnavailable == null ||
                        (_isAnyLoading && !_isLoadingUnavailable))
                    ? null
                    : () async {
                        setState(() => _isLoadingUnavailable = true);
                        try {
                          await widget.onUnavailable!();
                        } finally {
                          if (mounted) {
                            setState(() => _isLoadingUnavailable = false);
                          }
                        }
                      },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAvailableConfirmed(BuildContext context) {
    return Row(
      children: [
        _StatusCircle(
          bgColor: context.colors.successTint,
          borderColor: context.colors.success.withValues(alpha: 0.3),
          icon: Icons.check_rounded,
          iconColor: context.colors.success,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Você está disponível',
                style: context.textStyles.labelSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: context.colors.textPrimary,
                  fontSize: 11,
                ),
              ),
              Text(
                widget.event!.membershipFunctionName != null
                    ? 'Você se disponibilizou para ${widget.event!.membershipFunctionName}'
                    : 'Você se disponibilizou para este evento',
                style: context.textStyles.bodySmall?.copyWith(fontSize: 10),
              ),
            ],
          ),
        ),
        DSButton(
          label: 'Indisponível',
          icon: Icons.close_rounded,
          outlined: true,
          schema: DSButtonSchema.danger,
          size: DSButtonSize.xs,
          isLoading: _isLoadingUnavailable,
          fullWidth: false,
          onPressed: (widget.onUnavailable == null || _isAnyLoading)
              ? null
              : () async {
                  setState(() => _isLoadingUnavailable = true);
                  try {
                    await widget.onUnavailable!();
                  } finally {
                    if (mounted) setState(() => _isLoadingUnavailable = false);
                  }
                },
        ),
      ],
    );
  }

  Widget _buildUnavailableConfirmed(BuildContext context) {
    return Row(
      children: [
        _StatusCircle(
          bgColor: context.colors.dangerTint,
          borderColor: context.colors.danger.withValues(alpha: 0.3),
          icon: Icons.close_rounded,
          iconColor: context.colors.danger,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Você está indisponível',
                style: context.textStyles.labelSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: context.colors.textPrimary,
                  fontSize: 11,
                ),
              ),
              Text(
                'Toque para ficar disponível',
                style: context.textStyles.bodySmall?.copyWith(fontSize: 10),
              ),
            ],
          ),
        ),
        DSButton(
          label: 'Disponível',
          icon: Icons.check_rounded,
          outlined: true,
          schema: DSButtonSchema.success,
          size: DSButtonSize.xs,
          isLoading: _isLoadingAvailable,
          fullWidth: false,
          onPressed: (widget.onAvailable == null || _isAnyLoading)
              ? null
              : () async {
                  setState(() => _isLoadingAvailable = true);
                  try {
                    await widget.onAvailable!();
                  } finally {
                    if (mounted) setState(() => _isLoadingAvailable = false);
                  }
                },
        ),
      ],
    );
  }

  Widget _buildStatusFooter(BuildContext context) {
    final event = widget.event!;

    if (event.status == OrganizationEventStatus.canceled) {
      return DSInfoBanner(
        bgColor: context.colors.dangerTint,
        borderColor: context.colors.danger.withValues(alpha: 0.3),
        icon: Icons.close_rounded,
        iconColor: context.colors.danger,
        label: 'Evento Cancelado',
        sublabel: 'Este evento foi cancelado pelo admin.',
      );
    }

    if (event.status == OrganizationEventStatus.completed) {
      final formattedDate = DateFormat(
        "d 'de' MMMM 'às' HH:mm",
        'pt_BR',
      ).format(event.endTime);
      return DSInfoBanner(
        bgColor: context.colors.surfaceSubtle,
        borderColor: context.colors.border,
        icon: Icons.check_circle_outline_rounded,
        iconColor: context.colors.textSecondary,
        label: 'Evento Concluído',
        sublabel: 'Finalizado em $formattedDate',
        labelColor: context.colors.textSecondary,
      );
    }

    if (!event.allowAssignment) {
      if (event.membershipStatus ==
          OrganizationEventMembershipStatus.assigned) {
        return DSInfoBanner(
          bgColor: context.colors.successTint,
          borderColor: context.colors.success.withValues(alpha: 0.3),
          icon: Icons.check_rounded,
          iconColor: context.colors.success,
          label: 'Você está escalado',
          sublabel: 'Este evento não aceita mais respostas.',
        );
      }
      return DSInfoBanner(
        bgColor: context.colors.surfaceSubtle,
        borderColor: context.colors.border,
        icon: Icons.lock_outline_rounded,
        iconColor: context.colors.textSecondary,
        label: 'Não escalado',
        sublabel: 'Este evento não aceita mais respostas.',
        labelColor: context.colors.textSecondary,
      );
    }

    return switch (event.membershipStatus) {
      OrganizationEventMembershipStatus.assigned => Row(
        children: [
          _StatusCircle(
            bgColor: context.colors.successTint,
            borderColor: context.colors.success.withValues(alpha: 0.3),
            icon: Icons.check_rounded,
            iconColor: context.colors.success,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Você está escalado',
              style: context.textStyles.labelSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: context.colors.textPrimary,
                fontSize: 11,
              ),
            ),
          ),
          if (event.membershipAvailabilityStatus ==
              OrganizationEventMembershipAvailabilityStatus.available)
            DSButton(
              label: 'Sair',
              icon: Icons.logout_rounded,
              outlined: true,
              schema: DSButtonSchema.ghost,
              size: DSButtonSize.xs,
              isLoading: _isLoadingLeave,
              fullWidth: false,
              onPressed: (widget.onLeaveSchedule == null || _isAnyLoading)
                  ? null
                  : () async {
                      setState(() => _isLoadingLeave = true);
                      try {
                        await widget.onLeaveSchedule!();
                      } finally {
                        if (mounted) setState(() => _isLoadingLeave = false);
                      }
                    },
            )
          else
            _ParticipantsChip(count: event.participantsCount),
        ],
      ),
      OrganizationEventMembershipStatus.awaitingAssignment => DSInfoBanner(
        bgColor: context.colors.infoTint,
        borderColor: context.colors.info.withValues(alpha: 0.3),
        icon: Icons.hourglass_top_rounded,
        iconColor: context.colors.info,
        label: 'Aguardando escalação',
        sublabel: 'Aguardando a aprovação da sua escala',
      ),
      OrganizationEventMembershipStatus.invited => DSInfoBanner(
        bgColor: context.colors.warningTint,
        borderColor: context.colors.warning.withValues(alpha: 0.3),
        icon: Icons.mail_outline_rounded,
        iconColor: context.colors.warning,
        label: 'Participação solicitada',
        sublabel: 'Abra o evento para confirmar.',
      ),
      OrganizationEventMembershipStatus.notAssigned || null => DSInfoBanner(
        bgColor: context.colors.surfaceSubtle,
        borderColor: context.colors.border,
        icon: Icons.close_rounded,
        iconColor: context.colors.textSecondary,
        label: 'Não escalado',
        sublabel: 'Você não está nesta escala.',
        labelColor: context.colors.textSecondary,
      ),
      OrganizationEventMembershipStatus.expired => DSInfoBanner(
        bgColor: context.colors.dangerTint,
        borderColor: context.colors.danger.withValues(alpha: 0.3),
        icon: Icons.timer_off_rounded,
        iconColor: context.colors.danger,
        label: 'Resposta expirada',
        sublabel: 'O prazo para responder passou.',
        labelColor: context.colors.textSecondary,
      ),
      OrganizationEventMembershipStatus.pending => const SizedBox.shrink(),
    };
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Skeleton
// ─────────────────────────────────────────────────────────────────────────────

class _EventCardSkeleton extends StatelessWidget {
  const _EventCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: DSRadius.allLg,
        border: Border.all(color: context.colors.border),
        boxShadow: DSElevation.sm,
      ),
      clipBehavior: Clip.hardEdge,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 5, color: context.colors.border),
            Container(
              width: 52,
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(height: 4),
                  DSSkeleton(width: 28, height: 10, borderRadius: DSRadius.sm),
                  SizedBox(height: 4),
                  DSSkeleton(width: 32, height: 28, borderRadius: DSRadius.sm),
                ],
              ),
            ),
            Container(
              width: 1,
              margin: const EdgeInsets.symmetric(vertical: 12),
              color: context.colors.surfaceSubtle,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Expanded(
                          child: DSSkeleton(
                            height: 16,
                            borderRadius: DSRadius.sm,
                          ),
                        ),
                        SizedBox(width: 8),
                        DSSkeleton(
                          width: 72,
                          height: 22,
                          borderRadius: DSRadius.sm,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const DSSkeleton(
                      width: 130,
                      height: 12,
                      borderRadius: DSRadius.sm,
                    ),
                    const SizedBox(height: 10),
                    Divider(height: 1, color: context.colors.surfaceSubtle),
                    const SizedBox(height: 10),
                    const DSSkeleton(height: 32, borderRadius: DSRadius.sm),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HELPERS
// ─────────────────────────────────────────────────────────────────────────────

class _StatusCircle extends StatelessWidget {
  final Color bgColor;
  final Color borderColor;
  final IconData icon;
  final Color iconColor;

  const _StatusCircle({
    required this.bgColor,
    required this.borderColor,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        border: Border.all(color: borderColor),
      ),
      child: Icon(icon, size: 14, color: iconColor),
    );
  }
}

class _ParticipantsChip extends StatelessWidget {
  final int count;

  const _ParticipantsChip({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: context.colors.surfaceSubtle,
        borderRadius: DSRadius.allSm,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.people_rounded,
            size: 12,
            color: context.colors.textSecondary,
          ),
          const SizedBox(width: 4),
          Text(
            '$count membros',
            style: context.textStyles.labelSmall?.copyWith(
              color: context.colors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
