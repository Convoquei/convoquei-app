import 'package:convoquei_app/app/router.dart';
import 'package:convoquei_app/core/network/exceptions/api_exception.dart';
import 'package:convoquei_app/core/services/toast_feedback_service.dart';
import 'package:convoquei_app/core/services/user_feedback_service.dart';
import 'package:convoquei_app/design_system/ds.dart';
import 'package:convoquei_app/features/home/widgets/action_tile.dart';
import 'package:convoquei_app/features/organizations/events/models/enums/organization_event_status.dart';
import 'package:convoquei_app/features/organizations/events/models/organization_event_details_model.dart';
import 'package:convoquei_app/features/organizations/events/providers/cancel_event_provider.dart';
import 'package:convoquei_app/features/organizations/events/providers/find_all_events_membership_provider.dart';
import 'package:convoquei_app/features/organizations/events/providers/find_event_details_by_id_provider.dart';
import 'package:convoquei_app/features/organizations/home/providers/next_assigned_event_provider.dart';
import 'package:convoquei_app/features/organizations/home/providers/next_pending_availability_event_provider.dart';
import 'package:convoquei_app/features/organizations/events/providers/manage_assignments_provider.dart';
import 'package:convoquei_app/features/organizations/events/services/event_share_service.dart';
import 'package:convoquei_app/features/organizations/events/widgets/event_detail/event_detail_header_card.dart';
import 'package:convoquei_app/features/organizations/events/widgets/event_detail/event_detail_participants_board.dart';
import 'package:convoquei_app/features/organizations/events/widgets/event_detail/event_detail_rules_view.dart';
import 'package:convoquei_app/features/organizations/home/widgets/team_toggle_widget.dart';
import 'package:convoquei_app/features/organizations/shared/models/enums/organization_permission.dart';
import 'package:convoquei_app/features/organizations/shared/models/organization_my_member_profile_model.dart';
import 'package:convoquei_app/features/organizations/shared/providers/organization_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

enum _EventDetailTab { people, rules }

class OrgEventDetailPage extends ConsumerWidget {
  final String organizationId;
  final String eventId;

  const OrgEventDetailPage({
    super.key,
    required this.organizationId,
    required this.eventId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailsAsync = ref.watch(
      findEventDetailsByIdProvider(
        organizationId: organizationId,
        eventId: eventId,
      ),
    );

    final canManageEvents =
        ref
            .watch(currentUserMembershipOrganizationProvider(organizationId))
            .asData
            ?.value
            .hasPermission(OrganizationPermissionEnum.manageEvents) ??
        false;

    final currentMember = ref
        .watch(currentUserMembershipOrganizationProvider(organizationId))
        .asData
        ?.value;

    return Scaffold(
      appBar: AppBar(title: const Text('Detalhes do Evento')),
      body: detailsAsync.when(
        loading: () => const DSLoadingScreen(
          label: 'Carregando evento...',
          description: 'Buscando detalhes e participantes',
          skeleton: DSLoadingSkeleton.details,
        ),
        error: (_, _) => Center(
          child: DSErrorRetryState(
            icon: Icons.event_busy_rounded,
            message: 'Não foi possível carregar o evento',
            description: 'Verifique sua conexão e tente novamente.',
            onRetry: () => ref.invalidate(
              findEventDetailsByIdProvider(
                organizationId: organizationId,
                eventId: eventId,
              ),
            ),
          ),
        ),
        data: (details) => _EventDetailContent(
          organizationId: organizationId,
          eventId: eventId,
          details: details,
          canManageEvents: canManageEvents,
          currentMember: currentMember,
        ),
      ),
    );
  }
}

// ─── Content ─────────────────────────────────────────────────────────────────

class _EventDetailContent extends ConsumerStatefulWidget {
  final String organizationId;
  final String eventId;
  final OrganizationEventDetailsModel details;
  final bool canManageEvents;
  final OrganizationMyMemberProfile? currentMember;

  const _EventDetailContent({
    required this.organizationId,
    required this.eventId,
    required this.details,
    required this.canManageEvents,
    required this.currentMember,
  });

  @override
  ConsumerState<_EventDetailContent> createState() =>
      _EventDetailContentState();
}

class _EventDetailContentState extends ConsumerState<_EventDetailContent> {
  _EventDetailTab _tab = _EventDetailTab.people;

  void _showOptionsModal() {
    _EventOptionsModal.show(
      context,
      organizationId: widget.organizationId,
      eventId: widget.eventId,
      eventName: widget.details.name,
      canManageEvents: widget.canManageEvents,
      eventStatus: widget.details.status,
      onShareEvent: _handleShare,
      onCancelEvent: _handleCancelEvent,
    );
  }

  Future<void> _handleShare() async {
    await EventShareService.share(
      organizationId: widget.organizationId,
      eventId: widget.eventId,
      details: widget.details,
    );
  }

  Future<void> _handleLockAssignments() async {
    final confirmed = await UserFeedbackService.confirm(
      context,
      title: 'Fechar Escalação',
      message:
          'Deseja fechar as respostas? Os membros não poderão mais confirmar disponibilidade.',
      confirmLabel: 'Fechar Escalação',
      cancelLabel: 'Voltar',
    );
    if (!confirmed || !mounted) return;

    try {
      await ref
          .read(manageAssignmentsProvider.notifier)
          .lock(organizationId: widget.organizationId, eventId: widget.eventId);
      if (!mounted) return;
      ref.invalidate(
        findEventDetailsByIdProvider(
          organizationId: widget.organizationId,
          eventId: widget.eventId,
        ),
      );
      ToastFeedbackService.showToast(
        context,
        'Escalação fechada com sucesso.',
        ToastType.success,
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ToastFeedbackService.showToast(context, e.userMessage, ToastType.error);
    }
  }

  Future<void> _handleReopenAssignments() async {
    try {
      await ref
          .read(manageAssignmentsProvider.notifier)
          .reopen(
            organizationId: widget.organizationId,
            eventId: widget.eventId,
          );
      if (!mounted) return;
      ref.invalidate(
        findEventDetailsByIdProvider(
          organizationId: widget.organizationId,
          eventId: widget.eventId,
        ),
      );
      ToastFeedbackService.showToast(
        context,
        'Escalação reaberta com sucesso.',
        ToastType.success,
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ToastFeedbackService.showToast(context, e.userMessage, ToastType.error);
    }
  }

  Future<void> _handleCancelEvent() async {
    final confirmed = await UserFeedbackService.confirm(
      context,
      title: 'Cancelar Evento',
      message:
          'Tem certeza que deseja cancelar este evento? Esta ação não pode ser desfeita.',
      confirmLabel: 'Cancelar Evento',
      cancelLabel: 'Voltar',
    );
    if (!confirmed || !mounted) return;

    try {
      await ref
          .read(cancelEventProvider.notifier)
          .cancel(
            organizationId: widget.organizationId,
            eventId: widget.eventId,
          );
      if (!mounted) return;
      ref.invalidate(
        findEventDetailsByIdProvider(
          organizationId: widget.organizationId,
          eventId: widget.eventId,
        ),
      );
      ref.invalidate(eventMembershipProvider(widget.organizationId));
      ref.invalidate(
        nextPendingAvailabilityEventProvider(widget.organizationId),
      );
      ref.invalidate(nextAssignedEventProvider(widget.organizationId));
      ToastFeedbackService.showToast(
        context,
        'Evento cancelado com sucesso.',
        ToastType.success,
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ToastFeedbackService.showToast(context, e.userMessage, ToastType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => ref.refresh(
        findEventDetailsByIdProvider(
          organizationId: widget.organizationId,
          eventId: widget.eventId,
        ).future,
      ),
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ── Header card ────────────────────────────────────────────────
                EventDetailHeaderCard(
                  details: widget.details,
                  organizationId: widget.organizationId,
                  eventId: widget.eventId,
                  currentMemberId: widget.currentMember?.id,
                  onOptions: widget.canManageEvents ? _showOptionsModal : null,
                ),
                const SizedBox(height: 16),

                // ── Tabs ───────────────────────────────────────────────────────
                ToggleTabs<_EventDetailTab>(
                  selected: _tab,
                  values: _EventDetailTab.values,
                  labelBuilder: (t) => switch (t) {
                    _EventDetailTab.people => 'Escala',
                    _EventDetailTab.rules => 'Personalização',
                  },
                  onChanged: (t) => setState(() => _tab = t),
                ),
                const SizedBox(height: 16),

                // ── Tab content ────────────────────────────────────────────────
                AnimatedSwitcher(
                  duration: DSMotion.fast,
                  child: KeyedSubtree(
                    key: ValueKey(_tab),
                    child: _tab == _EventDetailTab.people
                        ? _EscalaTabContent(
                            details: widget.details,
                            organizationId: widget.organizationId,
                            eventId: widget.eventId,
                            canManageEvents: widget.canManageEvents,
                            onLockAssignments: () => _handleLockAssignments(),
                            onReopenAssignments: () => _handleReopenAssignments(),
                          )
                        : EventDetailRulesView(details: widget.details),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Escala Tab Content ───────────────────────────────────────────────────────

class _EscalaTabContent extends StatelessWidget {
  const _EscalaTabContent({
    required this.details,
    required this.organizationId,
    required this.eventId,
    required this.canManageEvents,
    required this.onLockAssignments,
    required this.onReopenAssignments,
  });

  final OrganizationEventDetailsModel details;
  final String organizationId;
  final String eventId;
  final bool canManageEvents;
  final Future<void> Function() onLockAssignments;
  final Future<void> Function() onReopenAssignments;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _EventStatusCard(
          details: details,
          canManageEvents: canManageEvents,
          onLockAssignments: onLockAssignments,
          onReopenAssignments: onReopenAssignments,
        ),
        const SizedBox(height: 16),
        EventDetailParticipantsBoard(
          organizationId: organizationId,
          eventId: eventId,
          participants: details.participants,
          canManageEvents:
              canManageEvents &&
              details.status == OrganizationEventStatus.scheduled,
        ),
      ],
    );
  }
}

// ─── Options Sheet ────────────────────────────────────────────────────────────

class _EventOptionsModal extends DSBaseModal {
  const _EventOptionsModal({
    required this.organizationId,
    required this.eventId,
    required this.eventName,
    required this.canManageEvents,
    required this.eventStatus,
    this.onShareEvent,
    this.onCancelEvent,
  });

  final String organizationId;
  final String eventId;
  final String eventName;
  final bool canManageEvents;
  final OrganizationEventStatus eventStatus;
  final VoidCallback? onShareEvent;
  final VoidCallback? onCancelEvent;

  static Future<void> show(
    BuildContext context, {
    required String organizationId,
    required String eventId,
    required String eventName,
    required bool canManageEvents,
    required OrganizationEventStatus eventStatus,
    VoidCallback? onShareEvent,
    VoidCallback? onCancelEvent,
  }) => DSBaseModal.show(
    context,
    _EventOptionsModal(
      organizationId: organizationId,
      eventId: eventId,
      eventName: eventName,
      canManageEvents: canManageEvents,
      eventStatus: eventStatus,
      onShareEvent: onShareEvent,
      onCancelEvent: onCancelEvent,
    ),
  );

  @override
  State<_EventOptionsModal> createState() => _EventOptionsModalState();
}

class _EventOptionsModalState extends DSBaseModalState<_EventOptionsModal> {
  @override
  Widget? get titleWidget =>
      DSModalHeader(title: 'Opções do evento', subtitle: widget.eventName);

  @override
  List<Widget> buildBody(BuildContext context) {
    final isScheduled = widget.eventStatus == OrganizationEventStatus.scheduled;
    final canEdit = widget.canManageEvents && isScheduled;

    return [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ActionTile(
          icon: Icons.share_rounded,
          title: 'Compartilhar Evento',
          description: 'Enviar informações e link do evento',
          onTap: () {
            DSBaseModal.hide(context);
            widget.onShareEvent?.call();
          },
        ),
      ),
      if (canEdit)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ActionTile(
            icon: Icons.edit_rounded,
            title: 'Editar Evento',
            description: 'Alterar data, local e configurações',
            onTap: () {
              DSBaseModal.hide(context);
              context.push(AppPaths.orgEventEdit(widget.eventId));
            },
          ),
        ),
      if (canEdit)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ActionTile(
            icon: Icons.cancel_rounded,
            title: 'Cancelar Evento',
            description: 'Encerrar e notificar todos os membros',
            destructive: true,
            onTap: () {
              DSBaseModal.hide(context);
              widget.onCancelEvent?.call();
            },
          ),
        ),
      const SizedBox(height: 8),
    ];
  }
}

// ─── Event Status Card ────────────────────────────────────────────────────────

String _formatLockMinutes(int minutes) {
  if (minutes == 0) return 'imediatamente';
  final h = minutes ~/ 60;
  final m = minutes % 60;
  if (h == 0) return '${m}min';
  if (m == 0) return '${h}h';
  return '${h}h${m}min';
}

String _formatEventTime(DateTime dt) =>
    '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

class _EventStatusCard extends StatefulWidget {
  const _EventStatusCard({
    required this.details,
    required this.canManageEvents,
    required this.onLockAssignments,
    required this.onReopenAssignments,
  });

  final OrganizationEventDetailsModel details;
  final bool canManageEvents;
  final Future<void> Function() onLockAssignments;
  final Future<void> Function() onReopenAssignments;

  @override
  State<_EventStatusCard> createState() => _EventStatusCardState();
}

class _EventStatusCardState extends State<_EventStatusCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;

  bool _isLoading = false;

  bool get _shouldPulse =>
      widget.details.status == OrganizationEventStatus.scheduled &&
      widget.details.allowAssignment;

  Future<void> _runAction(Future<void> Function() action) async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    try {
      await action();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: DSMotion.slow + DSMotion.slow,
    );
    _opacity = Tween(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: DSMotion.standard));
    if (_shouldPulse) _ctrl.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(_EventStatusCard old) {
    super.didUpdateWidget(old);
    if (_shouldPulse && !_ctrl.isAnimating) {
      _ctrl.repeat(reverse: true);
    } else if (!_shouldPulse && _ctrl.isAnimating) {
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
    return switch (widget.details.status) {
      OrganizationEventStatus.scheduled => _buildScheduled(context),
      OrganizationEventStatus.inProgress => _buildInProgress(context),
      OrganizationEventStatus.completed => _buildCompleted(context),
      OrganizationEventStatus.canceled => _buildCanceled(context),
    };
  }

  // ── scheduled ───────────────────────────────────────────────────────────────

  Widget _buildScheduled(BuildContext context) {
    final open = widget.details.allowAssignment;
    final lockMinutes = widget.details.availabilityLockBeforeStartInMinutes;
    final lockAt = widget.details.startAt.subtract(
      Duration(minutes: lockMinutes),
    );
    final lockLabel = _formatLockMinutes(lockMinutes);
    final lockTimeStr = _formatEventTime(lockAt);

    if (open) {
      return _StatusCardShell(
        background: context.colors.surface,
        borderColor: context.colors.border,
        iconData: Icons.access_time_rounded,
        iconColor: context.colors.info,
        iconTint: context.colors.infoTint,
        dot: FadeTransition(
          opacity: _opacity,
          child: _StatusDot(color: context.colors.success),
        ),
        statusText: 'Respostas Abertas',
        statusColor: context.colors.success,
        description: Text.rich(
          TextSpan(
            text: 'Esta escala fecha automaticamente ',
            style: context.textStyles.bodySmall.copyWith(
              color: context.colors.textSecondary,
              height: 1.4,
            ),
            children: [
              TextSpan(
                text: '$lockLabel antes',
                style: context.textStyles.bodySmall.copyWith(
                  color: context.colors.textPrimary,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
              ),
              TextSpan(text: ' (às $lockTimeStr).'),
            ],
          ),
        ),
        actionLabel: widget.canManageEvents ? 'Fechar Agora' : null,
        isLoading: _isLoading,
        onAction: widget.canManageEvents
            ? () => _runAction(widget.onLockAssignments)
            : null,
      );
    }

    return _StatusCardShell(
      background: context.colors.surface,
      borderColor: context.colors.border,
      iconData: Icons.lock_rounded,
      iconColor: context.colors.danger,
      iconTint: context.colors.dangerTint,
      dot: _StatusDot(color: context.colors.danger),
      statusText: 'Respostas Bloqueadas',
      statusColor: context.colors.danger,
      description: Text.rich(
        TextSpan(
          text: 'As respostas foram bloqueadas ',
          style: context.textStyles.bodySmall.copyWith(
            color: context.colors.textSecondary,
            height: 1.4,
          ),
          children: [
            TextSpan(
              text: '$lockLabel antes',
              style: context.textStyles.bodySmall.copyWith(
                color: context.colors.textPrimary,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
            TextSpan(text: ' do evento.'),
          ],
        ),
      ),
      actionLabel: widget.canManageEvents ? 'Reabrir Escala' : null,
      isLoading: _isLoading,
      onAction: widget.canManageEvents
          ? () => _runAction(widget.onReopenAssignments)
          : null,
    );
  }

  // ── inProgress ───────────────────────────────────────────────────────────────

  Widget _buildInProgress(BuildContext context) {
    final endTime = _formatEventTime(widget.details.endAt);
    return _StatusCardShell(
      background: context.colors.surface,
      borderColor: context.colors.border,
      iconData: Icons.play_circle_rounded,
      iconColor: context.colors.success,
      iconTint: context.colors.successTint,
      dot: FadeTransition(
        opacity: _opacity,
        child: _StatusDot(color: context.colors.success),
      ),
      statusText: 'Evento em Andamento',
      statusColor: context.colors.success,
      description: Text.rich(
        TextSpan(
          text: 'Termina às ',
          style: context.textStyles.bodySmall.copyWith(
            color: context.colors.textSecondary,
            height: 1.4,
          ),
          children: [
            TextSpan(
              text: endTime,
              style: context.textStyles.bodySmall.copyWith(
                color: context.colors.textPrimary,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
            TextSpan(text: '.'),
          ],
        ),
      ),
    );
  }

  // ── completed ────────────────────────────────────────────────────────────────

  Widget _buildCompleted(BuildContext context) {
    return _StatusCardShell(
      background: context.colors.surface,
      borderColor: context.colors.border,
      iconData: Icons.check_circle_rounded,
      iconColor: context.colors.textSecondary,
      iconTint: context.colors.surfaceSubtle,
      dot: _StatusDot(color: context.colors.textSecondary),
      statusText: 'Evento Finalizado',
      statusColor: context.colors.textSecondary,
      description: Text(
        'Este evento foi concluído com sucesso.',
        style: context.textStyles.bodySmall.copyWith(
          color: context.colors.textSecondary,
          height: 1.4,
        ),
      ),
    );
  }

  // ── canceled ─────────────────────────────────────────────────────────────────

  Widget _buildCanceled(BuildContext context) {
    return _StatusCardShell(
      background: context.colors.surface,
      borderColor: context.colors.border,
      iconData: Icons.cancel_rounded,
      iconColor: context.colors.danger,
      iconTint: context.colors.dangerTint,
      dot: _StatusDot(color: context.colors.danger),
      statusText: 'Evento Cancelado',
      statusColor: context.colors.danger,
      description: Text(
        'Este evento foi cancelado e não ocorrerá.',
        style: context.textStyles.bodySmall.copyWith(
          color: context.colors.textSecondary,
          height: 1.4,
        ),
      ),
    );
  }
}

// ─── Status card shell ────────────────────────────────────────────────────────

class _StatusCardShell extends StatelessWidget {
  const _StatusCardShell({
    required this.background,
    required this.borderColor,
    required this.iconData,
    required this.iconColor,
    required this.iconTint,
    required this.dot,
    required this.statusText,
    required this.statusColor,
    required this.description,
    this.actionLabel,
    this.isLoading = false,
    this.onAction,
  });

  final Color background;
  final Color borderColor;
  final IconData iconData;
  final Color iconColor;
  final Color iconTint;
  final Widget dot;
  final String statusText;
  final Color statusColor;
  final Widget description;
  final String? actionLabel;
  final bool isLoading;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DSSpacing.lg),
      decoration: BoxDecoration(
        color: background,
        borderRadius: DSRadius.allLg,
        border: Border.all(color: borderColor),
        boxShadow: DSElevation.sm,
      ),
      child: Row(
        children: [
          // Icon box
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconTint,
              borderRadius: DSRadius.allMd,
            ),
            child: Icon(iconData, size: 20, color: iconColor),
          ),
          const SizedBox(width: DSSpacing.md),

          // Text content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    dot,
                    const SizedBox(width: 6),
                    Text(
                      statusText.toUpperCase(),
                      style: context.textStyles.labelSmall.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                description,
              ],
            ),
          ),

          // Action button
          if (actionLabel != null) ...[
            const SizedBox(width: DSSpacing.sm),
            if (isLoading)
              SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: context.colors.primary,
                ),
              )
            else
              GestureDetector(
                onTap: onAction,
                child: Text(
                  actionLabel!,
                  style: context.textStyles.labelSmall.copyWith(
                    color: context.colors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _StatusDot extends StatelessWidget {
  const _StatusDot({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
