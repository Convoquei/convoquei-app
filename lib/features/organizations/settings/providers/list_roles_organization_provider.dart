import 'package:convoquei_app/core/models/paged_response_model.dart';
import 'package:convoquei_app/features/organizations/shared/models/OrganizationRolePermissionModel.dart';
import 'package:convoquei_app/features/organizations/shared/models/organization_role_model.dart';
import 'package:convoquei_app/features/organizations/shared/repositories/organization_role_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final listRolesOrganizationProvider =
    AsyncNotifierProvider.autoDispose<
      ListRolesOrganizationNotifier,
      PagedResponseModel<OrganizationRoleModel>
    >(ListRolesOrganizationNotifier.new);

class ListRolesOrganizationNotifier
    extends AsyncNotifier<PagedResponseModel<OrganizationRoleModel>> {
  @override
  Future<PagedResponseModel<OrganizationRoleModel>> build() async {
    return PagedResponseModel(
      items: [],
      page: 1,
      size: 10,
      totalItems: 0,
      totalPages: 0,
      hasNextPage: true,
      hasPreviousPage: false,
    );
  }

  Future<void> loadFirstPage(String organizationId) async {
    final repo = ref.read(organizationRoleRepositoryProvider);

    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      return await repo.getOrganizationRoles(
        organizationId: organizationId,
        page: 0,
        pageSize: 10,
      );
    });
  }

  Future<void> loadNextPage(String organizationId) async {
    final current = state.value;

    if (current == null || current.hasNextPage != true) return;

    final repo = ref.read(organizationRoleRepositoryProvider);

    final nextPage = (current.page) + 1;

    final result = await repo.getOrganizationRoles(
      organizationId: organizationId,
      page: nextPage,
      pageSize: current.size,
    );

    state = AsyncData(
      result.copyWith(items: [...current.items, ...result.items]),
    );
  }

  void updateRolePermissions({
    required String roleId,
    required List<OrganizationRolePermissionModel> permissions,
  }) {
    final current = state.value;
    if (current == null) return;

    final updatedItems = current.items.map((role) {
      if (role.id != roleId) return role;

      return role.copyWith(permissions: permissions);
    }).toList();

    state = AsyncData(current.copyWith(items: updatedItems));
  }

  void removeRole({required String roleId}) {
    final current = state.value;
    if (current == null) return;

    final updatedItems =
        current.items.where((role) => role.id != roleId).toList();

    state = AsyncData(current.copyWith(items: updatedItems));
  }

  Future<void> refresh(String organizationId) async {
    await loadFirstPage(organizationId);
  }
}
