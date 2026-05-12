import 'dart:async';

import 'package:convoquei_app/features/organizations/members/models/organization_function_member_model.dart';
import 'package:convoquei_app/features/organizations/members/models/requests/find_function_members_request.dart';
import 'package:convoquei_app/features/organizations/members/repositories/organization_functions_repository.dart';
import 'package:convoquei_app/features/organizations/shared/providers/selected_organization_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'function_members_paged_provider.g.dart';

@riverpod
class FunctionMembers extends _$FunctionMembers {
  @override
  Future<List<OrganizationFunctionMemberModel>> build(String functionId) async {
    final organizationId = ref.read(selectedOrganizationProvider)?.id;
    if (organizationId == null) return [];

    final repo = ref.read(organizationFunctionsRepositoryProvider);
    final result = await repo.findFunctionMembers(
      organizationId,
      functionId,
      FindFunctionMembersRequest(page: 0, size: 100),
    );
    return result.items;
  }

  void removeMember(String memberId) {
    state = state.whenData(
      (items) => items.where((m) => m.id != memberId).toList(),
    );
  }

  void clearAll() {
    state = const AsyncData([]);
  }
}
