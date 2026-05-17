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

  List<OrganizationEventParticipantModel> get _candidates =>
      widget.participants
          .where((p) =>
              p.availabilityStatus ==
                  OrganizationEventMembershipAvailabilityStatus.available &&
              p.status != OrganizationEventMembershipStatus.assigned &&
              p.availabilityStatus !=
                  OrganizationEventMembershipAvailabilityStatus.unavailable)
          .toList();

  List<OrganizationEventParticipantModel> get _assigned => widget.participants
      .where((p) => p.status == OrganizationEventMembershipStatus.assigned)
      .toList();

  List<OrganizationEventParticipantModel> get _pending => widget.participants
      .where((p) =>
          p.availabilityStatus ==
          OrganizationEventMembershipAvailabilityStatus.notAnswered)
      .toList();

  List<OrganizationEventParticipantModel> get _dismissed => widget.participants
      .where((p) =>
          p.availabilityStatus ==
          OrganizationEventMembershipAvailabilityStatus.unavailable)
      .toList();

  // ── Actions ───────────────────────────────────────────────────────────────

  void _invalidate() => ref.invalidate(findEventDetailsByIdProvider(
      organizationId: widget.organizationId, eventId: widget.eventId));

  Future<void> _approve(String membershipId) async {
    try {
      await ref.read(manageParticipantProvider.notifier).approveAssignment(
            organizationId: widget.organizationId,
            eventId: widget.eventId,
            participantId: membershipId,
          );
      _invalidate();
    } catch (_) {
      if (!mounted) return;
      ToastFeedbackService.showToast(
          context, 'Não foi possível escalar o membro.', ToastType.error);
    }
  }

  Future<void> _reject(String membershipId) async {
    try {
      await ref.read(manageParticipantProvider.notifier).reject(
            organizationId: widget.organizationId,
            eventId: widget.eventId,
            membershipId: membershipId,
          );
      _invalidate();
    } catch (_) {
      if (!mounted) return;
      ToastFeedbackService.showToast(
          context, 'Não foi possível rejeitar o membro.', ToastType.error);
    }
  }

  Future<void> _remove(String membershipId) async {
    try {
      await ref.read(manageParticipantProvider.notifier).removeAssignment(
            organizationId: widget.organizationId,
            eventId: widget.eventId,
            participantId: membershipId,
          );
      _invalidate();
    } catch (_) {
      if (!mounted) return;
      ToastFeedbackService.showToast(
          context, 'Não foi possível remover o membro da escala.', ToastType.error);
    }
  }

  void _request(String membershipId) {
    ref.read(requestAvailabilityProvider.notifier).request(membershipId);
    ToastFeedbackService.showToast(
        context, 'Solicitação enviada.', ToastType.success);
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final requestState = ref.watch(requestAvailabilityProvider);

    final candidates = _candidates.where(_matches).toList();
    final assigned = _assigned.where(_matches).toList();
    final pending = _pending.where(_matches).toList();
    final dismissed = _dismissed.where(_matches).toList();

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
            count: _candidates.length,
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
            count: _assigned.length,
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
            count: _pending.length,
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
            count: _dismissed.length,
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
      tiles.add(EventDetailParticipantTile(
        participant: p,
        variant: variant,
        onApprove: widget.canManageEvents
            ? () => _approve(p.membershipId)
            : null,
        onReject: widget.canManageEvents
            ? () => _reject(p.membershipId)
            : null,
        onRemove: widget.canManageEvents
            ? () => _remove(p.membershipId)
            : null,
        onRequest: widget.canManageEvents
            ? () => _request(p.membershipId)
            : null,
        requestCooldown: ref
            .read(requestAvailabilityProvider.notifier)
            .hasCooldown(p.membershipId),
      ));
      if (i < items.length - 1) {
        tiles.add(DSDivider(
          indent: DSSpacing.lg,
          endIndent: DSSpacing.lg,
        ));
      }
    }
    return tiles;
  }
}
