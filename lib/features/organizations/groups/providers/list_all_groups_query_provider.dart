import 'package:convoquei_app/core/models/state_list_paged.dart';
import 'package:convoquei_app/features/organizations/groups/models/organization_group_model.dart';
import 'package:convoquei_app/features/organizations/groups/models/requests/find_all_organization_groups_request.dart';
import 'package:convoquei_app/features/organizations/groups/repositories/organization_groups_repository.dart';
import 'package:convoquei_app/features/organizations/shared/providers/selected_organization_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final groupsPagedProvider =
    NotifierProvider.autoDispose<
      GroupsNotifier,
      StateListPaged<OrganizationGroupModel>
    >(GroupsNotifier.new);

class GroupsNotifier extends Notifier<StateListPaged<OrganizationGroupModel>> {
  int _generation = 0;

  @override
  StateListPaged<OrganizationGroupModel> build() {
    return const StateListPaged();
  }

  Future<void> loadNextPage({int size = 10}) async {
    final organizationId = ref.read(selectedOrganizationProvider)?.id;
    if (organizationId == null) return;
    if (!state.hasNextPage || state.isLoadingMore) return;

    final currentGeneration = _generation;

    state = state.copyWith(
      isInitialLoading: state.page == 0,
      isLoadingMore: state.page > 0,
      clearError: true,
    );

    try {
      final repo = ref.read(organizationGroupsRepositoryProvider);

      final result = await repo.findAllGroups(
        organizationId,
        FindAllOrganizationGroupsRequest(page: state.page, size: size),
      );

      if (!ref.mounted) return;
      if (_generation != currentGeneration) return;

      state = state.copyWith(
        items: [...state.items, ...result.items],
        page: state.page + 1,
        hasNextPage: result.hasNextPage,
        isInitialLoading: false,
        isLoadingMore: false,
      );
    } catch (e) {
      if (!ref.mounted) return;
      if (_generation != currentGeneration) return;

      state = state.copyWith(
        error: e,
        isInitialLoading: false,
        isLoadingMore: false,
      );
    }
  }

  void reset() {
    _generation++;
    state = const StateListPaged();
    loadNextPage();
  }

  Future<void> resetAsync() {
    _generation++;
    state = const StateListPaged();
    return loadNextPage();
  }

  void decrementParticipantCount(String groupId) {
    state = state.copyWith(
      items: state.items.map((g) {
        if (g.id == groupId) {
          return g.copyWith(
            participantCount:
                (g.participantCount - 1).clamp(0, double.infinity).toInt(),
          );
        }
        return g;
      }).toList(),
    );
  }

  void clearParticipantCount(String groupId) {
    state = state.copyWith(
      items: state.items.map((g) {
        if (g.id == groupId) return g.copyWith(participantCount: 0);
        return g;
      }).toList(),
    );
  }
}
