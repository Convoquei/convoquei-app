import 'package:convoquei_app/core/theme/app_theme.dart';
import 'package:convoquei_app/core/widgets/action_button.dart';
import 'package:convoquei_app/core/widgets/app_loading_info.dart';
import 'package:convoquei_app/core/widgets/app_loading_screen.dart';
import 'package:convoquei_app/core/widgets/error_retry_state.dart';
import 'package:convoquei_app/features/organizations/events/models/organization_event_details_model.dart';
import 'package:convoquei_app/features/organizations/events/providers/find_event_details_by_id_provider.dart';
import 'package:convoquei_app/features/organizations/events/widgets/event_detail_hero_card.dart';
import 'package:convoquei_app/features/organizations/events/widgets/event_participants_view.dart';
import 'package:convoquei_app/features/organizations/events/widgets/event_rules_view.dart';
import 'package:convoquei_app/features/organizations/home/widgets/team_toggle_widget.dart';
import 'package:convoquei_app/features/organizations/shared/models/enums/organization_permission.dart';
import 'package:convoquei_app/features/organizations/shared/models/organization_my_member_profile_model.dart';
import 'package:convoquei_app/features/organizations/shared/providers/organization_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

    return detailsAsync.when(
      loading: () => const AppLoadingScreen(
        content: AppLoadingInfo(
          label: 'Carregando evento...',
          description: 'Buscando detalhes e participantes',
        ),
        skeleton: AppLoadingSkeleton.details,
      ),
      error: (_, __) => Center(
        child: ErrorRetryState(
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
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _EventOptionsSheet(
        organizationId: widget.organizationId,
        eventId: widget.eventId,
        canManageEvents: widget.canManageEvents,
      ),
    );
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
                      duration: const Duration(milliseconds: 200),
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
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    top: BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: ActionButton(
                        label: 'Redefinir',
                        icon: Icons.restart_alt_rounded,
                        outlined: true,
                        schema: ActionButtonSchema.ghost,
                        onPressed: () => _rulesKey.currentState?.reset(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ActionButton(
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
      ],
    );
  }
}

// ─── Options Sheet ────────────────────────────────────────────────────────────

class _EventOptionsSheet extends StatelessWidget {
  const _EventOptionsSheet({
    required this.organizationId,
    required this.eventId,
    required this.canManageEvents,
  });

  final String organizationId;
  final String eventId;
  final bool canManageEvents;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          _OptionItem(
            icon: Icons.share_rounded,
            label: 'Compartilhar Evento',
            onTap: () => Navigator.of(context).pop(),
          ),
          if (canManageEvents) ...[
            const Divider(indent: 16, endIndent: 16),
            _OptionItem(
              icon: Icons.cancel_rounded,
              label: 'Cancelar Evento',
              color: AppTheme.errorColor,
              onTap: () => Navigator.of(context).pop(),
            ),
          ],
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _OptionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback onTap;

  const _OptionItem({
    required this.icon,
    required this.label,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppTheme.textPrimary;
    return ListTile(
      leading: Icon(icon, color: c),
      title: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(color: c),
      ),
      onTap: onTap,
    );
  }
}
