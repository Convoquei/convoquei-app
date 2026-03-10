import 'package:convoquei_app/core/models/state_list_paged.dart';
import 'package:convoquei_app/features/organizations/events/models/orgnaization_event_membership_model.dart';
import 'package:convoquei_app/features/organizations/events/models/requests/find_all_events_organization_membership_request.dart';
import 'package:convoquei_app/features/organizations/events/repositories/organization_events_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/events_filter_model.dart';

part 'find_all_events_membership_provider.g.dart';

@riverpod
class EventMembershipNotifier extends _$EventMembershipNotifier {
  /// Incrementado a cada reset — requisições de gerações anteriores são ignoradas.
  int _generation = 0;

  @override
  StateListPaged<OrganizationEventMembershipModel> build() {
    return const StateListPaged();
  }

  Future<void> loadNextPage(String organizationId, EventsFilter filter) async {
    if (!state.hasNextPage || state.isLoadingMore || state.isInitialLoading) return;

    final currentGeneration = _generation;

    state = state.copyWith(
      isInitialLoading: state.page == 0,
      isLoadingMore: state.page > 0,
      clearError: true,
    );

    try {
      final result = await ref
          .read(organizationEventsRepositoryProvider)
          .findAllEvents(
        organizationId: organizationId,
        request: FindAllEventsOrganizationMembershipRequest(
          page: state.page,
          size: 20,
          status: filter.status,
          startAfter: filter.startAfter,
          startBefore: filter.startBefore,
        ),
      );

      if (!ref.mounted) return;
      if (_generation != currentGeneration) return; // resposta obsoleta

      state = state.copyWith(
        items: [...state.items, ...result.items],
        page: state.page + 1,
        hasNextPage: result.hasNextPage,
        isInitialLoading: false,
        isLoadingMore: false,
      );
    } catch (e) {
      if (!ref.mounted) return;
      if (_generation != currentGeneration) return; // resposta obsoleta

      state = state.copyWith(
        isInitialLoading: false,
        isLoadingMore: false,
        error: e,
      );
    }
  }

  void reset(String organizationId, EventsFilter filter) {
    _generation++;          // invalida qualquer requisição em voo
    state = const StateListPaged();
    loadNextPage(organizationId, filter);
  }
}