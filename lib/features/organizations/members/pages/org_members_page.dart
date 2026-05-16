import 'dart:async';

import 'package:convoquei_app/app/router.dart';
import 'package:convoquei_app/core/network/exceptions/api_exception.dart';
import 'package:convoquei_app/core/services/toast_feedback_service.dart';
import 'package:convoquei_app/core/services/user_feedback_service.dart';
import 'package:convoquei_app/core/theme/app_theme.dart';
import 'package:convoquei_app/core/widgets/app_loading_info.dart';
import 'package:convoquei_app/core/widgets/app_loading_screen.dart';
import 'package:convoquei_app/core/widgets/error_retry_state.dart';
import 'package:convoquei_app/features/organizations/members/models/enums/manage_member_action.dart';
import 'package:convoquei_app/features/organizations/members/providers/kick_member_provider.dart';
import 'package:convoquei_app/features/organizations/members/providers/list_all_members_query_provider.dart';
import 'package:convoquei_app/features/organizations/members/widgets/member_list_tile.dart';
import 'package:convoquei_app/features/organizations/members/widgets/member_list_tile_skeleton.dart';
import 'package:convoquei_app/features/organizations/members/widgets/modals/invite_member_by_email_modal.dart';
import 'package:convoquei_app/features/organizations/functions/widgets/modals/manage_functions_member_modal.dart';
import 'package:convoquei_app/features/organizations/groups/widgets/modals/manage_groups_member_modal.dart';
import 'package:convoquei_app/features/organizations/members/widgets/modals/manage_member_modal.dart';
import 'package:convoquei_app/features/organizations/members/widgets/modals/manage_roles_member_modal.dart';
import 'package:convoquei_app/features/organizations/shared/models/enums/organization_permission.dart';
import 'package:convoquei_app/features/organizations/shared/models/organization_member_model.dart';
import 'package:convoquei_app/features/organizations/shared/providers/organization_providers.dart';
import 'package:convoquei_app/features/organizations/shared/providers/selected_organization_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class OrgMembersPage extends ConsumerStatefulWidget {
  const OrgMembersPage({super.key});

  @override
  ConsumerState<OrgMembersPage> createState() => _OrgMembersPageState();
}

class _OrgMembersPageState extends ConsumerState<OrgMembersPage> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  Timer? _debounce;
  bool _hasLoadedOnce = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(membersPagedProvider.notifier).reset();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onScroll() {
    final pos = _scrollController.position;
    if (pos.pixels < pos.maxScrollExtent - 200) return;

    final s = ref.read(membersPagedProvider);
    if (s.isLoadingMore || s.isInitialLoading || !s.hasNextPage) return;

    ref.read(membersPagedProvider.notifier).loadNextPage();
  }

  void _handleSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      final name = value.trim().isEmpty ? null : value.trim();
      ref.read(membersPagedProvider.notifier).reset(name: name);
    });
  }

  String? get _currentName {
    final text = _searchController.text.trim();
    return text.isEmpty ? null : text;
  }

  void _handleActionManageMember(
    ManageMemberActionEnum action,
    OrganizationMemberModel member,
  ) {
    final orgId = ref.read(selectedOrganizationProvider)?.id;
    if (orgId == null) return;

    switch (action) {
      case ManageMemberActionEnum.kickMember:
        _kickMember(member, orgId);
      case ManageMemberActionEnum.manageGroups:
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          ManageGroupsMemberModal.show(
            context,
            member,
            orgId,
            onNavigateToSettings: () {
              if (!mounted) return;
              context.pushNamed(
                AppRoutes.orgSettings,
                pathParameters: {'orgId': orgId},
              );
            },
          );
        });
      case ManageMemberActionEnum.manageFunctions:
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          ManageFunctionsMemberModal.show(
            context,
            member,
            orgId,
            onNavigateToSettings: () {
              if (!mounted) return;
              context.goNamed(
                AppRoutes.orgSettingsFunctions,
                pathParameters: {'orgId': orgId},
              );
            },
          );
        });
      case ManageMemberActionEnum.manageRoles:
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          ManageRolesMemberModal.show(
            context,
            member,
            orgId,
            onNavigateToSettings: () {
              if (!mounted) return;
              context.goNamed(
                AppRoutes.orgSettingsRoles,
                pathParameters: {'orgId': orgId},
              );
            },
          );
        });
    }
  }

  Future<void> _kickMember(OrganizationMemberModel member, String orgId) async {
    try {
      await ref
          .read(kickOrganizationMemberProvider.notifier)
          .kick(organizationId: orgId, memberId: member.id);

      if (!mounted) return;
      ToastFeedbackService.showToast(
        context,
        '${member.name} foi expulsado com sucesso!',
        ToastType.success,
      );
    } catch (e) {
      if (!mounted) return;
      if (e is ApiException) {
        UserFeedbackService.error(context, message: e.message);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final orgId = ref.watch(selectedOrganizationProvider)?.id;
    final currentUser = orgId != null
        ? ref.watch(currentUserMembershipOrganizationProvider(orgId)).asData?.value
        : null;

    final canInvite =
        currentUser?.hasPermission(OrganizationPermissionEnum.inviteMembers) ?? false;

    final state = ref.watch(membersPagedProvider);

    if (!state.isInitialLoading) _hasLoadedOnce = true;

    if (state.isInitialLoading && !_hasLoadedOnce) {
      return const AppLoadingScreen(
        skeleton: AppLoadingSkeleton.list,
        content: AppLoadingInfo(
          label: 'Carregando membros...',
          description: 'Buscando membros da organização',
        ),
      );
    }

    if (state.error != null && state.items.isEmpty && !state.isInitialLoading) {
      return Scaffold(
        body: Center(
          child: ErrorRetryState(
            onRetry: () =>
                ref.read(membersPagedProvider.notifier).reset(name: _currentName),
            message: state.error.toString(),
          ),
        ),
      );
    }

    final isPartialLoading = state.isInitialLoading && _hasLoadedOnce;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(membersPagedProvider.notifier).resetAsync(name: _currentName),
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: _handleSearchChanged,
                        enabled: !isPartialLoading,
                        decoration: const InputDecoration(
                          hintText: 'Buscar membro...',
                          prefixIcon: Icon(Icons.search_rounded, size: 20),
                        ),
                      ),
                    ),
                    if (canInvite) ...[
                      const SizedBox(width: 12),
                      Opacity(
                        opacity: isPartialLoading ? 0.4 : 1.0,
                        child: AbsorbPointer(
                          absorbing: isPartialLoading,
                          child: Material(
                            color: AppTheme.primaryColor,
                            borderRadius: BorderRadius.circular(6),
                            child: InkWell(
                              onTap: () => InviteMemberByEmailModal.show(
                                context,
                                orgId!,
                              ),
                              borderRadius: BorderRadius.circular(6),
                              child: const SizedBox(
                                height: 40,
                                width: 40,
                                child: Icon(Icons.person_add, color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            if (isPartialLoading)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, _) => const Padding(
                      padding: EdgeInsets.only(bottom: 4),
                      child: MemberListTileSkeleton(),
                    ),
                    childCount: 5,
                  ),
                ),
              )
            else if (state.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Align(
                  alignment: const Alignment(0, -0.2),
                  child: _EmptyState(
                    hasSearch: _searchController.text.isNotEmpty,
                    canInvite: canInvite,
                    onInvite: () => InviteMemberByEmailModal.show(
                      context,
                      orgId!,
                    ),
                  ),
                ),
              )
            else ...[
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final m = state.items[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: MemberListTile(
                          key: ValueKey(m.id),
                          member: m,
                          isCurrentUser: m.id == currentUser?.id,
                          onOptionsPressed: currentUser != null
                              ? () => ManageMemberModal.show(
                                    context,
                                    m,
                                    currentUser,
                                    (action) {
                                      _handleActionManageMember(action, m);
                                      return true;
                                    },
                                  )
                              : null,
                        ),
                      );
                    },
                    childCount: state.items.length,
                  ),
                ),
              ),

              if (state.isLoadingMore)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),

              if (state.error != null && state.items.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 20,
                    ),
                    child: Center(
                      child: TextButton.icon(
                        onPressed: () =>
                            ref.read(membersPagedProvider.notifier).loadNextPage(),
                        icon: const Icon(Icons.refresh_rounded, size: 16),
                        label: const Text('Tentar novamente'),
                      ),
                    ),
                  ),
                ),

              if (!state.hasNextPage && !state.isLoadingMore)
                const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.hasSearch,
    required this.canInvite,
    required this.onInvite,
  });

  final bool hasSearch;
  final bool canInvite;
  final VoidCallback onInvite;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppTheme.surfaceSubtle,
              borderRadius: BorderRadius.circular(20),
            ),
            alignment: Alignment.center,
            child: Text(
              hasSearch ? '🔍' : '👥',
              style: const TextStyle(fontSize: 36),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            hasSearch ? 'Nenhum resultado encontrado' : 'Nenhum membro ainda',
            style: theme.textTheme.titleSmall?.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            hasSearch
                ? 'Tente buscar por outro nome.'
                : 'Convide membros para começar a organizar sua equipe.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          ),
          if (!hasSearch && canInvite) ...[
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onInvite,
                icon: const Icon(Icons.person_add_rounded, size: 18),
                label: const Text('Convidar membro'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
