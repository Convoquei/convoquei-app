import 'package:convoquei_app/core/services/user_feedback_service.dart';
import 'package:convoquei_app/design_system/ds.dart';
import 'package:convoquei_app/features/organizations/roles/providers/avaliable_permissions_provider.dart';
import 'package:convoquei_app/features/organizations/roles/providers/create_role_provider.dart';
import 'package:convoquei_app/features/organizations/roles/providers/delete_role_provider.dart';
import 'package:convoquei_app/features/organizations/roles/providers/expanded_roles_provider.dart';
import 'package:convoquei_app/features/organizations/roles/providers/list_members_in_role_provider.dart';
import 'package:convoquei_app/features/organizations/roles/providers/list_roles_organization_provider.dart';
import 'package:convoquei_app/features/organizations/roles/providers/remove_role_member_provider.dart';
import 'package:convoquei_app/features/organizations/roles/providers/update_role_permissions_provider.dart';
import 'package:convoquei_app/features/organizations/roles/widgets/create_role_modal.dart';
import 'package:convoquei_app/features/organizations/roles/widgets/member_role_card.dart';
import 'package:convoquei_app/features/organizations/roles/widgets/no_roles_empty_state.dart';
import 'package:convoquei_app/features/organizations/roles/widgets/role_card_skeleton.dart';
import 'package:convoquei_app/features/organizations/shared/models/organization_model.dart';
import 'package:convoquei_app/features/organizations/shared/models/organization_role_member_model.dart';
import 'package:convoquei_app/features/organizations/shared/models/organization_role_model.dart';
import 'package:convoquei_app/features/organizations/shared/models/organization_role_permission_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ManageRolesPage extends ConsumerStatefulWidget {
  final OrganizationModel organization;

  const ManageRolesPage({super.key, required this.organization});

  @override
  ConsumerState<ManageRolesPage> createState() => _ManageRolesPageState();
}

class _ManageRolesPageState extends ConsumerState<ManageRolesPage> {
  final _scrollController = ScrollController();
  bool _hasLoadedOnce = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(rolesProvider.notifier).reset();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final pos = _scrollController.position;
    if (pos.pixels < pos.maxScrollExtent - 200) return;
    final s = ref.read(rolesProvider);
    if (s.isLoadingMore || s.isInitialLoading || !s.hasNextPage) return;
    ref.read(rolesProvider.notifier).loadNextPage();
  }

  Future<void> _handleCreate() async {
    if (!mounted) return;

    final role = await CreateRoleModal.show(
      context,
      (name) => ref
          .read(createRoleProvider.notifier)
          .execute(organizationId: widget.organization.id, name: name),
    );

    if (role == null || !mounted) return;
    await _handleEditPermissions(role);
  }

  Future<void> _handleDelete(OrganizationRoleModel role) async {
    final confirmed = await UserFeedbackService.confirm(
      context,
      title: 'Excluir papel',
      message: 'Tem certeza que deseja excluir o papel "${role.name}"? Esta ação não pode ser desfeita.',
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

  Future<void> _handleRemoveMember(
    OrganizationRoleModel role,
    OrganizationRoleMemberModel member,
  ) async {
    final confirmed = await UserFeedbackService.confirm(
      context,
      title: 'Remover membro',
      message: 'Tem certeza que deseja remover "${member.name}" do papel "${role.name}"?',
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

  Future<void> _handleEditPermissions(OrganizationRoleModel role) {
    return DSMultiSelectModal.show<OrganizationRolePermissionModel>(
      context,
      title: 'Gerenciar Papel',
      titleWidget: DSModalHeader(title: role.name, subtitle: 'Gerencie as permissões vinculadas a este papel'),
      fetcher: (ref) => ref.read(avaliablePermissionsProvider(widget.organization.id).future),
      idExtractor: (p) => p.code,
      itemBuilder: (permission, isSelected, onTap) => DSSelectableTile(
        title: permission.title,
        description: permission.description,
        isSelected: isSelected,
        onTap: onTap,
      ),
      initialSelectedIds: role.permissions.map((p) => p.code).toSet(),
      onSave: (selectedIds) async {
        final container = ProviderScope.containerOf(context);
        await container.read(updateRolePermissionsProvider.notifier).execute(
          organizationId: widget.organization.id,
          roleId: role.id,
          permissions: selectedIds.toList(),
        );
      },
      saveLabel: 'Guardar alterações',
    );
  }

  Widget _buildMembers(OrganizationRoleModel role) {
    final isExpanded = ref.watch(expandedRolesProvider).contains(role.id);
    if (!isExpanded) return const SizedBox.shrink();

    final membersAsync = ref.watch(
      roleMembersProvider((organizationId: widget.organization.id, roleId: role.id)),
    );

    return membersAsync.when(
      data: (members) {
        if (members.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: DSSpacing.sm),
            child: Row(
              children: [
                DSIcon(Icons.person_off_outlined, size: DSIconSize.sm, color: context.colors.textSecondary),
                const SizedBox(width: DSSpacing.sm),
                DSText(
                  'Nenhum membro vinculado',
                  variant: DSTextVariant.bodySmall,
                  color: context.colors.textSecondary,
                ),
              ],
            ),
          );
        }
        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: members.length,
          separatorBuilder: (_, _) => const SizedBox(height: DSSpacing.xs),
          itemBuilder: (_, index) {
            final member = members[index];
            return MemberRoleCard(
              userName: member.name,
              avatarUrl: member.avatarUrl,
              actionIcon: Icons.person_remove_outlined,
              onActionTap: () => _handleRemoveMember(role, member),
            );
          },
        );
      },
      loading: () => Padding(
        padding: const EdgeInsets.symmetric(vertical: DSSpacing.md),
        child: Center(child: DSSpinner(size: 18)),
      ),
      error: (_, _) => DSText(
        'Erro ao carregar membros.',
        variant: DSTextVariant.bodySmall,
        color: context.colors.danger,
      ),
    );
  }

  Widget _buildRoleCard(OrganizationRoleModel role) {
    final permCount = role.permissionCount;
    return DSExpandableCard(
      key: ValueKey(role.id),
      initiallyExpanded: false,
      leading: DSAvatar(name: role.name, avatarUrl: '', radius: 22),
      onExpand: () {
        final expanded = {...ref.read(expandedRolesProvider)};
        expanded.add(role.id);
        ref.read(expandedRolesProvider.notifier).state = expanded;
      },
      descriptionWidget: DSBadge(
        label: '$permCount ${permCount == 1 ? 'PERMISSÃO' : 'PERMISSÕES'}',
        color: context.colors.textSecondary,
        variant: DSBadgeVariant.elevated,
      ),
      title: role.name,
      actions: [
        DSButton(
          label: 'Excluir',
          schema: DSButtonSchema.danger,
          size: DSButtonSize.xs,
          outlined: true,
          icon: Icons.delete_outline_rounded,
          fullWidth: false,
          onPressed: () => _handleDelete(role),
        ),
      ],
      children: [
        _SectionLabel(
          label: 'PERMISSÕES VINCULADAS ($permCount)',
          trailing: DSButton(
            label: 'Editar',
            schema: DSButtonSchema.ghost,
            size: DSButtonSize.xs,
            icon: Icons.edit_outlined,
            fullWidth: false,
            onPressed: () => _handleEditPermissions(role),
          ),
        ),
        const SizedBox(height: DSSpacing.sm),
        role.permissions.isEmpty
            ? DSBadge(
                label: 'Nenhuma permissão vinculada',
                color: context.colors.textSecondary,
                variant: DSBadgeVariant.soft,
              )
            : Wrap(
                spacing: DSSpacing.xs,
                runSpacing: DSSpacing.xs,
                children: role.permissions
                    .map((p) => DSBadge(
                          label: p.title.toUpperCase(),
                          color: context.colors.primary,
                          variant: DSBadgeVariant.elevated,
                        ))
                    .toList(),
              ),
        const SizedBox(height: DSSpacing.lg),
        const _SectionLabel(label: 'MEMBROS VINCULADOS'),
        const SizedBox(height: DSSpacing.sm),
        _buildMembers(role),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(rolesProvider);
    if (!state.isInitialLoading) _hasLoadedOnce = true;

    final isPartialLoading = state.isInitialLoading && _hasLoadedOnce;

    return Scaffold(
      appBar: AppBar(title: const Text('Gerenciar Papéis')),
      body: Builder(
        builder: (context) {
          if (state.isInitialLoading && !_hasLoadedOnce) {
            return const DSLoadingScreen(
              label: 'Carregando papéis...',
              description: 'Buscando papéis da organização',
              skeleton: DSLoadingSkeleton.list,
            );
          }

          if (state.hasError && state.items.isEmpty && !state.isInitialLoading) {
            return DSErrorRetryState(
              message: 'Não foi possível carregar os papéis.',
              description: 'Verifique sua conexão e tente novamente.',
              onRetry: () => ref.read(rolesProvider.notifier).reset(),
            );
          }

          return RefreshIndicator(
        onRefresh: () => ref.read(rolesProvider.notifier).resetAsync(),
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: DSListHeader(
                onActionTap: _handleCreate,
                actionTooltip: 'Criar papel',
                enabled: !isPartialLoading,
              ),
            ),
            if (isPartialLoading)
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: DSSpacing.xl),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, _) => const Padding(
                      padding: EdgeInsets.only(bottom: DSSpacing.sm),
                      child: RoleCardSkeleton(),
                    ),
                    childCount: 3,
                  ),
                ),
              )
            else if (state.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Align(
                  alignment: const Alignment(0, -0.2),
                  child: NoRolesEmptyState(onCreateRole: _handleCreate),
                ),
              )
            else ...[
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: DSSpacing.xl),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, index) => Padding(
                      padding: const EdgeInsets.only(bottom: DSSpacing.sm),
                      child: _buildRoleCard(state.items[index]),
                    ),
                    childCount: state.items.length,
                  ),
                ),
              ),
              if (state.isLoadingMore)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: DSSpacing.xl),
                    child: Center(child: DSSpinner(size: 32)),
                  ),
                ),
              if (state.hasError && state.items.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: DSSpacing.lg, horizontal: DSSpacing.xl),
                    child: DSButton(
                      label: 'Tentar novamente',
                      schema: DSButtonSchema.ghost,
                      size: DSButtonSize.sm,
                      fullWidth: false,
                      onPressed: () => ref.read(rolesProvider.notifier).loadNextPage(),
                    ),
                  ),
                ),
              if (!state.hasNextPage && !state.isLoadingMore)
                const SliverToBoxAdapter(child: SizedBox(height: DSSpacing.xxl)),
            ],
          ],
        ),
      );
        },
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  final Widget? trailing;

  const _SectionLabel({required this.label, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        DSText(label, variant: DSTextVariant.labelSmall, color: context.colors.textSecondary),
        const SizedBox(width: DSSpacing.sm),
        const Expanded(child: DSDivider()),
        if (trailing != null) ...[
          const SizedBox(width: DSSpacing.xs),
          trailing!,
        ],
      ],
    );
  }
}
