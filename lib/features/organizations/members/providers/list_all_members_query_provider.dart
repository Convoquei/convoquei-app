import 'package:convoquei_app/core/models/state_list_paged.dart';
import 'package:convoquei_app/features/organizations/members/models/requests/find_all_organization_members_request.dart';
import 'package:convoquei_app/features/organizations/members/repositories/organization_members_repository.dart';
import 'package:convoquei_app/features/organizations/shared/models/organization_member_function_model.dart';
import 'package:convoquei_app/features/organizations/shared/models/organization_member_group_model.dart';
import 'package:convoquei_app/features/organizations/shared/models/organization_member_model.dart';
import 'package:convoquei_app/features/organizations/shared/providers/selected_organization_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final membersPagedProvider =
    NotifierProvider.autoDispose<MembersNotifier, StateListPaged<OrganizationMemberModel>>(
      MembersNotifier.new,
    );

class MembersNotifier extends Notifier<StateListPaged<OrganizationMemberModel>> {
  @override
  StateListPaged<OrganizationMemberModel> build() {
    return StateListPaged();
  }

  Future<void> loadNextPage({String? name}) async {
    final organizationId = ref.read(selectedOrganizationProvider)?.id;

    if (organizationId == null) return;

    if (state.isLoadingMore || state.isInitialLoading) return;

    // Seta loading
    state = state.page == 0
        ? state.copyWith(isInitialLoading: true)
        : state.copyWith(isLoadingMore: true);

    try {
      final repo = ref.read(organizationMembersRepositoryProvider);

      final result = await repo.findAllMembers(
        organizationId,
        FindAllOrganizationMembersRequest(
          page: state.page,
          size: 10,
          name: name,
          status: 'ACTIVE',
        ),
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

  void reset({String? name}) {
    state = state.reset();
    loadNextPage(name: name);
  }

  void updateMemberGroups(String memberId, List<OrganizationMemberGroupModel> groups) {
    state = state.copyWith(
      items: state.items.map((m) {
        if (m.id == memberId) return m.copyWith(groups: groups);
        return m;
      }).toList(),
    );
  }

  void updateMemberFunctions(String memberId, List<OrganizationMemberFunctionModel> functions) {
    state = state.copyWith(
      items: state.items.map((m) {
        if (m.id == memberId) return m.copyWith(functions: functions);
        return m;
      }).toList(),
    );
  }
}
