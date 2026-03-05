import 'package:convoquei_app/core/theme/app_theme.dart';
import 'package:convoquei_app/core/widgets/base_modal_stateful_widget.dart';
import 'package:convoquei_app/features/home/widgets/action_tile.dart';
import 'package:convoquei_app/features/organizations/members/models/enums/manage_member_action.dart';
import 'package:convoquei_app/features/organizations/members/widgets/header_member_modal.dart';
import 'package:convoquei_app/features/organizations/shared/models/enums/organization_permission.dart';
import 'package:convoquei_app/features/organizations/shared/models/organization_member_model.dart';
import 'package:convoquei_app/features/organizations/shared/models/organization_my_member_profile_model.dart';
import 'package:flutter/material.dart';

class ManageMemberModal extends BaseModalStatefulWidget {
  const ManageMemberModal({super.key, required this.member, required this.currentUserProfile, required this.onManageMember});

  final OrganizationMemberModel member;
  final OrganizationMyMemberProfile currentUserProfile;
  final bool Function(ManageMemberActionEnum action) onManageMember;

  static Future<bool?> show(
    BuildContext context,
    OrganizationMemberModel member,
    OrganizationMyMemberProfile currentUserProfile,
    bool Function(ManageMemberActionEnum action) onManageMember
  ) => BaseModalStatefulWidget.show<bool>(
    context,
    ManageMemberModal(member: member, currentUserProfile: currentUserProfile, onManageMember: onManageMember),
  );

  @override
  State<ManageMemberModal> createState() => _ManageMemberModalState();
}

class _ManageMemberModalState extends BaseModalState<ManageMemberModal> {
  void _handleManageMember(ManageMemberActionEnum action) {
    bool result = widget.onManageMember(action);

    if (result) {
      BaseModalStatefulWidget.hide(context);
    }
  }
  
  @override
  Widget? get titleWidget => HeaderMemberModal(
    title: "Gerenciar membro",
    userName: widget.member.name,
  );

  Widget _buildEmptyState(BuildContext context, {required IconData icon, required String title, required String message}) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 40, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: theme.textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  List<Widget> buildBody(BuildContext context) {
    final bool isSelf = widget.member.id == widget.currentUserProfile.id;
    final bool isOwner = widget.member.permissions.any((p) => p == OrganizationPermissionEnum.owner);

    final bool canKickMembers = widget.currentUserProfile.hasPermission(OrganizationPermissionEnum.kickMembers) && !isSelf && !isOwner;
    final bool canManageGroups = widget.currentUserProfile.hasPermission(OrganizationPermissionEnum.manageGroups);
    final bool canEditRoles = widget.currentUserProfile.hasPermission(OrganizationPermissionEnum.owner) && !isOwner;

    final List<Widget> actions = [
      if (canManageGroups)
        ActionTile(
          title: 'Gerenciar Grupos',
          description: 'Adicionar ou remover de grupos/ministerios',
          icon: Icons.groups_rounded,
          onTap: () {
            _handleManageMember(ManageMemberActionEnum.manageGroups);
          },
        ),
      if (canEditRoles)
        ActionTile(
          title: 'Gerenciar Papeis',
          description: 'Gerenciar permissões administrativas do membro',
          icon: Icons.verified_user_rounded,
          iconBgColor: const Color(0xFFF5F3FF),
          iconColor: const Color(0xFF7C3AED),
          onTap: () {
            _handleManageMember(ManageMemberActionEnum.manageRoles);
          },
        ),
      if (canKickMembers)
        ActionTile(
          title: 'Expulsar membro',
          description:
              'Remover ${widget.member.name} da organização',
          icon: Icons.person_remove,
          destructive: true,
          onTap: () {
            _handleManageMember(ManageMemberActionEnum.kickMember);
          },
        ),
    ];

    if (actions.isEmpty) {
      return [
        _buildEmptyState(
          context,
          icon: Icons.security_rounded,
          title: 'Sem permissões administrativas',
          message: 'Você não possui permissões para gerenciar este membro. Fale com o líder da organização para ser adicionado ao papel desejado.',
        ),
      ];
    }

    return actions.map((action) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: action,
    )).toList();
  }
}
