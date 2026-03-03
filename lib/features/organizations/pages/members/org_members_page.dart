import 'package:convoquei_app/core/theme/app_theme.dart';
import 'package:convoquei_app/core/widgets/app_search_input.dart';
import 'package:convoquei_app/features/organizations/widgets/manage_groups_modal.dart';
import 'package:convoquei_app/features/organizations/widgets/team_member_tile.dart';
import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// Mock data — substituir por modelos e providers reais ao refatorar
// ---------------------------------------------------------------------------

final _leadershipMembers = [
  TeamMemberData(
    name: 'Lucas Silva',
    avatarUrl: 'https://i.pravatar.cc/100?img=11',
    isCurrentUser: true,
    badges: [
      TeamMemberBadge(label: 'Admin', style: TeamMemberBadgeStyle.admin),
      TeamMemberBadge(label: 'Vocal'),
    ],
  ),
  TeamMemberData(
    name: 'Ana Clara',
    avatarUrl: 'https://i.pravatar.cc/100?img=33',
    badges: [
      TeamMemberBadge(label: 'Líder', style: TeamMemberBadgeStyle.leader),
      TeamMemberBadge(label: 'Vocal'),
    ],
  ),
];

final _regularMembers = [
  TeamMemberData(
    name: 'João Pedro',
    avatarUrl: 'https://i.pravatar.cc/100?img=12',
    badges: [TeamMemberBadge(label: 'Instrumental')],
  ),
  TeamMemberData(
    name: 'Mariana Luz',
    avatarUrl: 'https://i.pravatar.cc/100?img=47',
    badges: [
      TeamMemberBadge(label: 'Vocal'),
      TeamMemberBadge(label: 'Mídia'),
    ],
  ),
  TeamMemberData(
    name: 'Tiago Silva',
    hasNoGroup: true,
  ),
];

// ---------------------------------------------------------------------------
// Page
// ---------------------------------------------------------------------------

class OrgMembersPage extends StatefulWidget {
  const OrgMembersPage({super.key});

  @override
  State<OrgMembersPage> createState() => _OrgMembersPageState();
}

class _OrgMembersPageState extends State<OrgMembersPage> {
  int _tabIndex = 0; // 0 = Membros, 1 = Grupos

  void _openGroupModal(String memberName) {
    ManageGroupsModal.show(context, memberName: memberName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
              child: Column(
                children: [
                  _TeamToggle(
                    selectedIndex: _tabIndex,
                    onChanged: (i) => setState(() => _tabIndex = i),
                  ),
                  const SizedBox(height: 14),

                  // Search + invite row
                  Row(
                    children: [
                      Expanded(
                        child: AppSearchInput(hint: 'Procurar membro...'),
                      ),
                      const SizedBox(width: 12),
                      _InviteButton(onTap: () {}),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Leadership section
                  _MemberSection(
                    title: 'Liderança',
                    count: _leadershipMembers.length,
                    members: _leadershipMembers,
                    onMenuTap: _openGroupModal,
                  ),

                  const SizedBox(height: 20),

                  // Regular members section
                  _MemberSection(
                    title: 'Membros',
                    count: 22,
                    members: _regularMembers,
                    onMenuTap: _openGroupModal,
                    onAssignGroupTap: _openGroupModal,
                  ),
                  _MemberSection(
                    title: 'Membros',
                    count: 22,
                    members: _regularMembers,
                    onMenuTap: _openGroupModal,
                    onAssignGroupTap: _openGroupModal,
                  ),
                  _MemberSection(
                    title: 'Membros',
                    count: 22,
                    members: _regularMembers,
                    onMenuTap: _openGroupModal,
                    onAssignGroupTap: _openGroupModal,
                  ),
                  _MemberSection(
                    title: 'Membros',
                    count: 22,
                    members: _regularMembers,
                    onMenuTap: _openGroupModal,
                    onAssignGroupTap: _openGroupModal,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Toggle Membros / Grupos
// ---------------------------------------------------------------------------
class _TeamToggle extends StatelessWidget {
  const _TeamToggle({
    required this.selectedIndex,
    required this.onChanged,
  });

  final int selectedIndex;
  final ValueChanged<int> onChanged;

  static const _labels = ['Membros', 'Grupos'];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: List.generate(_labels.length, (i) {
          final selected = selectedIndex == i;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: selected
                      ? const Color(0xFFEFF6FF)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(
                  _labels[i],
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight:
                        selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected
                        ? AppTheme.primaryColor
                        : AppTheme.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Invite button (orange)
// ---------------------------------------------------------------------------
class _InviteButton extends StatelessWidget {
  const _InviteButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.secondaryColor,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: const SizedBox(
          width: 48,
          height: 48,
          child: Icon(Icons.person_add_rounded, color: Colors.white, size: 22),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Section card with member list
// ---------------------------------------------------------------------------
class _MemberSection extends StatelessWidget {
  const _MemberSection({
    required this.title,
    required this.count,
    required this.members,
    required this.onMenuTap,
    this.onAssignGroupTap,
  });

  final String title;
  final int count;
  final List<TeamMemberData> members;
  final void Function(String memberName) onMenuTap;
  final void Function(String memberName)? onAssignGroupTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Padding(
          padding: const EdgeInsets.only(left: 4, right: 4, bottom: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      fontSize: 17,
                    ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$count membros',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
            ],
          ),
        ),

        // Card
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Column(
              children: List.generate(members.length * 2 - 1, (i) {
                if (i.isOdd) {
                  return const Divider(
                    height: 1,
                    indent: 16,
                    endIndent: 16,
                    color: Color(0xFFF1F5F9),
                  );
                }
                final member = members[i ~/ 2];
                return TeamMemberTile(
                  member: member,
                  onMenuTap: () => onMenuTap(member.name),
                  onAssignGroupTap: member.hasNoGroup && onAssignGroupTap != null
                      ? () => onAssignGroupTap!(member.name)
                      : null,
                );
              }),
            ),
          ),
        ),
      ],
    );
  }
}
