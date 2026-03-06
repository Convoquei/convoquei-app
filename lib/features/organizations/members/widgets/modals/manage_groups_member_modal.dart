import 'package:convoquei_app/core/theme/app_theme.dart';
import 'package:convoquei_app/core/widgets/modals/multi_select_modal.dart';
import 'package:convoquei_app/features/organizations/members/models/organization_group_model.dart';
import 'package:convoquei_app/features/organizations/members/models/requests/find_all_organization_groups_request.dart';
import 'package:convoquei_app/features/organizations/members/providers/list_all_members_query_provider.dart';
import 'package:convoquei_app/features/organizations/members/providers/update_member_groups_provider.dart';
import 'package:convoquei_app/features/organizations/members/repositories/organization_groups_repository.dart';
import 'package:convoquei_app/features/organizations/members/widgets/modals/create_group_modal.dart';
import 'package:convoquei_app/core/widgets/header_modal_title_subtitle.dart';
import 'package:convoquei_app/features/organizations/members/widgets/no_groups_empty_state.dart';
import 'package:convoquei_app/features/organizations/shared/models/organization_member_group_model.dart';
import 'package:convoquei_app/features/organizations/shared/models/organization_member_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ManageGroupsMemberModal {
  ManageGroupsMemberModal._();

  static Future<void> show(
      BuildContext context,
      OrganizationMemberModel member,
      String organizationId,
      ) {
    return MultiSelectModal.show<OrganizationGroupModel>(
      context,
      titleWidget: HeaderModalTitleSubtitle(
        title: 'Gerenciar grupos',
        subtitle: member.name,
      ),
      title: 'Gerenciar grupos',
      subtitle: 'Selecione os grupos do membro',
      fetcher: (ref) async {
        final repo = ref.read(organizationGroupsRepositoryProvider);
        final result = await repo.findAllGroups(
          organizationId,
          FindAllOrganizationGroupsRequest(page: 0, size: 100),
        );
        return result.items;
      },
      idExtractor: (group) => group.id,
      initialSelectedIds: member.groups.map((g) => g.id).toSet(),
      itemBuilder: (group, isSelected, onTap) => _GroupTile(
        group: group,
        isSelected: isSelected,
        onTap: onTap,
      ),
      emptyWidget: Builder(
        builder: (context) => NoGroupsEmptyState(
          onCreateGroup: () => CreateGroupModal.show(context, organizationId),
        ),
      ),
      onSave: (selectedIds) async {
        final container = ProviderScope.containerOf(context);

        await container
            .read(updateMemberGroupsProvider.notifier)
            .execute(
          organizationId: organizationId,
          memberId: member.id,
          groupIds: selectedIds.toList(),
        );

        final allGroups = await container
            .read(organizationGroupsRepositoryProvider)
            .findAllGroups(
          organizationId,
          FindAllOrganizationGroupsRequest(page: 0, size: 100),
        );

        final selectedGroups = allGroups.items
            .where((g) => selectedIds.contains(g.id))
            .map((g) => OrganizationMemberGroupModel(id: g.id, name: g.name))
            .toList();

        container
            .read(membersPagedProvider.notifier)
            .updateMemberGroups(member.id, selectedGroups);
      },
    );
  }
}

class _GroupTile extends StatelessWidget {
  const _GroupTile({
    required this.group,
    required this.isSelected,
    required this.onTap,
  });

  final OrganizationGroupModel group;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.primaryColor.withOpacity(0.05)
                : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? AppTheme.primaryColor.withOpacity(0.4)
                  : const Color(0xFFE2E8F0),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(group.emoji, style: const TextStyle(fontSize: 22)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  group.name,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E293B),
                  ),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.primaryColor : Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.primaryColor
                        : const Color(0xFFCBD5E1),
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}