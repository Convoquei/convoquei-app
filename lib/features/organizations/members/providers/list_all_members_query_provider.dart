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
  int _generation = 0;
  String? _name;

  @override
  StateListPaged<OrganizationMemberModel> build() {
    return const StateListPaged();
  }

  Future<void> loadNextPage() async {
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
      final repo = ref.read(organizationMembersRepositoryProvider);

      final result = await repo.findAllMembers(
        organizationId,
        FindAllOrganizationMembersRequest(
          page: state.page,
          size: 10,
          name: _name,
          status: 'ACTIVE',
        ),
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

  void reset({String? name}) {
    _generation++;
    _name = name;
    state = const StateListPaged();
    loadNextPage();
  }

  Future<void> resetAsync({String? name}) {
    _generation++;
    _name = name;
    state = const StateListPaged();
    return loadNextPage();
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
