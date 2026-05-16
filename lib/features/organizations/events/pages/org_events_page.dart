import 'dart:async';

import 'package:convoquei_app/core/utils/date_locale_pt.dart';
import 'package:convoquei_app/design_system/ds.dart';
import 'package:convoquei_app/features/organizations/events/models/enums/org_events_tab.dart';
import 'package:convoquei_app/features/organizations/events/models/enums/organization_event_membership_status.dart';
import 'package:convoquei_app/features/organizations/events/models/enums/organization_event_status.dart';
import 'package:convoquei_app/features/organizations/events/models/events_filter_model.dart';
import 'package:convoquei_app/features/organizations/events/models/orgnaization_event_membership_model.dart';
import 'package:convoquei_app/features/organizations/events/providers/answer_availability_provider.dart';
import 'package:convoquei_app/features/organizations/events/providers/find_all_events_membership_provider.dart';
import 'package:convoquei_app/features/organizations/events/widgets/event_card.dart';
import 'package:convoquei_app/features/organizations/events/widgets/event_status_filter_section.dart';
import 'package:convoquei_app/features/organizations/events/widgets/events_tabs.dart';
import 'package:convoquei_app/features/organizations/events/models/enums/organization_event_membership_availability_status.dart';
import 'package:convoquei_app/features/organizations/events/widgets/availability_status_filter_section.dart';
import 'package:convoquei_app/features/organizations/events/widgets/date_range_filter_section.dart';
import 'package:convoquei_app/features/organizations/events/widgets/membership_status_filter_section.dart';
import 'package:convoquei_app/core/network/exceptions/api_exception.dart';
import 'package:convoquei_app/core/services/toast_feedback_service.dart';
import 'package:convoquei_app/features/organizations/events/models/enums/organization_event_function_call_mode.dart';
import 'package:convoquei_app/features/organizations/events/widgets/function_selection_modal.dart';
import 'package:convoquei_app/features/organizations/events/widgets/month_divider.dart';
import 'package:convoquei_app/features/organizations/shared/models/enums/organization_permission.dart';
import 'package:convoquei_app/features/organizations/shared/providers/current_org_provider.dart';
import 'package:convoquei_app/features/organizations/shared/providers/organization_providers.dart';
import 'package:convoquei_app/app/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class OrgEventsPage extends ConsumerStatefulWidget {
  const OrgEventsPage({super.key});

  @override
  ConsumerState<OrgEventsPage> createState() => _OrgEventsPageState();
}

class _OrgEventsPageState extends ConsumerState<OrgEventsPage> {
  OrgEventsTab _selectedTab = OrgEventsTab.all;

  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  String _searchQuery = '';
  bool _hasLoadedOnce = false;

  List<OrganizationEventMembershipStatus>? _customStatus;
  List<OrganizationEventMembershipAvailabilityStatus>? _customAvailabilityStatus;
  List<OrganizationEventStatus>? _customEventStatus;
  DateTime? _customStartDate;
  DateTime? _customEndDate;

  List<OrganizationEventMembershipStatus>? _pendingStatus;
  List<OrganizationEventMembershipAvailabilityStatus>? _pendingAvailabilityStatus;
  List<OrganizationEventStatus>? _pendingEventStatus;
  DateTime? _pendingStartDate;
  DateTime? _pendingEndDate;

  Timer? _debounce;

  EventsFilter _filter = EventsFilter(startAfter: startOfDay(DateTime.now()));

  bool get _hasActiveFilters {
    final tabEventDefault = _eventStatusForTab(_selectedTab);
    final defaultEventSet = {...tabEventDefault};
    final current = _customEventStatus != null
        ? {..._customEventStatus!}
        : defaultEventSet;
    final eventFilterActive = current.length != defaultEventSet.length ||
        !current.containsAll(defaultEventSet);

    final tabMembershipDefault = _membershipStatusForTab(_selectedTab);
    final defaultMembershipSet =
        tabMembershipDefault != null ? {...tabMembershipDefault} : <OrganizationEventMembershipStatus>{};
    final currentMembership = _customStatus != null ? {..._customStatus!} : defaultMembershipSet;
    final membershipFilterActive = currentMembership.length != defaultMembershipSet.length ||
        !currentMembership.containsAll(defaultMembershipSet);

    final tabAvailDefault = _availabilityStatusForTab(_selectedTab);
    final defaultAvailSet = tabAvailDefault != null
        ? {...tabAvailDefault}
        : <OrganizationEventMembershipAvailabilityStatus>{};
    final currentAvail = _customAvailabilityStatus != null
        ? {..._customAvailabilityStatus!}
        : defaultAvailSet;
    final availFilterActive = currentAvail.length != defaultAvailSet.length ||
        !currentAvail.containsAll(defaultAvailSet);

    return membershipFilterActive ||
        availFilterActive ||
        eventFilterActive ||
        _customStartDate != null ||
        _customEndDate != null;
  }

  List<OrganizationEventMembershipStatus>? _membershipStatusForTab(OrgEventsTab tab) =>
      switch (tab) {
        OrgEventsTab.all         => null,
        OrgEventsTab.pending     => [OrganizationEventMembershipStatus.pending],
        OrgEventsTab.mySchedules => [OrganizationEventMembershipStatus.assigned],
      };

  List<OrganizationEventMembershipAvailabilityStatus>? _availabilityStatusForTab(
      OrgEventsTab tab) =>
      switch (tab) {
        OrgEventsTab.all         => null,
        OrgEventsTab.pending     => [OrganizationEventMembershipAvailabilityStatus.notAnswered],
        OrgEventsTab.mySchedules => [OrganizationEventMembershipAvailabilityStatus.available],
      };

  List<OrganizationEventStatus> _eventStatusForTab(OrgEventsTab tab) =>
      switch (tab) {
        OrgEventsTab.all         => [OrganizationEventStatus.scheduled, OrganizationEventStatus.inProgress],
        OrgEventsTab.pending     => [OrganizationEventStatus.scheduled],
        OrgEventsTab.mySchedules => [OrganizationEventStatus.scheduled, OrganizationEventStatus.inProgress],
      };

  EventsFilter _buildFilter({OrgEventsTab? tab, String? name}) {
    final resolvedTab = tab ?? _selectedTab;
    final resolvedMembershipStatus   = _customStatus             ?? _membershipStatusForTab(resolvedTab);
    final resolvedAvailabilityStatus = _customAvailabilityStatus ?? _availabilityStatusForTab(resolvedTab);
    final resolvedEventStatus        = _customEventStatus        ?? _eventStatusForTab(resolvedTab);
    final resolvedName = (name ?? _searchQuery).trim();

    return EventsFilter(
      startAfter:         _customStartDate ?? startOfDay(DateTime.now()),
      startBefore:        _customEndDate,
      name:               resolvedName.isEmpty ? null : resolvedName,
      membershipStatus:   resolvedMembershipStatus,
      availabilityStatus: resolvedAvailabilityStatus,
      eventStatus:        resolvedEventStatus,
    );
  }

  String get _orgId => ref.read(currentOrgProvider).id;

  void _applyFilter(EventsFilter newFilter) {
    setState(() => _filter = newFilter);
    ref
        .read(eventMembershipProvider.notifier)
        .reset(_orgId, newFilter);
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _applyFilter(_buildFilter());
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final pos = _scrollController.position;
    if (pos.pixels < pos.maxScrollExtent - 200) return;

    final s = ref.read(eventMembershipProvider);
    if (s.isLoadingMore || s.isInitialLoading || !s.hasNextPage) return;

    ref
        .read(eventMembershipProvider.notifier)
        .loadNextPage(_orgId, _filter);
  }

  void _handleTabChange(OrgEventsTab newTab) {
    if (newTab == _selectedTab) return;
    setState(() {
      _selectedTab              = newTab;
      _customStatus             = null;
      _customAvailabilityStatus = null;
      _customEventStatus        = null;
    });
    _applyFilter(_buildFilter(tab: newTab));
  }

  void _handleSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() => _searchQuery = value);
      _applyFilter(_buildFilter(name: value));
    });
  }

  void _handleClearFilters() {
    setState(() {
      _customStatus             = null;
      _customAvailabilityStatus = null;
      _customEventStatus        = null;
      _customStartDate          = null;
      _customEndDate            = null;
    });
    _applyFilter(_buildFilter());
  }

  void _handleCreateEvent() {
    context.push(AppPaths.orgEventNew);
  }

  void _handleRetry() {
    ref
        .read(eventMembershipProvider.notifier)
        .reset(_orgId, _filter);
  }

  Future<void> _handleAvailability(
    OrganizationEventMembershipModel event,
    bool available,
  ) async {
    String? functionId;

    if (available && event.calledFunctions.isNotEmpty) {
      final result = await FunctionSelectionModal.show(
        context,
        calledFunctions: event.calledFunctions,
        allowNoFunction:
            event.functionCallMode ==
            OrganizationEventFunctionCallMode.allMembersWithFunctionLimits,
      );
      if (result == null) return;
      functionId = result.functionId;
    }

    try {
      final updated = await ref
          .read(answerAvailabilityProvider.notifier)
          .answer(
            organizationId: _orgId,
            eventId:        event.id,
            available:      available,
            functionId:     functionId,
          );

      if (!mounted) return;
      ref.read(eventMembershipProvider.notifier).updateItem(updated);
    } on ApiException catch (e) {
      if (!mounted) return;
      ToastFeedbackService.showToast(
        context,
        e.userMessage,
        ToastType.error,
      );
    }
  }

  Map<DateTime, List<OrganizationEventMembershipModel>> _groupByMonth(
    List<OrganizationEventMembershipModel> items,
  ) {
    final map = <DateTime, List<OrganizationEventMembershipModel>>{};
    for (final item in items) {
      final key = DateTime(item.startTime.year, item.startTime.month);
      map.putIfAbsent(key, () => []).add(item);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final orgId = ref.watch(currentOrgProvider).id;

    ref.listen(currentOrgProvider, (prev, next) {
      if (prev?.id != next.id) {
        setState(() {
          _selectedTab = OrgEventsTab.all;
          _customStatus = null;
          _customAvailabilityStatus = null;
          _customEventStatus = null;
          _customStartDate = null;
          _customEndDate = null;
          _searchQuery = '';
          _hasLoadedOnce = false;
        });
        _searchController.clear();
        _debounce?.cancel();
        _applyFilter(_buildFilter());
      }
    });

    final eventsState = ref.watch(eventMembershipProvider);
    final currentUser = ref
        .watch(currentUserMembershipOrganizationProvider(orgId))
        .asData!
        .value;
    final canManageEvents = currentUser.hasPermission(OrganizationPermissionEnum.manageEvents);

    if (!eventsState.isInitialLoading) _hasLoadedOnce = true;

    if (eventsState.error != null && eventsState.items.isEmpty && !eventsState.isInitialLoading) {
      return Scaffold(
        body: Center(
          child: DSErrorRetryState(
            onRetry: _handleRetry,
            message: 'Não foi possível carregar os eventos',
          ),
        ),
      );
    }

    final grouped = _groupByMonth(eventsState.items);
    final isPartialLoading = eventsState.isInitialLoading && _hasLoadedOnce;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => ref
            .read(eventMembershipProvider.notifier)
            .resetAsync(_orgId, _filter),
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: _handleSearchChanged,
                            enabled: !isPartialLoading,
                            decoration: const InputDecoration(
                              hintText: 'Buscar por nome ou local...',
                              prefixIcon: Icon(Icons.search_rounded, size: 20),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Opacity(
                          opacity: isPartialLoading ? 0.4 : 1.0,
                          child: AbsorbPointer(
                            absorbing: isPartialLoading,
                            child: DSFilterButton(
                              isActive: _hasActiveFilters,
                              onClear:  _handleClearFilters,
                              onApply: () {
                                setState(() {
                                  _customStatus             = _pendingStatus;
                                  _customAvailabilityStatus = _pendingAvailabilityStatus;
                                  _customEventStatus        = _pendingEventStatus;
                                  _customStartDate          = _pendingStartDate;
                                  _customEndDate            = _pendingEndDate;
                                });
                                _applyFilter(_buildFilter());
                              },
                              childrenBuilder: () {
                                _pendingStatus             = _customStatus             ?? _membershipStatusForTab(_selectedTab);
                                _pendingAvailabilityStatus = _customAvailabilityStatus ?? _availabilityStatusForTab(_selectedTab);
                                _pendingEventStatus        = _customEventStatus        ?? _eventStatusForTab(_selectedTab);
                                _pendingStartDate          = _customStartDate;
                                _pendingEndDate            = _customEndDate;
                                return [
                                  EventStatusFilterSection(
                                    selected: _pendingEventStatus,
                                    onChanged: (statuses) {
                                      setState(() => _pendingEventStatus = statuses);
                                    },
                                  ),
                                  AvailabilityStatusFilterSection(
                                    selected: _pendingAvailabilityStatus,
                                    onChanged: (statuses) {
                                      setState(() => _pendingAvailabilityStatus = statuses);
                                    },
                                  ),
                                  MembershipStatusFilterSection(
                                    selected: _pendingStatus,
                                    onChanged: (statuses) {
                                      setState(() => _pendingStatus = statuses);
                                    },
                                  ),
                                  DateRangeFilterSection(
                                    startDate: _pendingStartDate,
                                    endDate:   _pendingEndDate,
                                    onChanged: (start, end) {
                                      setState(() {
                                        _pendingStartDate = start;
                                        _pendingEndDate   = end;
                                      });
                                    },
                                  ),
                                ];
                              },
                            ),
                          ),
                        ),
                        if (canManageEvents) ...[
                          const SizedBox(width: 10),
                          Opacity(
                            opacity: isPartialLoading ? 0.4 : 1.0,
                            child: AbsorbPointer(
                              absorbing: isPartialLoading,
                              child: GestureDetector(
                                onTap: _handleCreateEvent,
                                child: Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: context.colors.primary,
                                    borderRadius: DSRadius.allMd,
                                    border: Border.all(color: context.colors.border),
                                    boxShadow: DSElevation.md,
                                  ),
                                  child: Icon(
                                    Icons.add_rounded,
                                    size: 22,
                                    color: context.colors.onPrimary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 14),
                    Opacity(
                      opacity: isPartialLoading ? 0.4 : 1.0,
                      child: AbsorbPointer(
                        absorbing: isPartialLoading,
                        child: EventsTabs(
                          selected: _selectedTab,
                          onChanged: _handleTabChange,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            if (eventsState.isInitialLoading)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => const Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: EventCard(skeleton: true),
                    ),
                    childCount: 3,
                  ),
                ),
              )
            else if (eventsState.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: DSEmptyState(
                  icon: Icons.event_busy_rounded,
                  title: switch (_selectedTab) {
                    OrgEventsTab.all         => 'Nenhum evento próximo encontrado',
                    OrgEventsTab.pending     => 'Nenhum evento aguardando sua resposta',
                    OrgEventsTab.mySchedules => 'Você não está escalado em nenhum evento',
                  },
                  description: canManageEvents
                      ? 'Crie o primeiro evento da sua organização e convoque sua equipe.'
                      : null,
                  actionLabel: canManageEvents ? 'Criar evento' : null,
                  onAction: canManageEvents ? _handleCreateEvent : null,
                ),
              )
            else ...[
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final entry  = grouped.entries.elementAt(index);
                      final month  = entry.key;
                      final events = entry.value;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          MonthDivider(month: month),
                          const SizedBox(height: 12),
                          ...events.map(
                            (membership) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: EventCard(
                                key: ValueKey(membership.id),
                                event: membership,
                                onTap: () => context.push(
                                  AppPaths.orgEventDetail(membership.id),
                                ),
                                onAvailable:     () => _handleAvailability(membership, true),
                                onUnavailable:   () => _handleAvailability(membership, false),
                                onLeaveSchedule: () => _handleAvailability(membership, false),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                      );
                    },
                    childCount: grouped.length,
                  ),
                ),
              ),

              if (eventsState.isLoadingMore)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: DSSpinner(size: 32)),
                  ),
                ),

              if (eventsState.error != null && eventsState.items.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                    child: Center(
                      child: TextButton.icon(
                        onPressed: () => ref
                            .read(eventMembershipProvider.notifier)
                            .loadNextPage(_orgId, _filter),
                        icon: const Icon(Icons.refresh_rounded, size: 16),
                        label: const Text('Tentar novamente'),
                      ),
                    ),
                  ),
                ),

              if (!eventsState.hasNextPage && !eventsState.isLoadingMore)
                const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          ],
        ),
      ),
    );
  }
}
