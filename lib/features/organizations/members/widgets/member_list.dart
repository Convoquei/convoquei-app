import 'package:convoquei_app/core/models/paged_response_model.dart';
import 'package:convoquei_app/features/organizations/members/widgets/member_list_tile.dart';
import 'package:convoquei_app/features/organizations/shared/models/organization_member_model.dart';
import 'package:flutter/material.dart';

class MemberList extends StatelessWidget {
  const MemberList({
    super.key,
    required this.stateList,
    required this.currentUserId,
    this.onOptionsPressed,
  });

  final PagedResponseModel<OrganizationMemberModel> stateList;
  final String currentUserId;
  final void Function(OrganizationMemberModel member)? onOptionsPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final members = stateList.items;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Todos os Membros',
                style: theme.textTheme.titleLarge?.copyWith(fontSize: 18),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${stateList.totalItems} total',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(8),
              itemCount: members.length,
              separatorBuilder: (_, __) => const Divider(
                height: 1,
                thickness: 1,
                indent: 20,
                endIndent: 20,
                color: Color(0xFFF1F5F9),
              ),
              itemBuilder: (_, i) => MemberListTile(
                member: members[i],
                isCurrentUser: members[i].id == currentUserId,
                onOptionsPressed: onOptionsPressed != null
                    ? () => onOptionsPressed!(members[i])
                    : null,
              ),
            ),
          ),
        ),
      ],
    );
  }
}