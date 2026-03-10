import 'package:convoquei_app/core/utils/date_locale_pt.dart';
import 'package:convoquei_app/core/widgets/action_button.dart';
import 'package:convoquei_app/core/widgets/custom_calendar.dart';
import 'package:convoquei_app/core/widgets/timeline_group.dart';
import 'package:convoquei_app/features/organizations/events/models/enums/organization_event_membership_status.dart';
import 'package:convoquei_app/features/organizations/events/models/events_filter_model.dart';
import 'package:convoquei_app/features/organizations/events/models/orgnaization_event_membership_model.dart';
import 'package:convoquei_app/features/organizations/events/providers/answer_availability_provider.dart';
import 'package:convoquei_app/features/organizations/events/providers/find_all_events_membership_provider.dart';
import 'package:convoquei_app/features/organizations/events/widgets/empty_event_state.dart';
import 'package:convoquei_app/features/organizations/events/widgets/event_card.dart';
import 'package:convoquei_app/features/organizations/home/widgets/team_toggle_widget.dart';
import 'package:convoquei_app/features/organizations/shared/models/organization_my_member_profile_model.dart';
import 'package:convoquei_app/features/organizations/shared/providers/organization_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

enum OrgEventsTab { all, mySchedules, pending }

class OrgEventsPage extends ConsumerStatefulWidget {
  const OrgEventsPage({
    super.key,
    required this.organizationId,
    this.onCreateEvent,
  });

  final String organizationId;
  final VoidCallback? onCreateEvent;

  @override
  ConsumerState<OrgEventsPage> createState() => _OrgEventsPageState();
}

class _OrgEventsPageState extends ConsumerState<OrgEventsPage> {
  OrgEventsTab _selectedTab = OrgEventsTab.all;
  EventsFilter _filter      = const EventsFilter();

  // O que o pai sabe sobre o calendário — apenas o suficiente para labels e filtro
  DateTime? _selectedDay;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;

  static const _weekdayNames = DateLocalePt.weekdayNames;
  static const _monthNames   = DateLocalePt.monthNames;

  String get _dateLabel {
    if (_selectedDay != null) {
      final d       = _selectedDay!;
      final weekday = _weekdayNames[d.weekday - 1].toLowerCase();
      return '$weekday, ${d.day} de ${_monthNames[d.month - 1]} de ${d.year}';
    }
    return 'esse período';
  }

  // ================================================================
  // _buildFilter — fonte única de verdade para o filtro de datas
  //
  // Regra:
  //   • Dia selecionado  → filtra apenas aquele dia
  //   • Sem seleção      → filtra o range visível no calendário
  // ================================================================
  EventsFilter _buildFilter({
    DateTime? selectedDay,
    DateTime? rangeStart,
    DateTime? rangeEnd,
    OrgEventsTab? tab,
  }) {
    final resolvedTab = tab ?? _selectedTab;

    final List<OrganizationEventMembershipStatus>? status = switch (resolvedTab) {
      OrgEventsTab.all         => null,
      OrgEventsTab.mySchedules => [OrganizationEventMembershipStatus.assigned],
      OrgEventsTab.pending     => [
        OrganizationEventMembershipStatus.pending,
        OrganizationEventMembershipStatus.awaitingAssignment,
        OrganizationEventMembershipStatus.awaitingDraw,
      ],
    };

    if (selectedDay != null) {
      return EventsFilter(
        startAfter:  startOfDay(selectedDay),
        startBefore: endOfDay(selectedDay),
        status:      status,
      );
    }

    if (rangeStart != null && rangeEnd != null) {
      return EventsFilter(
        startAfter:  startOfDay(rangeStart),
        startBefore: endOfDay(rangeEnd),
        status:      status,
      );
    }

    return EventsFilter(status: status);
  }

  void _applyFilter(EventsFilter newFilter) {
    setState(() => _filter = newFilter);
    ref
        .read(eventMembershipProvider.notifier)
        .reset(widget.organizationId, newFilter);
  }

  // ── Callbacks do calendário ──────────────────────────────────────

  void _handleDaySelected(DateTime selected, DateTime? deselected) {
    final isDeselecting = selected == deselected;
    final nextSelected  = isDeselecting ? null : selected;

    setState(() => _selectedDay = nextSelected);

    _applyFilter(_buildFilter(
      selectedDay: nextSelected,
      rangeStart:  _rangeStart,
      rangeEnd:    _rangeEnd,
    ));
  }

  /// Chamado pelo calendário sempre que o range visível muda.
  /// Se há dia selecionado, apenas guarda o range para uso futuro.
  void _handleRangeChanged(DateTime start, DateTime end) {
    setState(() {
      _rangeStart  = start;
      _rangeEnd    = end;
      _selectedDay = null; // range novo = sem seleção
    });

    _applyFilter(_buildFilter(rangeStart: start, rangeEnd: end));
  }

  // ── Handler das tabs ─────────────────────────────────────────────
  void _handleTabChange(OrgEventsTab newTab) {
    if (newTab == _selectedTab) return;

    setState(() => _selectedTab = newTab);

    _applyFilter(_buildFilter(
      selectedDay: _selectedDay,
      rangeStart:  _rangeStart,
      rangeEnd:    _rangeEnd,
      tab:         newTab,
    ));
  }

  void _handleRetry() {
    ref
        .read(eventMembershipProvider.notifier)
        .reset(widget.organizationId, _filter);
  }

  // ── Disponibilidade ──────────────────────────────────────────────
  Future<void> _handleAvailability(String eventId, bool available) async {
    final updated = await ref
        .read(answerAvailabilityProvider.notifier)
        .answer(organizationId: widget.organizationId, eventId: eventId, available: available);

    if (updated != null) {
      ref.read(eventMembershipProvider.notifier).updateItem(updated);
    }
  }


  // ── Agrupamento ──────────────────────────────────────────────────
  Map<DateTime, List<OrganizationEventMembershipModel>> _groupByDate(
      List<OrganizationEventMembershipModel> items,
      ) {
    final map = <DateTime, List<OrganizationEventMembershipModel>>{};
    for (final item in items) {
      final date = DateTime(
        item.startTime.year,
        item.startTime.month,
        item.startTime.day,
      );
      map.putIfAbsent(date, () => []).add(item);
    }
    return map;
  }

  // ── Build ────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final eventsState = ref.watch(eventMembershipProvider);
    OrganizationMyMemberProfile currentUser = ref.watch(currentUserMembershipOrganizationProvider(widget.organizationId)).asData!.value;
    final grouped = _groupByDate(eventsState.items);

    final hasListContent = !eventsState.isInitialLoading &&
        eventsState.error == null &&
        !eventsState.isEmpty;

    return Scaffold(
      body: CustomScrollView(
        physics: hasListContent
            ? const AlwaysScrollableScrollPhysics()
            : const NeverScrollableScrollPhysics(),
        slivers: [
          // ── Calendário + Tabs ──────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomCalendar(
                    events: {
                      ...grouped.map(
                            (date, events) => MapEntry(
                          DateTime(date.year, date.month, date.day),
                          events.map((e) => e.id).toList(),
                        ),
                      ),
                    },
                    onDaySelected:  _handleDaySelected,
                    onRangeChanged: _handleRangeChanged,
                  ),
                  const SizedBox(height: 20),
                  ToggleTabs(
                    selected: _selectedTab,
                    onChanged: _handleTabChange,
                    values: OrgEventsTab.values,
                    labelBuilder: (tab) => switch (tab) {
                      OrgEventsTab.all         => 'Todos eventos',
                      OrgEventsTab.mySchedules => 'Minhas Escalas',
                      OrgEventsTab.pending     => 'Pendentes',
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // ── Conteúdo principal ─────────────────────────────────
          if (eventsState.isInitialLoading)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: CircularProgressIndicator()),
            )
          else if (eventsState.error != null)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.cloud_off_rounded, size: 48, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text(
                      'Não foi possível carregar os eventos',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Verifique sua conexão e tente novamente.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 24),
                    ActionButton(
                      label: 'Tentar novamente',
                      icon: Icons.refresh_rounded,
                      outlined: true,
                      fullWidth: false,
                      onPressed: _handleRetry,
                    ),
                  ],
                ),
              ),
            )
          else if (eventsState.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyEventsState(
                  tab: _selectedTab,
                  dateLabel: _dateLabel,
                  membership: currentUser,
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      final entry  = grouped.entries.elementAt(index);
                      final date   = entry.key;
                      final events = entry.value;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TimelineGroup(
                            title: DateFormat(
                              "d 'de' MMMM 'de' yyyy",
                              'pt_BR',
                            ).format(date),
                            children: [],
                          ),
                          const SizedBox(height: 8),
                          ...events.map(
                                (membership) => Column(
                              children: [
                                EventCard(
                                  key: ValueKey(membership.id),
                                  event: membership,
                                  onAvailable: () => _handleAvailability(membership.id, true),
                                  onUnavailable: () => _handleAvailability(membership.id, false),
                                  onLeaveSchedule: () => _handleAvailability(membership.id, false),
                                ),
                                const SizedBox(height: 12),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      );
                    },
                    childCount: grouped.length,
                  ),
                ),
              ),
        ],
      ),
    );
  }
}