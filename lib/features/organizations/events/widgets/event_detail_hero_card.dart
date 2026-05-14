import 'package:convoquei_app/design_system/ds.dart';
import 'package:convoquei_app/core/utils/date_locale_pt.dart';
import 'package:convoquei_app/features/organizations/events/models/enums/organization_event_assignment_mode.dart';
import 'package:convoquei_app/features/organizations/events/models/enums/organization_event_status.dart';
import 'package:convoquei_app/features/organizations/events/models/organization_event_details_model.dart';
import 'package:flutter/material.dart';

/// Card hero da tela de detalhes do evento.
///
/// Exibe barra lateral colorida por status, tags de status e modo de aprovação,
/// nome do evento, data e local.
class EventDetailHeroCard extends StatelessWidget {
  final OrganizationEventDetailsModel details;
  final VoidCallback? onOptions;

  const EventDetailHeroCard({super.key, required this.details, this.onOptions});

  Color _accentColor(BuildContext context) => switch (details.status) {
        OrganizationEventStatus.scheduled => context.colors.warning,
        OrganizationEventStatus.inProgress => context.colors.info,
        OrganizationEventStatus.completed => context.colors.success,
        OrganizationEventStatus.canceled => context.colors.danger,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: DSRadius.all(24),
        border: Border.all(color: context.colors.border),
        boxShadow: DSElevation.sm,
      ),
      clipBehavior: Clip.hardEdge,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 6, color: _accentColor(context)),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _StatusRow(details: details, onOptions: onOptions),
                    const SizedBox(height: 10),
                    Text(
                      details.name,
                      style: context.textStyles.displayMedium?.copyWith(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _InfoRow(
                      icon: Icons.calendar_today_rounded,
                      primaryText: _formatDate(details.startAt),
                      secondaryText: _formatTime(details.startAt, details.endAt),
                    ),
                    const SizedBox(height: 8),
                    _InfoRow(
                      icon: Icons.location_on_rounded,
                      primaryText: details.location,
                    ),
                    const SizedBox(height: 12),
                    _AssignmentModeTag(mode: details.assignmentMode),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _formatDate(DateTime date) {
    final weekday = DateLocalePt.weekdayNames[date.weekday - 1];
    final rawMonth = DateLocalePt.monthNames[date.month - 1];
    final month = rawMonth[0].toUpperCase() + rawMonth.substring(1);
    return '$weekday, ${date.day} de $month';
  }

  static String _formatTime(DateTime start, DateTime end) {
    final s =
        '${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}';
    final e =
        '${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}';
    return '$s às $e';
  }
}

// ─── Status Row ───────────────────────────────────────────────────────────────

class _StatusRow extends StatelessWidget {
  final OrganizationEventDetailsModel details;
  final VoidCallback? onOptions;

  const _StatusRow({required this.details, this.onOptions});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _EventStatusTag(status: details.status),
        if (onOptions != null)
          SizedBox(
            width: 32,
            height: 32,
            child: IconButton(
              icon: const Icon(Icons.more_vert_rounded, size: 20),
              onPressed: onOptions,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              color: context.colors.textSecondary,
            ),
          ),
      ],
    );
  }
}

class _EventStatusTag extends StatelessWidget {
  final OrganizationEventStatus status;

  const _EventStatusTag({required this.status});

  ({String label, Color bg, Color border, Color color}) _config(
          BuildContext context) =>
      switch (status) {
        OrganizationEventStatus.scheduled => (
          label: 'Em Aberto',
          bg: context.colors.warningTint,
          border: context.colors.warning.withValues(alpha: 0.4),
          color: context.colors.warning,
        ),
        OrganizationEventStatus.inProgress => (
          label: 'Em Andamento',
          bg: context.colors.infoTint,
          border: context.colors.info.withValues(alpha: 0.4),
          color: context.colors.info,
        ),
        OrganizationEventStatus.completed => (
          label: 'Finalizado',
          bg: context.colors.successTint,
          border: context.colors.success.withValues(alpha: 0.4),
          color: context.colors.success,
        ),
        OrganizationEventStatus.canceled => (
          label: 'Cancelado',
          bg: context.colors.dangerTint,
          border: context.colors.danger.withValues(alpha: 0.4),
          color: context.colors.danger,
        ),
      };

  @override
  Widget build(BuildContext context) {
    final c = _config(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: c.bg,
        borderRadius: DSRadius.allSm,
        border: Border.all(color: c.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (status == OrganizationEventStatus.scheduled) ...[
            _PulseDot(color: c.color),
            const SizedBox(width: 5),
          ],
          Text(
            c.label.toUpperCase(),
            style: context.textStyles.labelSmall?.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: c.color,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _PulseDot extends StatefulWidget {
  final Color color;

  const _PulseDot({required this.color});

  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _opacity = Tween(begin: 0.35, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: Container(
        width: 6,
        height: 6,
        decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle),
      ),
    );
  }
}

class _AssignmentModeTag extends StatelessWidget {
  final OrganizationEventAssignmentMode mode;

  const _AssignmentModeTag({required this.mode});

  @override
  Widget build(BuildContext context) {
    final label = mode == OrganizationEventAssignmentMode.manual
        ? 'Modo Manual'
        : 'Modo Automático';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: context.colors.surfaceSubtle,
        borderRadius: DSRadius.allSm,
        border: Border.all(color: context.colors.border),
      ),
      child: Text(
        label,
        style: context.textStyles.labelSmall?.copyWith(
          fontWeight: FontWeight.w700,
          color: context.colors.textPrimary,
        ),
      ),
    );
  }
}

// ─── Info Row ─────────────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String primaryText;
  final String? secondaryText;

  const _InfoRow({
    required this.icon,
    required this.primaryText,
    this.secondaryText,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: context.colors.surfaceSubtle,
            shape: BoxShape.circle,
            border: Border.all(color: context.colors.border),
          ),
          child: Icon(icon, size: 15, color: context.colors.textSecondary),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                primaryText,
                style: context.textStyles.labelMedium?.copyWith(
                  color: context.colors.textPrimary,
                ),
              ),
              if (secondaryText != null)
                Text(
                  secondaryText!,
                  style: context.textStyles.labelSmall,
                ),
            ],
          ),
        ),
      ],
    );
  }
}
