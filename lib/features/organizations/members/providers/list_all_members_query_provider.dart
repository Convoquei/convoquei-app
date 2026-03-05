import 'package:convoquei_app/core/models/state_list_paged.dart';
import 'package:convoquei_app/features/organizations/members/models/requests/find_all_organization_members_request.dart';
import 'package:convoquei_app/features/organizations/members/repositories/organization_members_repository.dart';
import 'package:convoquei_app/features/organizations/shared/models/organization_member_model.dart';
import 'package:convoquei_app/features/organizations/shared/providers/selected_organization_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final membersPagedProvider =
    NotifierProvider.autoDispose<MembersNotifier, StateListPaged<OrganizationMemberModel>>(
      MembersNotifier.new,
    );

class MembersNotifier extends Notifier<StateListPaged<OrganizationMemberModel>> {
  @override
  StateListPaged<OrganizationMemberModel> build() {
    ref.onDispose(() => debugPrint("Descartar MembersNotifier"));

    Future.microtask(() => loadNextPage());
    
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

  void removeMember(String memberId) {
    final before = state.items.length;

    final newItems = state.items.where((m) => m.id != memberId).toList();
    if (newItems.length == before) return;

    state = state.copyWith(
      items: newItems,
    );
  }

  void updateMember(OrganizationMemberModel updated) {
    final newItems = state.items.map((m) => m.id == updated.id ? updated : m).toList();
    state = state.copyWith(items: newItems);
  }

  /// Remove [groupId] from every member's groups list.
  void removeGroupFromAllMembers(String groupId) {
    state = state.copyWith(
      items: state.items
          .map((m) => m.copyWith(
                groups: m.groups.where((g) => g.id != groupId).toList(),
              ))
          .toList(),
    );
  }

  /// Remove [groupId] only from the member identified by [memberId].
  void removeGroupFromMember(String memberId, String groupId) {
    state = state.copyWith(
      items: state.items
          .map((m) => m.id == memberId
              ? m.copyWith(
                  groups: m.groups.where((g) => g.id != groupId).toList(),
                )
              : m)
          .toList(),
    );
  }
}
