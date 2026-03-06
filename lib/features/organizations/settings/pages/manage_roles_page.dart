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

  Widget membersWidget(OrganizationRoleModel role) {
    final expandedRoles = ref.watch(expandedRolesProvider);
    final isExpanded = expandedRoles.contains(role.id);

    if (!isExpanded) {
      return const SizedBox.shrink();
    }

    final membersAsync = ref.watch(
      roleMembersProvider((
        organizationId: widget.organization.id,
        roleId: role.id,
      )),
    );

    return membersAsync.when(
      data: (members) {
        if (members.isEmpty) {
          return const Text("Nenhum membro vinculado");
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: members.length,
          separatorBuilder: (_, __) => const SizedBox(height: 2),
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
        padding: EdgeInsets.symmetric(vertical: 8),
        child: SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      error: (err, _) => const Text("Erro ao carregar membros"),
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
      searchHint: "Procurar pepéis...",
      onRequestNextPage: hasNextPage ? _handleRequestNextPage : null,
      icon: Icons.add_moderator_outlined,
      emptyState: emptyState,
      onIconTap: _handleCreateRole,
      children: [
        rolesAsync.when(
          data: (paged) {
            return Column(
              spacing: 6,
              children: paged.items.map((role) {
                return ExpandedCard(
                  key: ValueKey(role.id),
                  initiallyExpanded: false,
                  leading: CircleAvatar(
                    radius: 24,
                    backgroundColor: const Color(0xFF1E293B),
                    child: Text(
                      role.name.substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
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
                  actions: [
                    TextButton.icon(
                      onPressed: () => _handleDeleteRole(role),
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        size: 16,
                        color: Color(0xFFDC2626),
                      ),
                      label: const Text(
                        'Excluir papel',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFFDC2626),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 12,
                      ),
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Color(0xFFF1F5F9)),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'PERMISSÕES VINCULADAS (${role.permissionCount})',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF64748B),
                                  letterSpacing: 0.8,
                                ),
                              ),
                              // Button [Editar permissões]
                              const Spacer(),
                              TextButton(
                                onPressed: () => _handleOpenModalEditRole(role),
                                child: const Text("Editar"),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Wrap(
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
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Text(
                          'MEMBROS VINCULADOS',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF64748B),
                            letterSpacing: 0.8,
                          ),
                        ),

                        const SizedBox(width: 12),
                      ],
                    ),
                    const SizedBox(height: 8),
                    membersWidget(role),
                  ],
                );
              }).toList(),
            );
          },
          error: (err, _) =>
              Center(child: Text("Erro ao carregar papéis." + err.toString())),
          loading: () => const Center(child: CircularProgressIndicator()),
        ),
      ],
    );
  }
}
