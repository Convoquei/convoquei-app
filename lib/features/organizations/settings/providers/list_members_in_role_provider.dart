import 'package:convoquei_app/features/organizations/shared/models/organization_role_member_model.dart';
import 'package:convoquei_app/features/organizations/shared/repositories/organization_role_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final roleMembersProvider = FutureProvider
    .autoDispose
    .family<List<OrganizationRoleMemberModel>, ({String organizationId, String roleId})>((ref, args) async {
      final repo = ref.read(organizationRoleRepositoryProvider);

      final result = await repo.getOrganizationRoleMembers(
        organizationId: args.organizationId,
        roleId: args.roleId,
        page: 0,
        pageSize: 100
      );

      return result.items;
    });
