import 'package:convoquei_app/core/theme/app_theme.dart';
import 'package:convoquei_app/core/widgets/action_button.dart';
import 'package:convoquei_app/core/widgets/info_banner.dart';
import 'package:convoquei_app/core/widgets/status_circle.dart';
import 'package:convoquei_app/features/organizations/events/models/enums/organization_event_membership_availability_status.dart';
import 'package:convoquei_app/features/organizations/events/models/enums/organization_event_membership_status.dart';
import 'package:convoquei_app/features/organizations/events/models/enums/organization_event_status.dart';
import 'package:convoquei_app/features/organizations/events/models/orgnaization_event_membership_model.dart';
import 'package:convoquei_app/features/organizations/events/widgets/event_status_badge.dart';
import 'package:convoquei_app/features/organizations/events/widgets/participants_chip.dart';
import 'package:convoquei_app/features/organizations/events/widgets/urgent_badge.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// ── Abbreviated weekday names (Mon=1 … Sun=7) ─────────────────────────────────
const _weekdayAbbr = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];

// ─────────────────────────────────────────────────────────────────────────────
// EventCard
// ─────────────────────────────────────────────────────────────────────────────

class EventCard extends StatefulWidget {
  final OrganizationEventMembershipModel event;
  final Future<void> Function()? onAvailable;
  final Future<void> Function()? onUnavailable;
  final Future<void> Function()? onLeaveSchedule;
  final VoidCallback? onTap;

  const EventCard({
    super.key,
    required this.event,
    this.onAvailable,
    this.onUnavailable,
    this.onLeaveSchedule,
    this.onTap,
  });

  @override
  State<EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<EventCard> {
  bool _isLoadingAvailable   = false;
  bool _isLoadingUnavailable = false;
  bool _isLoadingLeave       = false;

  bool get _isAnyLoading =>
      _isLoadingAvailable || _isLoadingUnavailable || _isLoadingLeave;

  // ── Accent color by membership status ────────────────────────────
  Color get _accentColor => switch (widget.event.membershipStatus) {
        OrganizationEventMembershipStatus.assigned => AppTheme.primaryColor,
        OrganizationEventMembershipStatus.pending =>
          switch (widget.event.membershipAvailabilityStatus) {
            OrganizationEventMembershipAvailabilityStatus.available =>
              const Color(0xFF059669),
            OrganizationEventMembershipAvailabilityStatus.unavailable =>
              const Color(0xFFDC2626),
            OrganizationEventMembershipAvailabilityStatus.notAnswered ||
            null =>
              AppTheme.secondaryColor,
          },
        OrganizationEventMembershipStatus.notAssigned ||
        OrganizationEventMembershipStatus.expired ||
        null =>
          const Color(0xFFCBD5E1),
        OrganizationEventMembershipStatus.awaitingAssignment ||
            OrganizationEventMembershipStatus.awaitingDraw =>
          const Color(0xFF8B5CF6),
      };

  // ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final event      = widget.event;
    final isCanceled = event.status == OrganizationEventStatus.canceled;

    final showUrgent = !isCanceled &&
        event.availabilityLockEpochSeconds <= 86400 &&
        event.availabilityLockEpochSeconds > 0;

    final showInProgress = event.status == OrganizationEventStatus.inProgress;

    return Opacity(
      opacity: isCanceled ? 0.5 : 1.0,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          clipBehavior: Clip.hardEdge,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Barra de status colorida ──────────────────────
                Container(width: 5, color: _accentColor),

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
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF94A3B8),
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        '${event.startTime.day}',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1E293B),
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
                  color: const Color(0xFFF1F5F9),
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
                                UrgentBadge(event: event),
                                const SizedBox(width: 6),
                              ],
                              if (showInProgress) EventStatusBadge(event.status),
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
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(
                                      decoration: isCanceled
                                          ? TextDecoration.lineThrough
                                          : null,
                                    ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: const Color(0xFFE2E8F0)),
                              ),
                              child: Text(
                                '${DateFormat('HH:mm').format(event.startTime)} – ${DateFormat('HH:mm').format(event.endTime)}',
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF334155),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 4),

                        // ── Localização ───────────────────────────
                        Row(
                          children: [
                            const Icon(Icons.location_on_rounded,
                                size: 12, color: Color(0xFF94A3B8)),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                event.location,
                                style: Theme.of(context).textTheme.bodySmall,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),
                        const Divider(height: 1, color: Color(0xFFF1F5F9)),
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
    final event = widget.event;

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
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
                fontSize: 11,
              ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ActionButton(
                label: 'Disponível',
                icon: Icons.check_rounded,
                outlined: true,
                schema: ActionButtonSchema.success,
                size: ActionButtonSize.sm,
                isLoading: _isLoadingAvailable,
                onPressed: (widget.onAvailable == null ||
                        (_isAnyLoading && !_isLoadingAvailable))
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
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ActionButton(
                label: 'Indisponível',
                icon: Icons.close_rounded,
                outlined: true,
                schema: ActionButtonSchema.ghost,
                size: ActionButtonSize.sm,
                isLoading: _isLoadingUnavailable,
                onPressed: (widget.onUnavailable == null ||
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
        StatusCircle(
          bgColor: const Color(0xFFECFDF5),
          borderColor: const Color(0xFFD1FAE5),
          icon: Icons.check_rounded,
          iconColor: const Color(0xFF059669),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Você está disponível',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                      fontSize: 11,
                    ),
              ),
              Text(
                'Aguardando escalação',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(fontSize: 10),
              ),
            ],
          ),
        ),
        ActionButton(
          label: 'Indisponível',
          icon: Icons.close_rounded,
          outlined: true,
          schema: ActionButtonSchema.danger,
          size: ActionButtonSize.xs,
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
        StatusCircle(
          bgColor: const Color(0xFFFEF2F2),
          borderColor: const Color(0xFFFEE2E2),
          icon: Icons.close_rounded,
          iconColor: const Color(0xFFDC2626),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Você está indisponível',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                      fontSize: 11,
                    ),
              ),
              Text(
                'Toque para ficar disponível',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(fontSize: 10),
              ),
            ],
          ),
        ),
        ActionButton(
          label: 'Disponível',
          icon: Icons.check_rounded,
          outlined: true,
          schema: ActionButtonSchema.success,
          size: ActionButtonSize.xs,
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
    final event = widget.event;

    if (event.status == OrganizationEventStatus.canceled) {
      return const InfoBanner(
        bgColor: Color(0xFFFEF2F2),
        borderColor: Color(0xFFFEE2E2),
        icon: Icons.close_rounded,
        iconColor: Color(0xFFDC2626),
        label: 'Evento Cancelado',
        sublabel: 'Este evento foi cancelado pelo admin.',
      );
    }

    if (event.status == OrganizationEventStatus.completed) {
      final formattedDate =
          DateFormat("d 'de' MMMM 'às' HH:mm", 'pt_BR').format(event.endTime);
      return InfoBanner(
        bgColor: const Color(0xFFF8FAFC),
        borderColor: const Color(0xFFE2E8F0),
        icon: Icons.check_circle_outline_rounded,
        iconColor: const Color(0xFF64748B),
        label: 'Evento Concluído',
        sublabel: 'Finalizado em $formattedDate',
        labelColor: AppTheme.textSecondary,
      );
    }

    if (!event.allowAssignment) {
      if (event.membershipStatus ==
          OrganizationEventMembershipStatus.assigned) {
        return const InfoBanner(
          bgColor: Color(0xFFECFDF5),
          borderColor: Color(0xFFD1FAE5),
          icon: Icons.check_rounded,
          iconColor: Color(0xFF059669),
          label: 'Você está escalado',
          sublabel: 'Este evento está fechado para novas escalas.',
        );
      }
      return const InfoBanner(
        bgColor: Color(0xFFF8FAFC),
        borderColor: Color(0xFFE2E8F0),
        icon: Icons.lock_outline_rounded,
        iconColor: Color(0xFF94A3B8),
        label: 'Não escalado',
        sublabel: 'Este evento está fechado para novas escalas.',
        labelColor: AppTheme.textSecondary,
      );
    }

    return switch (event.membershipStatus) {
      OrganizationEventMembershipStatus.assigned => Row(
          children: [
            StatusCircle(
              bgColor: const Color(0xFFECFDF5),
              borderColor: const Color(0xFFD1FAE5),
              icon: Icons.check_rounded,
              iconColor: const Color(0xFF059669),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Você está escalado',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                      fontSize: 11,
                    ),
              ),
            ),
            if (event.membershipAvailabilityStatus ==
                OrganizationEventMembershipAvailabilityStatus.available)
              ActionButton(
                label: 'Sair',
                icon: Icons.logout_rounded,
                outlined: true,
                schema: ActionButtonSchema.ghost,
                size: ActionButtonSize.xs,
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
              ParticipantsChip(count: event.participantsCount),
          ],
        ),
      OrganizationEventMembershipStatus.awaitingAssignment => const InfoBanner(
          bgColor: Color(0xFFF5F3FF),
          borderColor: Color(0xFFEDE9FE),
          icon: Icons.hourglass_top_rounded,
          iconColor: Color(0xFF7C3AED),
          label: 'Aguardando escalação',
          sublabel: 'Você será escalado em breve',
        ),
      OrganizationEventMembershipStatus.awaitingDraw => const InfoBanner(
          bgColor: Color(0xFFF5F3FF),
          borderColor: Color(0xFFEDE9FE),
          icon: Icons.casino_rounded,
          iconColor: Color(0xFF7C3AED),
          label: 'Aguardando sorteio',
          sublabel: 'Escalação será definida por sorteio',
        ),
      OrganizationEventMembershipStatus.notAssigned || null => const InfoBanner(
          bgColor: Color(0xFFF8FAFC),
          borderColor: Color(0xFFE2E8F0),
          icon: Icons.close_rounded,
          iconColor: Color(0xFF94A3B8),
          label: 'Não escalado',
          sublabel: 'Você não está nesta escala.',
          labelColor: AppTheme.textSecondary,
        ),
      OrganizationEventMembershipStatus.expired => const InfoBanner(
          bgColor: Color(0xFFFEF2F2),
          borderColor: Color(0xFFFECACA),
          icon: Icons.timer_off_rounded,
          iconColor: Color(0xFFDC2626),
          label: 'Resposta expirada',
          sublabel: 'O prazo para responder passou.',
          labelColor: AppTheme.textSecondary,
        ),
      OrganizationEventMembershipStatus.pending => const SizedBox.shrink(),
    };
  }
}











