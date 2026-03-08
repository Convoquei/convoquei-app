import 'package:convoquei_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

enum EventStatus { scheduled, inProgress, completed, canceled }

enum ParticipantStatus {
  pending,
  awaitingAssignment,
  awaitingDraw,
  assigned,
  notAssigned,
}

enum AvailabilityStatus { notAnswered, available, unavailable }

class EventCard extends StatelessWidget {
  final String title;
  final String time;
  final String location;
  final EventStatus eventStatus;
  final ParticipantStatus participantStatus;
  final AvailabilityStatus availabilityStatus;
  final String? role;
  final int? memberCount;
  final bool hasUrgentAlert;
  final VoidCallback? onAvailable;
  final VoidCallback? onUnavailable;
  final VoidCallback? onRemoveAvailability;
  final VoidCallback? onRemoveUnavailability;
  final VoidCallback? onTap;

  const EventCard({
    super.key,
    required this.title,
    required this.time,
    required this.location,
    required this.eventStatus,
    required this.participantStatus,
    this.availabilityStatus = AvailabilityStatus.notAnswered,
    this.role,
    this.memberCount,
    this.hasUrgentAlert = false,
    this.onAvailable,
    this.onUnavailable,
    this.onRemoveAvailability,
    this.onRemoveUnavailability,
    this.onTap,
  });

  Color get _accentColor => switch (participantStatus) {
    ParticipantStatus.assigned => AppTheme.primaryColor,
    ParticipantStatus.pending => switch (availabilityStatus) {
      AvailabilityStatus.available => const Color(0xFF059669),
      AvailabilityStatus.unavailable => const Color(0xFFDC2626),
      AvailabilityStatus.notAnswered => AppTheme.secondaryColor,
    },
    ParticipantStatus.notAssigned => const Color(0xFFCBD5E1),
    ParticipantStatus.awaitingAssignment ||
    ParticipantStatus.awaitingDraw =>
    const Color(0xFF8B5CF6),
  };

  @override
  Widget build(BuildContext context) {
    final bool isCanceled = eventStatus == EventStatus.canceled;
    final bool showUrgent = hasUrgentAlert && !isCanceled;
    final bool showStatusBadge =
        eventStatus == EventStatus.completed || isCanceled;

    return Opacity(
      opacity: isCanceled ? 0.5 : 1.0,
      child: GestureDetector(
        onTap: onTap,
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
                        if (showUrgent || showStatusBadge) ...[
                          Row(
                            children: [
                              if (showUrgent) ...[
                                _UrgentBadge(),
                                const SizedBox(width: 6),
                              ],
                              if (showStatusBadge)
                                _EventStatusBadge(eventStatus),
                            ],
                          ),
                          const SizedBox(height: 8),
                        ],
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                title,
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
                                time,
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
                            Text(location,
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
    if (participantStatus != ParticipantStatus.pending) {
      return _buildStatusFooter(context);
    }

    // PENDING: footer depende da availability
    return switch (availabilityStatus) {
      AvailabilityStatus.notAnswered => _buildAvailabilityButtons(context),
      AvailabilityStatus.available => _buildAvailableConfirmed(context),
      AvailabilityStatus.unavailable => _buildUnavailableConfirmed(context),
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
              child: GestureDetector(
                onTap: onAvailable,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFD1FAE5)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_rounded,
                          size: 14, color: Color(0xFF059669)),
                      SizedBox(width: 6),
                      Text(
                        'Disponível',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF059669),
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: GestureDetector(
                onTap: onUnavailable,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFFEE2E2)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.close_rounded,
                          size: 14, color: Color(0xFFDC2626)),
                      SizedBox(width: 6),
                      Text(
                        'Indisponível',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFDC2626),
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                ),
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
                'Aguardando escalação pelo admin',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(fontSize: 10),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: onRemoveAvailability,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: const Text(
              'Desfazer',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Color(0xFF64748B),
                fontFamily: 'Inter',
              ),
            ),
          ),
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
        GestureDetector(
          onTap: onRemoveUnavailability,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFFEE2E2)),
            ),
            child: const Text(
              'Desfazer',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Color(0xFFDC2626),
                fontFamily: 'Inter',
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusFooter(BuildContext context) {
    return switch (participantStatus) {
      ParticipantStatus.assigned => Row(
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
                if (role != null)
                  Text(
                    'Função: $role',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(fontSize: 10),
                  ),
              ],
            ),
          ),
          if (memberCount != null)
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
                    '$memberCount membros',
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
      ParticipantStatus.awaitingAssignment => _InfoFooter(
        bgColor: const Color(0xFFF5F3FF),
        borderColor: const Color(0xFFEDE9FE),
        icon: Icons.hourglass_top_rounded,
        iconColor: const Color(0xFF7C3AED),
        label: 'Aguardando escalação',
        sublabel: 'Você será escalado em breve',
      ),
      ParticipantStatus.awaitingDraw => _InfoFooter(
        bgColor: const Color(0xFFF5F3FF),
        borderColor: const Color(0xFFEDE9FE),
        icon: Icons.casino_rounded,
        iconColor: const Color(0xFF7C3AED),
        label: 'Aguardando sorteio',
        sublabel: 'Escalação será definida por sorteio',
      ),
      ParticipantStatus.notAssigned => _InfoFooter(
        bgColor: const Color(0xFFF8FAFC),
        borderColor: const Color(0xFFE2E8F0),
        icon: Icons.lock_outline_rounded,
        iconColor: const Color(0xFF94A3B8),
        label: 'Escala Fechada',
        sublabel: 'Você não está nesta escala.',
        labelColor: AppTheme.textSecondary,
      ),
      ParticipantStatus.pending => const SizedBox.shrink(),
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
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFEE2E2)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.warning_amber_rounded,
              size: 12, color: Color(0xFFDC2626)),
          SizedBox(width: 4),
          Text(
            'A escala encerra em 2h',
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
  final EventStatus status;
  const _EventStatusBadge(this.status);

  @override
  Widget build(BuildContext context) {
    final (label, bg, fg) = switch (status) {
      EventStatus.completed =>
      ('Concluído', const Color(0xFFF8FAFC), const Color(0xFF64748B)),
      EventStatus.canceled =>
      ('Cancelado', const Color(0xFFFEF2F2), const Color(0xFFDC2626)),
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