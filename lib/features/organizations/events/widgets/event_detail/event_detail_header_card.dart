import 'package:convoquei_app/core/services/toast_feedback_service.dart';
import 'package:convoquei_app/core/utils/date_locale_pt.dart';
import 'package:convoquei_app/design_system/ds.dart';
import 'package:convoquei_app/features/organizations/events/models/enums/organization_event_assignment_mode.dart';
import 'package:convoquei_app/features/organizations/events/models/enums/organization_event_membership_availability_status.dart';
import 'package:convoquei_app/features/organizations/events/models/enums/organization_event_membership_status.dart';
import 'package:convoquei_app/features/organizations/events/models/enums/organization_event_status.dart';
import 'package:convoquei_app/features/organizations/events/models/organization_event_details_model.dart';
import 'package:convoquei_app/features/organizations/events/providers/answer_availability_provider.dart';
import 'package:convoquei_app/features/organizations/events/providers/find_event_details_by_id_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ─── Public API ───────────────────────────────────────────────────────────────

class EventDetailHeaderCard extends ConsumerStatefulWidget {
  const EventDetailHeaderCard({
    super.key,
    required this.details,
    required this.organizationId,
    required this.eventId,
    this.currentMemberId,
    this.onOptions,
  });

  final OrganizationEventDetailsModel details;
  final String organizationId;
  final String eventId;
  final String? currentMemberId;
  final VoidCallback? onOptions;

  @override
  ConsumerState<EventDetailHeaderCard> createState() =>
      _EventDetailHeaderCardState();
}

class _EventDetailHeaderCardState extends ConsumerState<EventDetailHeaderCard> {
  bool _answerLoading = false;

  OrganizationEventParticipantModel? get _me => widget.details.participants
      .where((p) => p.memberId == widget.currentMemberId)
      .firstOrNull;

  Future<void> _answer(bool available) async {
    setState(() => _answerLoading = true);
    try {
      await ref
          .read(answerAvailabilityProvider.notifier)
          .answer(
            organizationId: widget.organizationId,
            eventId: widget.eventId,
            available: available,
          );

      if (!mounted) return;

      ref.invalidate(
        findEventDetailsByIdProvider(
          organizationId: widget.organizationId,
          eventId: widget.eventId,
        ),
      );
    } catch (_) {
      if (!mounted) return;

      ToastFeedbackService.showToast(
        context,
        'Não foi possível registrar disponibilidade.',
        ToastType.error,
      );
    } finally {
      if (mounted) setState(() => _answerLoading = false);
    }
  }

  String get _scaleTypeLabel {
    if (details.calledFunctions.isEmpty) {
      return details.assignmentMode == OrganizationEventAssignmentMode.manual
          ? 'Escala Manual'
          : 'Escala Automática';
    }
    final allMatch = details.calledFunctions.every(
      (f) => f.assignmentMode == details.assignmentMode,
    );
    if (allMatch) {
      return details.assignmentMode == OrganizationEventAssignmentMode.manual
          ? 'Escala Manual'
          : 'Escala Automática';
    }
    return 'Escala Híbrida';
  }

  ({Color color, Color tint}) get _scaleColors {
    final label = _scaleTypeLabel;
    if (label == 'Escala Automática') {
      return (color: context.colors.success, tint: context.colors.successTint);
    }
    if (label == 'Escala Híbrida') {
      return (color: context.colors.info, tint: context.colors.infoTint);
    }
    return (color: context.colors.warning, tint: context.colors.warningTint);
  }

  OrganizationEventDetailsModel get details => widget.details;

  static String _formatTime(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final sc = _scaleColors;

    return DSCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ScaleBadge(
                      label: _scaleTypeLabel,
                      color: sc.color,
                      tint: sc.tint,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      details.name,
                      style: context.textStyles.titleLarge,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_rounded,
                          size: 13,
                          color: context.colors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            details.location,
                            style: context.textStyles.bodySmall.copyWith(
                              color: context.colors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _DateSquare(date: details.startAt),
                  if (widget.onOptions != null) ...[
                    const SizedBox(height: 4),
                    SizedBox(
                      width: 32,
                      height: 32,
                      child: IconButton(
                        icon: const Icon(Icons.more_vert_rounded, size: 20),
                        onPressed: widget.onOptions,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                        color: context.colors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),

          // ── Divider + time grid ────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1, color: context.colors.border),
          ),
          Row(
            children: [
              _TimeInfo(
                icon: Icons.access_time_rounded,
                label: 'Início',
                value: _formatTime(details.startAt),
              ),
              const SizedBox(width: 20),
              _TimeInfo(
                icon: Icons.flag_rounded,
                label: 'Fim',
                value: _formatTime(details.endAt),
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.only(top: 14),
            child: Divider(height: 1, color: context.colors.border),
          ),
          const SizedBox(height: 12),

          _PersonalStatusRow(
            currentParticipantMembership: _me,
            details: widget.details,
            loading: _answerLoading,
            onAvailable: () => _answer(true),
            onUnavailable: () => _answer(false),
          ),
        ],
      ),
    );
  }
}

// ─── Scale badge ──────────────────────────────────────────────────────────────

class _ScaleBadge extends StatelessWidget {
  const _ScaleBadge({
    required this.label,
    required this.color,
    required this.tint,
  });

  final String label;
  final Color color;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: tint,
        borderRadius: DSRadius.allSm,
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 0.6,
          height: 1.2,
        ),
      ),
    );
  }
}

// ─── Date square ─────────────────────────────────────────────────────────────

class _DateSquare extends StatelessWidget {
  const _DateSquare({required this.date});
  final DateTime date;

  String _monthAbbr() {
    final name = DateLocalePt.monthNames[date.month - 1];
    return name[0].toUpperCase() + name.substring(1, 3);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: context.colors.primaryTint,
        borderRadius: DSRadius.allMd,
        border: Border.all(
          color: context.colors.primary.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _monthAbbr(),
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: context.colors.primary,
              letterSpacing: 0.5,
              height: 1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            date.day.toString(),
            style: context.textStyles.displayMedium.copyWith(
              color: context.colors.primary,
              fontSize: 20,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Time info ────────────────────────────────────────────────────────────────

class _TimeInfo extends StatelessWidget {
  const _TimeInfo({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: context.colors.textSecondary),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label.toUpperCase(),
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: context.colors.textSecondary,
                letterSpacing: 0.5,
                height: 1,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: context.textStyles.labelMedium.copyWith(
                color: context.colors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PersonalStatusRow extends StatelessWidget {
  const _PersonalStatusRow({
    required this.currentParticipantMembership,
    required this.details,
    required this.loading,
    required this.onAvailable,
    required this.onUnavailable,
  });

  final OrganizationEventParticipantModel? currentParticipantMembership;
  final OrganizationEventDetailsModel details;
  final bool loading;
  final VoidCallback onAvailable;
  final VoidCallback onUnavailable;

  bool get _availabilityOpen =>
      details.status == OrganizationEventStatus.scheduled &&
      details.availabilityLockEpochSeconds > 0;

  @override
  Widget build(BuildContext context) {
    final m = currentParticipantMembership;
    final open = _availabilityOpen;

    Color dotColor;
    bool pulse;
    String text;
    String? boldSuffix;
    List<Widget> actions = const [];

    if (m == null) {
      dotColor = context.colors.textSecondary;
      pulse = false;
      text = 'Você não foi convocado para este evento.';
      boldSuffix = null;
    } else if (m.status == OrganizationEventMembershipStatus.invited) {
      // O invite sobrescreve a disponibilidade. O backend hoje não invita
      // indisponíveis, mas a lógica aqui não depende disso — basta o status
      // chegar como `invited` para mostrar o UI correto.
      dotColor = context.colors.warning;
      pulse = true;
      text = 'Sua participação foi solicitada';
      boldSuffix = m.function != null ? ': ${m.function}' : null;
      actions = [
        const SizedBox(width: 8),
        GestureDetector(
          onTap: onAvailable,
          child: Text(
            'Aceitar convite',
            style: context.textStyles.labelSmall.copyWith(
              color: context.colors.success,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Text(
            '|',
            style: TextStyle(color: context.colors.border, fontSize: 12),
          ),
        ),
        GestureDetector(
          onTap: onUnavailable,
          child: Text(
            'Recusar',
            style: context.textStyles.labelSmall.copyWith(
              color: context.colors.danger,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ];
    } else if (m.availabilityStatus ==
        OrganizationEventMembershipAvailabilityStatus.notAnswered) {
      if (open) {
        dotColor = context.colors.warning;
        pulse = true;
        text = 'Você ainda não respondeu.';
        boldSuffix = null;
        actions = [
          const SizedBox(width: 8),
          Builder(
            builder: (ctx) => GestureDetector(
              onTap: () async {
                final result = await _AnswerAvailabilityBottomSheet.show(
                  ctx,
                  details.name,
                  details.startAt,
                );
                if (result == true) onAvailable();
                if (result == false) onUnavailable();
              },
              child: Text(
                'Responder',
                style: ctx.textStyles.labelSmall.copyWith(
                  color: ctx.colors.success,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ];
      } else {
        dotColor = context.colors.textSecondary;
        pulse = false;
        text = 'Prazo de resposta encerrado.';
        boldSuffix = null;
      }
    } else if (m.availabilityStatus ==
        OrganizationEventMembershipAvailabilityStatus.unavailable) {
      if (open) {
        dotColor = context.colors.danger;
        pulse = false;
        text = 'Você informou que não pode participar.';
        boldSuffix = null;
        actions = [
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onAvailable,
            child: Text(
              'Disponibilizar-me',
              style: context.textStyles.labelSmall.copyWith(
                color: context.colors.success,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ];
      } else {
        dotColor = context.colors.danger;
        pulse = false;
        text = 'Você não pode participar deste evento.';
        boldSuffix = null;
      }
    } else {
      // availabilityStatus == available — derivar do status de participação
      switch (m.status) {
        case OrganizationEventMembershipStatus.awaitingAssignment:
          dotColor = context.colors.info;
          pulse = true;
          text = 'Disponível — aguardando escalação.';
          boldSuffix = null;
        case OrganizationEventMembershipStatus.assigned:
          dotColor = context.colors.success;
          pulse = true;
          text = 'Você foi escalado';
          boldSuffix = m.function != null ? ': ${m.function}' : null;
        case OrganizationEventMembershipStatus.notAssigned:
          dotColor = context.colors.textSecondary;
          pulse = false;
          text = 'Você não foi escalado para este evento.';
          boldSuffix = null;
        case OrganizationEventMembershipStatus.expired:
          dotColor = context.colors.danger;
          pulse = false;
          text = 'Prazo de disponibilidade expirado.';
          boldSuffix = null;
        default:
          dotColor = context.colors.warning;
          pulse = false;
          text = 'Status indefinido. Recarregue o evento.';
          boldSuffix = null;
      }
    }

    return Row(
      children: [
        _PulseDot(color: dotColor, pulse: pulse),
        const SizedBox(width: 8),
        Expanded(
          child: Text.rich(
            TextSpan(
              text: text,
              style: context.textStyles.bodySmall.copyWith(
                color: context.colors.textSecondary,
              ),
              children: [
                if (boldSuffix != null)
                  TextSpan(
                    text: boldSuffix,
                    style: context.textStyles.bodySmall.copyWith(
                      color: context.colors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (loading)
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: context.colors.primary,
              ),
            ),
          )
        else
          ...actions,
      ],
    );
  }
}

// ─── Answer availability bottom sheet ────────────────────────────────────────

class _AnswerAvailabilityBottomSheet extends DSBaseModal {
  const _AnswerAvailabilityBottomSheet({
    required this.eventName,
    required this.eventDate,
  });

  final String eventName;
  final DateTime eventDate;

  static Future<bool?> show(
    BuildContext context,
    String eventName,
    DateTime eventDate,
  ) =>
      DSBaseModal.show<bool>(
        context,
        _AnswerAvailabilityBottomSheet(
          eventName: eventName,
          eventDate: eventDate,
        ),
      );

  @override
  State<_AnswerAvailabilityBottomSheet> createState() =>
      _AnswerAvailabilityBottomSheetState();
}

class _AnswerAvailabilityBottomSheetState
    extends DSBaseModalState<_AnswerAvailabilityBottomSheet> {
  @override
  String? get titleText => 'Confirmar disponibilidade';

  @override
  List<Widget> buildBody(BuildContext context) {
    return [
      Padding(
        padding: const EdgeInsets.fromLTRB(
          DSSpacing.xl,
          0,
          DSSpacing.xl,
          DSSpacing.xl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DSCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.eventName,
                    style: context.textStyles.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(widget.eventDate),
                    style: context.textStyles.bodySmall.copyWith(
                      color: context.colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: DSSpacing.md),
            Text(
              'Você pode participar deste evento? Sua resposta ajuda a montar a escala.',
              style: context.textStyles.bodyMedium.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
            const SizedBox(height: DSSpacing.lg),
            DSButton(
              label: 'Sim, estou disponível',
              schema: DSButtonSchema.success,
              onPressed: () => DSBaseModal.hide(context, true),
            ),
            const SizedBox(height: DSSpacing.sm),
            DSButton(
              label: 'Não posso participar',
              schema: DSButtonSchema.danger,
              outlined: true,
              onPressed: () => DSBaseModal.hide(context, false),
            ),
          ],
        ),
      ),
    ];
  }

  String _formatDate(DateTime date) {
    const months = [
      'jan', 'fev', 'mar', 'abr', 'mai', 'jun',
      'jul', 'ago', 'set', 'out', 'nov', 'dez',
    ];
    const weekdays = ['seg', 'ter', 'qua', 'qui', 'sex', 'sáb', 'dom'];
    final weekday = weekdays[date.weekday - 1];
    final month = months[date.month - 1];
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$weekday, ${date.day} de $month às $hour:$minute';
  }
}

class _PulseDot extends StatefulWidget {
  const _PulseDot({required this.color, required this.pulse});
  final Color color;
  final bool pulse;

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
    );
    _opacity = Tween(
      begin: 0.35,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
    if (widget.pulse) _ctrl.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(_PulseDot old) {
    super.didUpdateWidget(old);
    if (widget.pulse && !_ctrl.isAnimating) {
      _ctrl.repeat(reverse: true);
    } else if (!widget.pulse && _ctrl.isAnimating) {
      _ctrl.stop();
      _ctrl.value = 1.0;
    }
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
        width: 8,
        height: 8,
        decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle),
      ),
    );
  }
}
