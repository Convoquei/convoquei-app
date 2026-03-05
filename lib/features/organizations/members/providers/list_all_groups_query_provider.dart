import 'package:convoquei_app/core/models/state_list_paged.dart';
import 'package:convoquei_app/features/organizations/members/models/organization_group_model.dart';
import 'package:convoquei_app/features/organizations/members/models/requests/find_all_organization_groups_request.dart';
import 'package:convoquei_app/features/organizations/members/repositories/organization_groups_repository.dart';
import 'package:convoquei_app/features/organizations/shared/providers/selected_organization_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final groupsPagedProvider =
    NotifierProvider.autoDispose<
      GroupsNotifier,
      StateListPaged<OrganizationGroupModel>
    >(GroupsNotifier.new);

class GroupsNotifier extends Notifier<StateListPaged<OrganizationGroupModel>> {
  @override
  StateListPaged<OrganizationGroupModel> build() {
    return StateListPaged();
  }

  Future<void> loadNextPage({int size = 10}) async {
    final organizationId = ref.read(selectedOrganizationProvider)?.id;

    if (organizationId == null) return;

    if (state.isLoadingMore || state.isInitialLoading) return;

    state = state.page == 0
        ? state.copyWith(isInitialLoading: true)
        : state.copyWith(isLoadingMore: true);

    try {
      final repo = ref.read(organizationGroupsRepositoryProvider);

      final result = await repo.findAllGroups(
        organizationId,
        FindAllOrganizationGroupsRequest(page: state.page, size: size),
      );

      state = state.copyWith(
        items: [...state.items, ...result.items],
        page: state.page + 1,
        hasNextPage: result.hasNextPage,
        isInitialLoading: false,
        isLoadingMore: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        error: e,
        isInitialLoading: false,
        isLoadingMore: false,
      );
    }
  }

  void reset() {
    state = state.reset();

    loadNextPage();
  }
}
