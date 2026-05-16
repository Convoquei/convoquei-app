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
import 'package:convoquei_app/features/organizations/events/widgets/event_detail_hero_card.dart';
import 'package:convoquei_app/features/organizations/events/widgets/event_participants_view.dart';
import 'package:convoquei_app/features/organizations/events/widgets/event_rules_view.dart';
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

    final canManageEvents = ref
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
  final _rulesKey = GlobalKey<EventRulesViewState>();
  bool _rulesIsDirty = false;
  bool _rulesSaving = false;

  void _showOptionsModal() {
    _EventOptionsModal.show(
      context,
      organizationId: widget.organizationId,
      eventId: widget.eventId,
      eventName: widget.details.name,
      canManageEvents: widget.canManageEvents,
      eventStatus: widget.details.status,
      allowAssignment: widget.details.allowAssignment,
      onShareEvent: _handleShare,
      onCancelEvent: _handleCancelEvent,
      onLockAssignments: _handleLockAssignments,
      onReopenAssignments: _handleReopenAssignments,
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
      message: 'Deseja fechar as respostas? Os membros não poderão mais confirmar disponibilidade.',
      confirmLabel: 'Fechar Escalação',
      cancelLabel: 'Voltar',
    );
    if (!confirmed || !mounted) return;

    try {
      await ref.read(manageAssignmentsProvider.notifier).lock(
            organizationId: widget.organizationId,
            eventId: widget.eventId,
          );
      if (!mounted) return;
      ref.invalidate(findEventDetailsByIdProvider(
        organizationId: widget.organizationId,
        eventId: widget.eventId,
      ));
      ToastFeedbackService.showToast(
          context, 'Escalação fechada com sucesso.', ToastType.success);
    } on ApiException catch (e) {
      if (!mounted) return;
      ToastFeedbackService.showToast(context, e.userMessage, ToastType.error);
    }
  }

  Future<void> _handleReopenAssignments() async {
    try {
      await ref.read(manageAssignmentsProvider.notifier).reopen(
            organizationId: widget.organizationId,
            eventId: widget.eventId,
          );
      if (!mounted) return;
      ref.invalidate(findEventDetailsByIdProvider(
        organizationId: widget.organizationId,
        eventId: widget.eventId,
      ));
      ToastFeedbackService.showToast(
          context, 'Escalação reaberta com sucesso.', ToastType.success);
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
      await ref.read(cancelEventProvider.notifier).cancel(
            organizationId: widget.organizationId,
            eventId: widget.eventId,
          );
      if (!mounted) return;
      ref.invalidate(findEventDetailsByIdProvider(
        organizationId: widget.organizationId,
        eventId: widget.eventId,
      ));
      ref.invalidate(eventMembershipProvider(widget.organizationId));
      ref.invalidate(
        nextPendingAvailabilityEventProvider(widget.organizationId),
      );
      ref.invalidate(nextAssignedEventProvider(widget.organizationId));
      ToastFeedbackService.showToast(
          context, 'Evento cancelado com sucesso.', ToastType.success);
    } on ApiException catch (e) {
      if (!mounted) return;
      ToastFeedbackService.showToast(context, e.userMessage, ToastType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final showBottomBar = _tab == _EventDetailTab.rules && _rulesIsDirty;
    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: () async => ref.refresh(
            findEventDetailsByIdProvider(
              organizationId: widget.organizationId,
              eventId: widget.eventId,
            ).future,
          ),
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, showBottomBar ? 104 : 32),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    EventDetailHeroCard(
                      details: widget.details,
                      onOptions:
                          widget.canManageEvents ? _showOptionsModal : null,
                    ),
                    const SizedBox(height: 16),
                    ToggleTabs<_EventDetailTab>(
                      selected: _tab,
                      values: _EventDetailTab.values,
                      labelBuilder: (t) => switch (t) {
                        _EventDetailTab.people => 'Pessoas',
                        _EventDetailTab.rules => 'Regras do Evento',
                      },
                      onChanged: (t) => setState(() {
                        _tab = t;
                        if (t != _EventDetailTab.rules) {
                          _rulesIsDirty = false;
                          _rulesSaving = false;
                        }
                      }),
                    ),
                    const SizedBox(height: 16),
                    AnimatedSwitcher(
                      duration: DSMotion.fast,
                      child: KeyedSubtree(
                        key: ValueKey(_tab),
                        child: _tab == _EventDetailTab.people
                            ? EventParticipantsView(
                                organizationId: widget.organizationId,
                                eventId: widget.eventId,
                                currentMemberId: widget.currentMember?.id ?? '',
                                canManageEvents: widget.canManageEvents,
                                participants: widget.details.participants,
                              )
                            : EventRulesView(
                                key: _rulesKey,
                                organizationId: widget.organizationId,
                                canManageEvents: widget.canManageEvents,
                                details: widget.details,
                                onDirtyChanged: (dirty) =>
                                    setState(() => _rulesIsDirty = dirty),
                                onSavingChanged: (saving) =>
                                    setState(() => _rulesSaving = saving),
                              ),
                      ),
                    ),
                  ]),
                ),
              ),
            ],
          ),
        ),
        if (showBottomBar)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              top: false,
              child: Builder(
                builder: (context) => Container(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  decoration: BoxDecoration(
                    color: context.colors.surface,
                    border: Border(
                      top: BorderSide(color: context.colors.border),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: DSButton(
                          label: 'Redefinir',
                          icon: Icons.restart_alt_rounded,
                          outlined: true,
                          schema: DSButtonSchema.ghost,
                          onPressed: () => _rulesKey.currentState?.reset(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DSButton(
                          label: 'Salvar Regras',
                          icon: Icons.save_rounded,
                          isLoading: _rulesSaving,
                          onPressed: () => _rulesKey.currentState?.save(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
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
    required this.allowAssignment,
    this.onShareEvent,
    this.onCancelEvent,
    this.onLockAssignments,
    this.onReopenAssignments,
  });

  final String organizationId;
  final String eventId;
  final String eventName;
  final bool canManageEvents;
  final OrganizationEventStatus eventStatus;
  final bool allowAssignment;
  final VoidCallback? onShareEvent;
  final VoidCallback? onCancelEvent;
  final VoidCallback? onLockAssignments;
  final VoidCallback? onReopenAssignments;

  static Future<void> show(
    BuildContext context, {
    required String organizationId,
    required String eventId,
    required String eventName,
    required bool canManageEvents,
    required OrganizationEventStatus eventStatus,
    required bool allowAssignment,
    VoidCallback? onShareEvent,
    VoidCallback? onCancelEvent,
    VoidCallback? onLockAssignments,
    VoidCallback? onReopenAssignments,
  }) =>
      DSBaseModal.show(
        context,
        _EventOptionsModal(
          organizationId: organizationId,
          eventId: eventId,
          eventName: eventName,
          canManageEvents: canManageEvents,
          eventStatus: eventStatus,
          allowAssignment: allowAssignment,
          onShareEvent: onShareEvent,
          onCancelEvent: onCancelEvent,
          onLockAssignments: onLockAssignments,
          onReopenAssignments: onReopenAssignments,
        ),
      );

  @override
  State<_EventOptionsModal> createState() => _EventOptionsModalState();
}

class _EventOptionsModalState extends DSBaseModalState<_EventOptionsModal> {
  @override
  Widget? get titleWidget => DSModalHeader(
        title: 'Opções do evento',
        subtitle: widget.eventName,
      );

  @override
  List<Widget> buildBody(BuildContext context) {
    final isScheduled = widget.eventStatus == OrganizationEventStatus.scheduled;
    final canEdit = widget.canManageEvents && isScheduled;
    final canManageAssignments = widget.canManageEvents && isScheduled;

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
      if (canManageAssignments && widget.allowAssignment)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ActionTile(
            icon: Icons.lock_rounded,
            title: 'Fechar Escalação',
            description: 'Encerrar respostas de disponibilidade',
            iconColor: context.colors.warning,
            iconBgColor: context.colors.warningTint,
            onTap: () {
              DSBaseModal.hide(context);
              widget.onLockAssignments?.call();
            },
          ),
        ),
      if (canManageAssignments && !widget.allowAssignment)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ActionTile(
            icon: Icons.lock_open_rounded,
            title: 'Reabrir Escalação',
            description: 'Permitir novas respostas de disponibilidade',
            iconColor: context.colors.success,
            iconBgColor: context.colors.successTint,
            onTap: () {
              DSBaseModal.hide(context);
              widget.onReopenAssignments?.call();
            },
          ),
        ),
      if (widget.canManageEvents &&
          widget.eventStatus != OrganizationEventStatus.canceled)
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
