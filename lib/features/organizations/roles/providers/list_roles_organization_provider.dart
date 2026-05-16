import 'package:convoquei_app/core/models/state_list_paged.dart';
import 'package:convoquei_app/features/organizations/shared/models/organization_role_model.dart';
import 'package:convoquei_app/features/organizations/shared/models/organization_role_permission_model.dart';
import 'package:convoquei_app/features/organizations/shared/providers/selected_organization_provider.dart';
import 'package:convoquei_app/features/organizations/shared/repositories/organization_role_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'list_roles_organization_provider.g.dart';

@riverpod
class RolesNotifier extends _$RolesNotifier {
  int _generation = 0;

  @override
  StateListPaged<OrganizationRoleModel> build() => const StateListPaged();

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
          .read(organizationRoleRepositoryProvider)
          .getOrganizationRoles(
            organizationId: organizationId,
            page: state.page,
            pageSize: size,
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

  void updateRolePermissions({
    required String roleId,
    required List<OrganizationRolePermissionModel> permissions,
  }) {
    state = state.copyWith(
      items: state.items.map((role) {
        if (role.id != roleId) return role;
        return role.copyWith(permissions: permissions);
      }).toList(),
    );
  }

  void removeRole({required String roleId}) {
    state = state.copyWith(
      items: state.items.where((role) => role.id != roleId).toList(),
    );
  }
}
