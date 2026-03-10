import 'package:convoquei_app/core/theme/app_theme.dart';
import 'package:convoquei_app/core/widgets/action_button.dart';
import 'package:convoquei_app/features/organizations/events/models/enums/organization_event_assignment_mode.dart';
import 'package:convoquei_app/features/organizations/events/models/enums/organization_event_membership_availability_status.dart';
import 'package:convoquei_app/features/organizations/events/models/enums/organization_event_membership_status.dart';
import 'package:convoquei_app/features/organizations/events/models/enums/organization_event_status.dart';
import 'package:convoquei_app/features/organizations/events/models/orgnaization_event_membership_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EventCard extends StatefulWidget {
  final OrganizationEventMembershipModel event;
  final Future<void> Function()? onAvailable;
  final Future<void> Function()? onUnavailable;
  final Future<void> Function()? onRemoveAvailability;
  final Future<void> Function()? onRemoveUnavailability;
  final VoidCallback? onTap;

  const EventCard({
    super.key,
    required this.event,
    this.onAvailable,
    this.onUnavailable,
    this.onRemoveAvailability,
    this.onRemoveUnavailability,
    this.onTap,
  });

  @override
  State<EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<EventCard> {
  bool _isLoadingAvailable = false;
  bool _isLoadingUnavailable = false;
  bool _isLoadingUndo = false;

  bool get _isAnyLoading => _isLoadingAvailable || _isLoadingUnavailable || _isLoadingUndo;

  Color get _accentColor => switch (widget.event.membershipStatus) {
    OrganizationEventMembershipStatus.assigned => AppTheme.primaryColor,
    OrganizationEventMembershipStatus.pending => switch (widget.event.membershipAvailabilityStatus) {
      OrganizationEventMembershipAvailabilityStatus.available => const Color(0xFF059669),
      OrganizationEventMembershipAvailabilityStatus.unavailable => const Color(0xFFDC2626),
      OrganizationEventMembershipAvailabilityStatus.notAnswered || null => AppTheme.secondaryColor,
    },
    OrganizationEventMembershipStatus.notAssigned || null => const Color(0xFFCBD5E1),
    OrganizationEventMembershipStatus.awaitingAssignment ||
    OrganizationEventMembershipStatus.awaitingDraw =>
    const Color(0xFF8B5CF6)
  };

  @override
  Widget build(BuildContext context) {
    final bool isCanceled = widget.event.status == OrganizationEventStatus.canceled;
    final bool showUrgent =
        !isCanceled &&
            widget.event.availabilityLockEpochSeconds <= 86400 &&
            widget.event.availabilityLockEpochSeconds > 0;
    final bool showEventBadge = widget.event.status == OrganizationEventStatus.inProgress ||
        widget.event.status == OrganizationEventStatus.completed;

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
                Container(width: 5, color: _accentColor),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (showUrgent || showEventBadge) ...[
                          Row(
                            children: [
                              if (showUrgent) ...[
                                _UrgentBadge(event: widget.event,),
                                const SizedBox(width: 6),
                              ],

                              if (showEventBadge)
                                _EventStatusBadge(widget.event.status),
                            ],
                          ),
                          const SizedBox(height: 8),
                        ],
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                widget.event.name,
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
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: const Color(0xFFE2E8F0)),
                              ),
                              child: Text(
                                DateFormat('HH:mm', 'pt_BR').format(widget.event.startTime),
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF334155),
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.location_on_rounded,
                                size: 12, color: Color(0xFF94A3B8)),
                            const SizedBox(width: 4),
                            Text(widget.event.location,
                                style:
                                Theme.of(context).textTheme.bodySmall),
                          ],
                        ),
                        const SizedBox(height: 10),
                        const Divider(height: 1, color: Color(0xFFF1F5F9)),
                        const SizedBox(height: 10),
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

  Widget _buildFooter(BuildContext context) {
    // Qualquer status que não seja PENDING tem prioridade
    if (widget.event.membershipStatus != OrganizationEventMembershipStatus.pending || !widget.event.allowAssignment) {
      return _buildStatusFooter(context);
    }

    // PENDING: footer depende da availability
    return switch (widget.event.membershipAvailabilityStatus) {
      OrganizationEventMembershipAvailabilityStatus.notAnswered => _buildAvailabilityButtons(context),
      OrganizationEventMembershipAvailabilityStatus.available => _buildAvailableConfirmed(context),
      OrganizationEventMembershipAvailabilityStatus.unavailable => _buildUnavailableConfirmed(context),
      null => SizedBox.shrink(),
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
                onPressed: (widget.onAvailable == null || (_isAnyLoading && !_isLoadingAvailable))
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
                schema: ActionButtonSchema.danger,
                size: ActionButtonSize.sm,
                isLoading: _isLoadingUnavailable,
                onPressed: (widget.onUnavailable == null || (_isAnyLoading && !_isLoadingUnavailable))
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
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAvailableConfirmed(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: const Color(0xFFECFDF5),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFD1FAE5)),
          ),
          child: const Icon(Icons.check_rounded,
              size: 14, color: Color(0xFF059669)),
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
          label: 'Desfazer',
          outlined: true,
          schema: ActionButtonSchema.ghost,
          size: ActionButtonSize.xs,
          isLoading: _isLoadingUndo,
          fullWidth: false,
          onPressed: (widget.onRemoveAvailability == null || _isAnyLoading)
              ? null
              : () async {
                  setState(() => _isLoadingUndo = true);
                  try {
                    await widget.onRemoveAvailability!();
                  } finally {
                    if (mounted) setState(() => _isLoadingUndo = false);
                  }
                },
        ),
      ],
    );
  }

  Widget _buildUnavailableConfirmed(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: const Color(0xFFFEF2F2),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFFEE2E2)),
          ),
          child: const Icon(Icons.close_rounded,
              size: 14, color: Color(0xFFDC2626)),
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
                'Toque em desfazer para alterar',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(fontSize: 10),
              ),
            ],
          ),
        ),
        ActionButton(
          label: 'Desfazer',
          outlined: true,
          schema: ActionButtonSchema.ghost,
          size: ActionButtonSize.xs,
          isLoading: _isLoadingUndo,
          fullWidth: false,
          onPressed: (widget.onRemoveUnavailability == null || _isAnyLoading)
              ? null
              : () async {
                  setState(() => _isLoadingUndo = true);
                  try {
                    await widget.onRemoveUnavailability!();
                  } finally {
                    if (mounted) setState(() => _isLoadingUndo = false);
                  }
                },
        ),
      ],
    );
  }

  Widget _buildStatusFooter(BuildContext context) {

    if (widget.event.status == OrganizationEventStatus.canceled) {
      return _InfoFooter(
        bgColor: const Color(0xFFFEF2F2),
        borderColor: const Color(0xFFFEE2E2),
        icon: Icons.close_rounded,
        iconColor: const Color(0xFFDC2626),
        label: 'Evento Cancelado',
        sublabel: 'Este evento foi cancelado pelo admin.',
      );
    }

    if (!widget.event.allowAssignment) {
      return _InfoFooter(
        bgColor: const Color(0xFFF8FAFC),
        borderColor: const Color(0xFFE2E8F0),
        icon: Icons.lock_outline_rounded,
        iconColor: const Color(0xFF94A3B8),
        label: 'Escala Trancada',
        sublabel: 'Este evento não permite escalação.',
        labelColor: AppTheme.textSecondary,
      );
    }

    return switch (widget.event.membershipStatus) {
      OrganizationEventMembershipStatus.assigned => Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: const Color(0xFFECFDF5),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFD1FAE5)),
            ),
            child: const Icon(Icons.check_rounded,
                size: 14, color: Color(0xFF059669)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Você está escalado',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                    fontSize: 11,
                  ),
                ),
                // if (role != null)
                //   Text(
                //     'Função: $role',
                //     style: Theme.of(context)
                //         .textTheme
                //         .bodySmall
                //         ?.copyWith(fontSize: 10),
                //   ),
              ],
            ),
          ),
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.people_rounded,
                    size: 12, color: Color(0xFF64748B)),
                const SizedBox(width: 4),
                Text(
                  '${widget.event.participantsCount} membros',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      OrganizationEventMembershipStatus.awaitingAssignment => _InfoFooter(
        bgColor: const Color(0xFFF5F3FF),
        borderColor: const Color(0xFFEDE9FE),
        icon: Icons.hourglass_top_rounded,
        iconColor: const Color(0xFF7C3AED),
        label: 'Aguardando escalação',
        sublabel: 'Você será escalado em breve',
      ),
      OrganizationEventMembershipStatus.awaitingDraw => _InfoFooter(
        bgColor: const Color(0xFFF5F3FF),
        borderColor: const Color(0xFFEDE9FE),
        icon: Icons.casino_rounded,
        iconColor: const Color(0xFF7C3AED),
        label: 'Aguardando sorteio',
        sublabel: 'Escalação será definida por sorteio',
      ),
      OrganizationEventMembershipStatus.notAssigned || null => _InfoFooter(
        bgColor: const Color(0xFFF8FAFC),
        borderColor: const Color(0xFFE2E8F0),
        icon: Icons.close_rounded,
        iconColor: const Color(0xFF94A3B8),
        label: 'Não escalado',
        sublabel: 'Você não está nesta escala.',
        labelColor: AppTheme.textSecondary,
      ),
      OrganizationEventMembershipStatus.pending => const SizedBox.shrink(),
    };
  }
}

class _InfoFooter extends StatelessWidget {
  final Color bgColor;
  final Color borderColor;
  final IconData icon;
  final Color iconColor;
  final String label;
  final String sublabel;
  final Color? labelColor;

  const _InfoFooter({
    required this.bgColor,
    required this.borderColor,
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.sublabel,
    this.labelColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
            border: Border.all(color: borderColor),
          ),
          child: Icon(icon, size: 14, color: iconColor),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: labelColor ?? AppTheme.textPrimary,
                fontSize: 11,
              ),
            ),
            Text(
              sublabel,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(fontSize: 10),
            ),
          ],
        ),
      ],
    );
  }
}

class _UrgentBadge extends StatelessWidget {
  final OrganizationEventMembershipModel event;

  const _UrgentBadge({required this.event});

  String formatRemaining(Duration duration) {
    if (duration.inDays > 0) {
      return Intl.plural(
        duration.inDays,
        one: '1 dia',
        other: '${duration.inDays} dias',
      );
    }

    if (duration.inHours > 0) {
      return Intl.plural(
        duration.inHours,
        one: '1 hora',
        other: '${duration.inHours} horas',
      );
    }

    if (duration.inMinutes > 0) {
      return Intl.plural(
        duration.inMinutes,
        one: '1 minuto',
        other: '${duration.inMinutes} minutos',
      );
    }

    return 'menos de 1 minuto';
  }

  String _buildEventText() {
    if (event.availabilityLockEpochSeconds <= 0) {
      return 'A escala está fechada';
    }

    if (event.assignmentMode == OrganizationEventAssignmentMode.automatic)
      return 'A escala será fechada em ${formatRemaining(event.durationBeforeStartEvent)}';
    else if (event.assignmentMode == OrganizationEventAssignmentMode.manual)
      return 'A disponibilidade sera bloqueada em ${formatRemaining(event.durationBeforeStartEvent)}';

    return 'A escala será fechada em ${formatRemaining(event.durationBeforeStartEvent)}';
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFEE2E2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.warning_amber_rounded,
              size: 12, color: Color(0xFFDC2626)),
          SizedBox(width: 4),
          Text(
            _buildEventText(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Color(0xFFDC2626),
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }
}

class _EventStatusBadge extends StatelessWidget {
  final OrganizationEventStatus status;
  const _EventStatusBadge(this.status);

  @override
  Widget build(BuildContext context) {
    final (label, bg, fg) = switch (status) {
      OrganizationEventStatus.completed => ('Concluído', const Color(0xFFF8FAFC), const Color(0xFF64748B)),
      OrganizationEventStatus.inProgress => ('Em andamento', const Color(0xFFECFDF5), const Color(0xFF059669)),
      _ => ('', Colors.transparent, Colors.transparent),
    };

    if (label.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: fg,
          fontFamily: 'Inter',
        ),
      ),
    );
  }
}