import 'package:convoquei_app/core/services/user_feedback_service.dart';
import 'package:convoquei_app/core/theme/app_theme.dart';
import 'package:convoquei_app/core/widgets/alert_banner.dart';
import 'package:convoquei_app/core/widgets/base_scrollable_page.dart';
import 'package:convoquei_app/core/widgets/header_modal_title_subtitle.dart';
import 'package:convoquei_app/core/widgets/modals/multi_select_modal.dart';
import 'package:convoquei_app/core/widgets/selectable_tile.dart';
import 'package:convoquei_app/core/widgets/tag_label.dart';
import 'package:convoquei_app/features/organizations/settings/providers/avaliable_permissions_provider.dart';
import 'package:convoquei_app/features/organizations/settings/providers/create_role_provider.dart';
import 'package:convoquei_app/features/organizations/settings/providers/delete_role_provider.dart';
import 'package:convoquei_app/features/organizations/settings/providers/expanded_roles_provider.dart';
import 'package:convoquei_app/features/organizations/settings/providers/list_members_in_role_provider.dart';
import 'package:convoquei_app/features/organizations/settings/providers/list_roles_organization_provider.dart';
import 'package:convoquei_app/features/organizations/settings/providers/remove_role_member_provider.dart';
import 'package:convoquei_app/features/organizations/settings/providers/update_role_permissions_provider.dart';
import 'package:convoquei_app/features/organizations/settings/widgets/create_role_modal.dart';
import 'package:convoquei_app/features/organizations/settings/widgets/member_role_card.dart';
import 'package:convoquei_app/features/organizations/settings/widgets/no_roles_empty_state.dart';
import 'package:convoquei_app/features/organizations/shared/models/OrganizationRolePermissionModel.dart';
import 'package:convoquei_app/features/organizations/shared/models/organization_model.dart';
import 'package:convoquei_app/features/organizations/shared/models/organization_my_member_profile_model.dart';
import 'package:convoquei_app/features/organizations/shared/models/organization_role_member_model.dart';
import 'package:convoquei_app/features/organizations/shared/models/organization_role_model.dart';
import 'package:convoquei_app/features/organizations/shared/providers/organization_providers.dart';
import 'package:convoquei_app/features/organizations/shared/widgets/expanded_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ManageRolesPage extends ConsumerStatefulWidget {
  final OrganizationModel organization;

  const ManageRolesPage({super.key, required this.organization});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ManageRolesPageState();
}

class _ManageRolesPageState extends ConsumerState<ManageRolesPage> {
  Future<void> _handleRequestNextPage() async {
    await ref
        .read(listRolesOrganizationProvider.notifier)
        .loadNextPage(widget.organization.id);
  }

  Future<void> _handleCreateRole() async {
    if (!mounted) return;

    final role = await CreateRoleModal.show(
      context,
          (name) => ref
          .read(createRoleProvider.notifier)
          .execute(organizationId: widget.organization.id, name: name),
    );

    if (role == null || !mounted) return;

    await _handleOpenModalEditRole(role);
  }

  Future<void> _handleDeleteRole(OrganizationRoleModel role) async {
    final confirmed = await UserFeedbackService.confirm(
      context,
      title: 'Excluir papel',
      message:
      'Tem certeza que deseja excluir o papel "${role.name}"? Esta ação não pode ser desfeita.',
      confirmLabel: 'Excluir',
      destructive: true,
    );

    if (!confirmed || !mounted) return;

    try {
      await ref
          .read(deleteRoleProvider.notifier)
          .execute(organizationId: widget.organization.id, roleId: role.id);
    } catch (_) {
      if (!mounted) return;
      await UserFeedbackService.error(
        context,
        message: 'Não foi possível excluir o papel. Tente novamente.',
      );
    }
  }

  Future<void> _handleRemoveRoleMember(
      OrganizationRoleModel role,
      OrganizationRoleMemberModel member,
      ) async {
    final confirmed = await UserFeedbackService.confirm(
      context,
      title: 'Remover membro',
      message:
      'Tem certeza que deseja remover "${member.name}" do papel "${role.name}"?',
      confirmLabel: 'Remover',
      destructive: true,
    );

    if (!confirmed || !mounted) return;

    try {
      await ref
          .read(removeRoleMemberProvider.notifier)
          .execute(
        organizationId: widget.organization.id,
        roleId: role.id,
        memberId: member.id,
      );
    } catch (_) {
      if (!mounted) return;
      await UserFeedbackService.error(
        context,
        message: 'Não foi possível remover o membro. Tente novamente.',
      );
    }
  }

  Future<void> _handleOpenModalEditRole(OrganizationRoleModel role) {
    return MultiSelectModal.show<OrganizationRolePermissionModel>(
      context,
      titleWidget: HeaderModalTitleSubtitle(
        title: role.name,
        subtitle: 'Gerencie as permissões vinculadas a este papel',
      ),
      title: 'Gerenciar Papel',
      fetcher: (ref) =>
          ref.read(avaliablePermissionsProvider(widget.organization.id).future),
      idExtractor: (role) => role.code,
      itemBuilder: (permission, isSelected, onTap) => SelectableTile(
        title: permission.title,
        description: permission.description,
        isSelected: isSelected,
        onTap: onTap,
      ),
      initialSelectedIds: role.permissions.map((p) => p.code).toSet(),
      onSave: (selectedIds) async {
        final container = ProviderScope.containerOf(context);

        await container
            .read(updateRolePermissionsProvider.notifier)
            .execute(
          organizationId: widget.organization.id,
          roleId: role.id,
          permissions: selectedIds.toList(),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(listRolesOrganizationProvider.notifier)
          .loadFirstPage(widget.organization.id);
    });
  }

  Widget _membersWidget(OrganizationRoleModel role) {
    final expandedRoles = ref.watch(expandedRolesProvider);
    final isExpanded = expandedRoles.contains(role.id);

    if (!isExpanded) return const SizedBox.shrink();

    final membersAsync = ref.watch(
      roleMembersProvider((
      organizationId: widget.organization.id,
      roleId: role.id,
      )),
    );

    return membersAsync.when(
      data: (members) {
        if (members.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Icon(
                  Icons.person_off_outlined,
                  size: 14,
                  color: AppTheme.textSecondary.withOpacity(0.5),
                ),
                const SizedBox(width: 6),
                Text(
                  'Nenhum membro vinculado',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    color: AppTheme.textSecondary.withOpacity(0.6),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: members.length,
          separatorBuilder: (_, __) => const SizedBox(height: 4),
          itemBuilder: (context, index) {
            final member = members[index];
            return MemberRoleCard(
              userName: member.name,
              avatarUrl: member.avatarUrl,
              actionIcon: Icons.person_remove_outlined,
              onActionTap: () => _handleRemoveRoleMember(role, member),
            );
          },
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Center(
          child: SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
      error: (err, _) => const Text('Erro ao carregar membros'),
    );
  }

  /// Constrói o avatar inicial do papel com cor baseada no nome
  Widget _buildRoleAvatar(String name) {
    // Gera uma cor consistente baseada no nome
    final colors = [
      const Color(0xFF1D4ED8), // primaryColor
      const Color(0xFF0F766E),
      const Color(0xFF7C3AED),
      const Color(0xFFB45309),
      const Color(0xFF0369A1),
      const Color(0xFF4338CA),
    ];
    final colorIndex = name.codeUnitAt(0) % colors.length;
    final color = colors[colorIndex];

    return CircleAvatar(
      radius: 22,
      backgroundColor: color.withOpacity(0.12),
      child: Text(
        name.substring(0, 1).toUpperCase(),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 16,
          fontFamily: 'Poppins',
        ),
      ),
    );
  }

  Widget _buildRoleCard(OrganizationRoleModel role) {
    return ExpandedCard(
      key: ValueKey(role.id),
      initiallyExpanded: false,
      leading: _buildRoleAvatar(role.name),
      onExpand: () {
        final roles = {...ref.read(expandedRolesProvider)};
        roles.add(role.id);
        ref.read(expandedRolesProvider.notifier).state = roles;
      },
      descriptionWidget: Wrap(
        spacing: 6,
        children: [
          TagLabel(
            label:
            "${role.permissionCount} ${role.permissionCount == 1 ? 'PERMISSÃO' : 'PERMISSÕES'}",
            color: AppTheme.textSecondary,
            variant: TagLabelVariant.elevated,
          ),
        ],
      ),
      title: role.name,

      // ─── Ação de excluir: agora como ícone no trailing do header ───
      // Passada via actions para ser renderizada pelo ExpandedCard
      actions: [
        _DeleteRoleButton(onTap: () => _handleDeleteRole(role)),
      ],

      children: [
        // ── Seção: Permissões ──────────────────────────────────────
        _SectionDivider(
          label: 'PERMISSÕES VINCULADAS (${role.permissionCount})',
          trailing: _EditPermissionsButton(
            onTap: () => _handleOpenModalEditRole(role),
          ),
        ),
        const SizedBox(height: 10),
        role.permissions.isEmpty
            ? _EmptyChip(label: 'Nenhuma permissão vinculada')
            : Wrap(
          spacing: 6,
          runSpacing: 6,
          children: role.permissions.map((perm) {
            return TagLabel(
              label: perm.title.toUpperCase(),
              color: AppTheme.primaryColor,
              variant: TagLabelVariant.elevated,
            );
          }).toList(),
        ),

        const SizedBox(height: 16),

        // ── Seção: Membros ─────────────────────────────────────────
        const _SectionDivider(label: 'MEMBROS VINCULADOS'),
        const SizedBox(height: 10),
        _membersWidget(role),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final rolesAsync = ref.watch(listRolesOrganizationProvider);
    final hasNextPage = rolesAsync.value?.hasNextPage ?? false;

    final emptyState = rolesAsync.whenOrNull(
      data: (paged) => paged.items.isEmpty
          ? NoRolesEmptyState(onCreateRole: _handleCreateRole)
          : null,
    );

    return BaseScrollablePage(
      useSafeArea: true,
      searchHint: 'Procurar papéis...',
      onRequestNextPage: hasNextPage ? _handleRequestNextPage : null,
      icon: Icons.add_moderator_outlined,
      emptyState: emptyState,
      onIconTap: _handleCreateRole,
      children: [
        rolesAsync.when(
          data: (paged) => Column(
            spacing: 8,
            children: paged.items.map(_buildRoleCard).toList(),
          ),
          error: (err, _) => Center(
            child: Text('Erro ao carregar papéis: $err'),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Widgets auxiliares extraídos para manter o build limpo
// ─────────────────────────────────────────────────────────────────────────────

/// Botão de excluir papel — ícone com visual destrutivo contido,
/// evitando que fique "perdido" em meio ao card.
class _DeleteRoleButton extends StatelessWidget {
  final VoidCallback onTap;

  const _DeleteRoleButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    const dangerColor = Color(0xFFDC2626);

    return Tooltip(
      message: 'Excluir papel',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: dangerColor.withOpacity(0.07),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: dangerColor.withOpacity(0.18),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.delete_outline_rounded, size: 15, color: dangerColor),
              SizedBox(width: 5),
              Text(
                'Excluir',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: dangerColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Botão leve de editar permissões.
class _EditPermissionsButton extends StatelessWidget {
  final VoidCallback onTap;

  const _EditPermissionsButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.edit_outlined,
              size: 13,
              color: AppTheme.primaryColor,
            ),
            const SizedBox(width: 4),
            Text(
              'Editar',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Divisor de seção com label uppercase e trailing opcional.
class _SectionDivider extends StatelessWidget {
  final String label;
  final Widget? trailing;

  const _SectionDivider({required this.label, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: Color(0xFF94A3B8),
            letterSpacing: 0.9,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFE2E8F0),
                  const Color(0xFFE2E8F0).withOpacity(0),
                ],
              ),
            ),
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 4),
          trailing!,
        ],
      ],
    );
  }
}

/// Chip/placeholder quando não há itens na lista.
class _EmptyChip extends StatelessWidget {
  final String label;

  const _EmptyChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 12,
          color: Color(0xFF94A3B8),
          fontStyle: FontStyle.italic,
        ),

      ),
    );
  }
}