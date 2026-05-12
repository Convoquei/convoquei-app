import 'package:convoquei_app/core/models/state_list_paged.dart';
import 'package:convoquei_app/features/organizations/members/models/organization_function_model.dart';
import 'package:convoquei_app/features/organizations/members/models/requests/find_all_organization_functions_request.dart';
import 'package:convoquei_app/features/organizations/members/repositories/organization_functions_repository.dart';
import 'package:convoquei_app/features/organizations/shared/providers/selected_organization_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'list_all_functions_query_provider.g.dart';

@riverpod
class FunctionsNotifier extends _$FunctionsNotifier {
  int _generation = 0;
  String? _name;

  @override
  StateListPaged<OrganizationFunctionModel> build() {
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
      final result = await ref
          .read(organizationFunctionsRepositoryProvider)
          .findAllFunctions(
            organizationId,
            FindAllOrganizationFunctionsRequest(page: state.page, size: size, name: _name),
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
        isInitialLoading: false,
        isLoadingMore: false,
        error: e,
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
