import 'package:convoquei_app/core/models/state_list_paged.dart';
import 'package:convoquei_app/features/organizations/members/models/organization_function_model.dart';
import 'package:convoquei_app/features/organizations/members/models/requests/find_all_organization_functions_request.dart';
import 'package:convoquei_app/features/organizations/members/repositories/organization_functions_repository.dart';
import 'package:convoquei_app/features/organizations/shared/providers/selected_organization_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final functionsPagedProvider =
    NotifierProvider.autoDispose<
      FunctionsNotifier,
      StateListPaged<OrganizationFunctionModel>
    >(FunctionsNotifier.new);

class FunctionsNotifier extends Notifier<StateListPaged<OrganizationFunctionModel>> {
  @override
  StateListPaged<OrganizationFunctionModel> build() {
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
      final repo = ref.read(organizationFunctionsRepositoryProvider);

      final result = await repo.findAllFunctions(
        organizationId,
        FindAllOrganizationFunctionsRequest(page: state.page, size: size),
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

  void decrementMemberCount(String functionId) {
    state = state.copyWith(
      items: state.items.map((f) {
        if (f.id == functionId) {
          return f.copyWith(memberCount: (f.memberCount - 1).clamp(0, double.infinity).toInt());
        }
        return f;
      }).toList(),
    );
  }

  void clearMemberCount(String functionId) {
    state = state.copyWith(
      items: state.items.map((f) {
        if (f.id == functionId) return f.copyWith(memberCount: 0);
        return f;
      }).toList(),
    );
  }
}
