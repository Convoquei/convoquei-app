import 'package:convoquei_app/core/services/toast_feedback_service.dart';
import 'package:convoquei_app/design_system/ds.dart';
import 'package:convoquei_app/features/organizations/events/models/enums/organization_event_membership_availability_status.dart';
import 'package:convoquei_app/features/organizations/events/models/enums/organization_event_membership_status.dart';
import 'package:convoquei_app/features/organizations/events/models/organization_event_details_model.dart';
import 'package:convoquei_app/features/organizations/events/providers/find_event_details_by_id_provider.dart';
import 'package:convoquei_app/features/organizations/events/providers/manage_participant_provider.dart';
import 'package:convoquei_app/features/organizations/events/providers/request_availability_provider.dart';
import 'package:convoquei_app/features/organizations/events/widgets/event_detail/event_detail_participant_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum _ParticipantBucket { awaiting, assigned, pending, dismissed }

class EventDetailParticipantsBoard extends ConsumerStatefulWidget {
  const EventDetailParticipantsBoard({
    super.key,
    required this.organizationId,
    required this.eventId,
    required this.participants,
    required this.canManageEvents,
  });

  final String organizationId;
  final String eventId;
  final List<OrganizationEventParticipantModel> participants;
  final bool canManageEvents;

  @override
  ConsumerState<EventDetailParticipantsBoard> createState() =>
      _EventDetailParticipantsBoardState();
}

class _EventDetailParticipantsBoardState
    extends ConsumerState<EventDetailParticipantsBoard> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ── Filtering ─────────────────────────────────────────────────────────────

  bool _matches(OrganizationEventParticipantModel p) {
    if (_query.isEmpty) return true;
    final q = _query.toLowerCase();
    return p.name.toLowerCase().contains(q) ||
        (p.function?.toLowerCase().contains(q) ?? false);
  }

  // ── Buckets ───────────────────────────────────────────────────────────────

  _ParticipantBucket _bucketOf(OrganizationEventParticipantModel p) {
    if (p.status == OrganizationEventMembershipStatus.invited) {
      return _ParticipantBucket.pending;
    }
    switch (p.availabilityStatus) {
      case OrganizationEventMembershipAvailabilityStatus.notAnswered:
        return _ParticipantBucket.pending;
      case OrganizationEventMembershipAvailabilityStatus.unavailable:
        return _ParticipantBucket.dismissed;
      case OrganizationEventMembershipAvailabilityStatus.available:
        return switch (p.status) {
          OrganizationEventMembershipStatus.awaitingAssignment =>
            _ParticipantBucket.awaiting,
          OrganizationEventMembershipStatus.assigned =>
            _ParticipantBucket.assigned,
          OrganizationEventMembershipStatus.notAssigned =>
            _ParticipantBucket.dismissed,
          OrganizationEventMembershipStatus.expired =>
            _ParticipantBucket.dismissed,
          _ => _ParticipantBucket.pending,
        };
    }
  }

  ({
    List<OrganizationEventParticipantModel> awaiting,
    List<OrganizationEventParticipantModel> assigned,
    List<OrganizationEventParticipantModel> pending,
    List<OrganizationEventParticipantModel> dismissed,
  }) get _buckets {
    final awaiting = <OrganizationEventParticipantModel>[];
    final assigned = <OrganizationEventParticipantModel>[];
    final pending = <OrganizationEventParticipantModel>[];
    final dismissed = <OrganizationEventParticipantModel>[];

    for (final p in widget.participants) {
      switch (_bucketOf(p)) {
        case _ParticipantBucket.awaiting:
          awaiting.add(p);
        case _ParticipantBucket.assigned:
          assigned.add(p);
        case _ParticipantBucket.pending:
          pending.add(p);
        case _ParticipantBucket.dismissed:
          dismissed.add(p);
      }
    }

    return (
      awaiting: awaiting,
      assigned: assigned,
      pending: pending,
      dismissed: dismissed,
    );
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  void _invalidate() => ref.invalidate(
    findEventDetailsByIdProvider(
      organizationId: widget.organizationId,
      eventId: widget.eventId,
    ),
  );

  Future<void> _approve(String participantId) async {
    try {
      await ref
          .read(manageParticipantProvider.notifier)
          .approveAssignment(
            organizationId: widget.organizationId,
            eventId: widget.eventId,
            participantId: participantId,
          );
      _invalidate();
    } catch (_) {
      if (!mounted) return;
      ToastFeedbackService.showToast(
        context,
        'Não foi possível escalar o membro.',
        ToastType.error,
      );
    }
  }

  Future<void> _reject(String participantId) async {
    try {
      await ref
          .read(manageParticipantProvider.notifier)
          .reject(
            organizationId: widget.organizationId,
            eventId: widget.eventId,
            participantId: participantId,
          );
      _invalidate();
    } catch (_) {
      if (!mounted) return;
      ToastFeedbackService.showToast(
        context,
        'Não foi possível rejeitar o membro.',
        ToastType.error,
      );
    }
  }

  Future<void> _remove(String participantId) async {
    try {
      await ref
          .read(manageParticipantProvider.notifier)
          .removeAssignment(
            organizationId: widget.organizationId,
            eventId: widget.eventId,
            participantId: participantId,
          );
      _invalidate();
    } catch (_) {
      if (!mounted) return;
      ToastFeedbackService.showToast(
        context,
        'Não foi possível remover o membro da escala.',
        ToastType.error,
      );
    }
  }

  void _request(String participantId) {
    ref.read(requestAvailabilityProvider.notifier).request(participantId);
    ToastFeedbackService.showToast(
      context,
      'Solicitação enviada.',
      ToastType.success,
    );
  }

  Future<void> _assign(String participantId) async {
    try {
      await ref
          .read(manageParticipantProvider.notifier)
          .assign(
            organizationId: widget.organizationId,
            eventId: widget.eventId,
            participantId: participantId,
          );
      _invalidate();
    } catch (_) {
      if (!mounted) return;
      ToastFeedbackService.showToast(
        context,
        'Não foi possível escalar o membro.',
        ToastType.error,
      );
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final requestState = ref.watch(requestAvailabilityProvider);

    final buckets = _buckets;
    final candidates = buckets.awaiting.where(_matches).toList();
    final assigned = buckets.assigned.where(_matches).toList();
    final pending = buckets.pending.where(_matches).toList();
    final dismissed = buckets.dismissed.where(_matches).toList();

    final hasQuery = _query.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Search ──────────────────────────────────────────────────────────
        DSSearchInput(
          controller: _searchController,
          hintText: 'Buscar por nome ou função...',
          onChanged: (q) => setState(() => _query = q),
          onClear: () => setState(() {
            _query = '';
            _searchController.clear();
          }),
        ),
        const SizedBox(height: 16),

        // ── 1. Aguardando Escalação ──────────────────────────────────────────
        if (!hasQuery || candidates.isNotEmpty) ...[
          DSSectionHeader(
            title: 'Aguardando Escalação',
            count: buckets.awaiting.length,
            countColor: context.colors.warning,
          ),
          DSCard(
            padding: EdgeInsets.zero,
            child: candidates.isEmpty
                ? DSEmptyState(
                    icon: Icons.pan_tool_outlined,
                    title: 'Nenhum candidato aguardando aprovação.',
                    compact: true,
                  )
                : Column(
                    children: _buildTiles(
                      candidates,
                      EventDetailParticipantVariant.candidate,
                      requestState: requestState,
                    ),
                  ),
          ),
          const SizedBox(height: 16),
        ],

        // ── 2. Escalados ────────────────────────────────────────────────────
        if (!hasQuery || assigned.isNotEmpty) ...[
          DSSectionHeader(
            title: 'Escalados',
            count: buckets.assigned.length,
            countColor: context.colors.success,
          ),
          DSCard(
            padding: EdgeInsets.zero,
            child: assigned.isEmpty
                ? DSEmptyState(
                    icon: Icons.group_off_rounded,
                    title: 'Ninguém escalado ainda.',
                    compact: true,
                  )
                : Column(
                    children: _buildTiles(
                      assigned,
                      EventDetailParticipantVariant.assigned,
                      requestState: requestState,
                    ),
                  ),
          ),
          const SizedBox(height: 16),
        ],

        // ── 3. Não Responderam ───────────────────────────────────────────────
        if (!hasQuery || pending.isNotEmpty) ...[
          DSSectionHeader(
            title: 'Não Responderam',
            count: buckets.pending.length,
          ),
          DSCard(
            padding: EdgeInsets.zero,
            child: pending.isEmpty
                ? DSEmptyState(
                    icon: Icons.check_circle_outline_rounded,
                    title: 'Todos já responderam.',
                    compact: true,
                  )
                : Column(
                    children: _buildTiles(
                      pending,
                      EventDetailParticipantVariant.pending,
                      requestState: requestState,
                    ),
                  ),
          ),
          const SizedBox(height: 16),
        ],

        // ── 4. Dispensados ───────────────────────────────────────────────────
        if (!hasQuery || dismissed.isNotEmpty) ...[
          DSSectionHeader(
            title: 'Dispensados',
            count: buckets.dismissed.length,
            countColor: context.colors.danger,
          ),
          DSCard(
            padding: EdgeInsets.zero,
            child: dismissed.isEmpty
                ? DSEmptyState(
                    icon: Icons.thumb_up_outlined,
                    title: 'Ninguém dispensado.',
                    compact: true,
                  )
                : Column(
                    children: _buildTiles(
                      dismissed,
                      EventDetailParticipantVariant.dismissed,
                      requestState: requestState,
                    ),
                  ),
          ),
        ],
      ],
    );
  }

  List<Widget> _buildTiles(
    List<OrganizationEventParticipantModel> items,
    EventDetailParticipantVariant variant, {
    required Map<String, DateTime> requestState,
  }) {
    final tiles = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      final p = items[i];
      tiles.add(
        EventDetailParticipantTile(
          participant: p,
          variant: variant,
          onApprove: widget.canManageEvents
              ? () => _approve(p.participantId)
              : null,
          onReject: widget.canManageEvents
              ? () => _reject(p.participantId)
              : null,
          onRemove: widget.canManageEvents
              ? () => _remove(p.participantId)
              : null,
          onRequest: widget.canManageEvents
              ? () => _request(p.participantId)
              : null,
          onAssign: widget.canManageEvents &&
                  variant == EventDetailParticipantVariant.dismissed
              ? () => _assign(p.participantId)
              : null,
          requestCooldown: ref
              .read(requestAvailabilityProvider.notifier)
              .hasCooldown(p.participantId),
        ),
      );
      if (i < items.length - 1) {
        tiles.add(DSDivider(indent: DSSpacing.lg, endIndent: DSSpacing.lg));
      }
    }
    return tiles;
  }
}
