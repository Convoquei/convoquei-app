import 'package:convoquei_app/core/models/state_list_paged.dart';
import 'package:convoquei_app/features/organizations/members/models/organization_function_member_model.dart';
import 'package:convoquei_app/features/organizations/members/models/requests/find_function_members_request.dart';
import 'package:convoquei_app/features/organizations/members/repositories/organization_functions_repository.dart';
import 'package:convoquei_app/features/organizations/shared/providers/selected_organization_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final functionMembersPagedProvider = NotifierProvider.autoDispose
    .family<FunctionMembersNotifier,
        StateListPaged<OrganizationFunctionMemberModel>, String>(
  FunctionMembersNotifier.new,
);

class FunctionMembersNotifier
    extends Notifier<StateListPaged<OrganizationFunctionMemberModel>> {
  FunctionMembersNotifier(this.functionId);
  final String functionId;

  @override
  StateListPaged<OrganizationFunctionMemberModel> build() {
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
      final repo = ref.read(organizationFunctionsRepositoryProvider);

      final result = await repo.findFunctionMembers(
        organizationId,
        functionId,
        FindFunctionMembersRequest(page: state.page, size: 20),
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

  void removeMember(String memberId) {
    state = state.copyWith(
      items: state.items.where((m) => m.id != memberId).toList(),
    );
  }

  void clearAll() {
    state = StateListPaged();
  }
}
