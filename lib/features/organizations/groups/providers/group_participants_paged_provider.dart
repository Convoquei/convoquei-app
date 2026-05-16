import 'package:convoquei_app/core/models/state_list_paged.dart';
import 'package:convoquei_app/features/organizations/groups/models/organization_group_participant_model.dart';
import 'package:convoquei_app/features/organizations/groups/models/requests/find_group_participants_request.dart';
import 'package:convoquei_app/features/organizations/groups/repositories/organization_groups_repository.dart';
import 'package:convoquei_app/features/organizations/shared/providers/selected_organization_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final groupParticipantsPagedProvider = NotifierProvider.autoDispose
    .family<GroupParticipantsNotifier,
    StateListPaged<OrganizationGroupParticipantModel>, String>(
  GroupParticipantsNotifier.new,
);

class GroupParticipantsNotifier extends Notifier<StateListPaged<OrganizationGroupParticipantModel>> {

  GroupParticipantsNotifier(this.groupId);
  final String groupId;

  @override
  StateListPaged<OrganizationGroupParticipantModel> build() {
    return StateListPaged();
  }

  Future<void> loadNextPage() async {
    final organizationId = ref.read(selectedOrganizationProvider)?.id;
    if (organizationId == null) return;

    if (state.isLoadingMore || state.isInitialLoading) return;

    state = state.page == 0
        ? state.copyWith(isInitialLoading: true)
        : state.copyWith(isLoadingMore: true);

    try {
      final repo = ref.read(organizationGroupsRepositoryProvider);

      final result = await repo.findGroupParticipants(
        organizationId,
        groupId,
        FindGroupParticipantsRequest(page: state.page, size: 20),
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

  void removeParticipant(String participantId) {
    state = state.copyWith(
      items: state.items.where((p) => p.id != participantId).toList(),
    );
  }

  void clearAll() {
    state = StateListPaged();
  }
}
