import 'package:convoquei_app/core/network/exceptions/api_exception.dart';
import 'package:convoquei_app/core/services/toast_feedback_service.dart';
import 'package:convoquei_app/core/services/user_feedback_service.dart';
import 'package:convoquei_app/core/theme/app_theme.dart';
import 'package:convoquei_app/core/widgets/app_search_input.dart';
import 'package:convoquei_app/features/organizations/members/models/enums/manage_member_action.dart';
import 'package:convoquei_app/features/organizations/members/providers/invite_member_provider.dart';
import 'package:convoquei_app/features/organizations/members/providers/kick_member_provider.dart';
import 'package:convoquei_app/features/organizations/members/providers/list_all_groups_query_provider.dart';
import 'package:convoquei_app/features/organizations/members/providers/list_all_members_query_provider.dart';
import 'package:convoquei_app/features/organizations/members/widgets/create_group_modal.dart';
import 'package:convoquei_app/features/organizations/members/widgets/group_list.dart';
import 'package:convoquei_app/features/organizations/members/widgets/invite_member_by_email_modal.dart';
import 'package:convoquei_app/features/organizations/members/widgets/manage_groups_member_modal.dart';
import 'package:convoquei_app/features/organizations/members/widgets/manage_member_modal.dart';
import 'package:convoquei_app/features/organizations/members/widgets/member_list.dart';
import 'package:convoquei_app/features/organizations/shared/models/enums/organization_permission.dart';
import 'package:convoquei_app/features/organizations/shared/models/organization_member_model.dart';
import 'package:convoquei_app/features/organizations/shared/providers/organization_providers.dart';
import 'package:convoquei_app/features/organizations/home/widgets/team_toggle_widget.dart';
import 'package:convoquei_app/features/organizations/shared/providers/selected_organization_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';

enum OrgMembersTab { membros, grupos }

class OrgMembersPage extends ConsumerStatefulWidget {
  const OrgMembersPage({super.key});

  @override
  ConsumerState<OrgMembersPage> createState() => _OrgMembersPageState();
}

class _OrgMembersPageState extends ConsumerState<OrgMembersPage> {
  OrgMembersTab _tab = OrgMembersTab.membros;
  final _scrollController = ScrollController();
  final _groupsScrollController = ScrollController();
  final _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _groupsScrollController.addListener(_onGroupsScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _groupsScrollController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onScroll() {
    final nearBottom =
        _scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200;

    if (!nearBottom) return;

    final s = ref.read(membersPagedProvider);
    if (s.isLoadingMore || s.isInitialLoading || !s.hasNextPage) return;

    ref
        .read(membersPagedProvider.notifier)
        .loadNextPage(
          name: _searchController.text.isEmpty ? null : _searchController.text,
        );
  }

  void _onGroupsScroll() {
    final nearBottom =
        _groupsScrollController.position.pixels >=
        _groupsScrollController.position.maxScrollExtent - 200;

    if (!nearBottom) return;

    final s = ref.read(groupsPagedProvider);
    if (s.isLoadingMore || s.isInitialLoading || !s.hasNextPage) return;

    ref.read(groupsPagedProvider.notifier).loadNextPage();
  }

  void _onSearchChanged(String value) {
    if (value.length < 3 && value.isNotEmpty) {
      return;
    }

    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      ref
          .read(membersPagedProvider.notifier)
          .reset(name: value.isEmpty ? null : value);
    });
  }

  void _handleActionManageMember(
    ManageMemberActionEnum action,
    OrganizationMemberModel member,
  ) async {
    switch (action) {
      case ManageMemberActionEnum.kickMember:
        {
          final organizationId = ref.watch(selectedOrganizationProvider)?.id;

          try {
            await ref
                .read(kickOrganizationMemberProvider.notifier)
                .kick(organizationId: organizationId!, memberId: member.id);

            ToastFeedbackService.showToast(
              context,
              "${member.name} foi expulsado com sucesso!",
              ToastType.success,
            );
          } catch (e) {
            if (!mounted) return;

            if (e is ApiException) {
              UserFeedbackService.error(context, message: e.message);
              return;
            }
          }
        }
      case ManageMemberActionEnum.manageGroups:
        {
          final organizationId = ref.read(selectedOrganizationProvider)?.id;
          if (organizationId == null) break;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            ManageGroupsMemberModal.show(context, member, organizationId);
          });
          break;
        }
      case ManageMemberActionEnum.manageRoles:
        {
          break;
        }
    }
  }

  Future<bool> _handleInviteMember(String email) async {
    try {
      final orgId = ref.read(selectedOrganizationProvider)!.id;

      await ref
          .read(inviteOrganizationMemberProvider.notifier)
          .invite(organizationId: orgId, email: email);

      ToastFeedbackService.showToast(
        context,
        "Convite enviado com sucesso!",
        ToastType.success,
      );
      return true;
    }
    catch (e) {
      if (!mounted) return false;

      if (e is ApiException) {
        UserFeedbackService.error(context, message: e.message);
        return false;
      }
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    final orgId = ref.watch(selectedOrganizationProvider)?.id;
    final currentUser = orgId != null
        ? ref.watch(currentOrgMemberProvider(orgId)).asData?.value
        : null;

    final canInviteMembers =
        currentUser?.hasPermission(OrganizationPermissionEnum.inviteMembers) ??
        false;
    final canManageGroups =
        currentUser?.hasPermission(OrganizationPermissionEnum.manageGroups) ??
        false;

    final membersState = ref.watch(membersPagedProvider);
    final groupsState = ref.watch(groupsPagedProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
            child: Column(
              children: [
                ToggleTabs<OrgMembersTab>(
                  selected: _tab,
                  values: OrgMembersTab.values,
                  onChanged: (tab) {
                    setState(() => _tab = tab);
                    _searchController.clear();
                    if (tab == OrgMembersTab.grupos) {
                      final s = ref.read(groupsPagedProvider);
                      if (s.items.isEmpty && !s.isInitialLoading) {
                        ref
                            .read(groupsPagedProvider.notifier)
                            .loadNextPage();
                      }
                    }
                  },
                  labelBuilder: (tab) => switch (tab) {
                    OrgMembersTab.membros => 'Membros',
                    OrgMembersTab.grupos => 'Grupos',
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: AppSearchInput(
                        hint: 'Procurar ${_tab.name}',
                        controller: _searchController,
                        onChanged: _onSearchChanged,
                      ),
                    ),
                    if ((_tab == OrgMembersTab.membros && canInviteMembers) ||
                        (_tab == OrgMembersTab.grupos && canManageGroups)) ...[
                      const SizedBox(width: 12),
                      Material(
                        color: AppTheme.primaryColor,
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          onTap: () {
                            if (_tab == OrgMembersTab.membros) {
                              InviteMemberByEmailModal.show(
                                context,
                                _handleInviteMember,
                              );
                            }
                            else if(_tab == OrgMembersTab.grupos) {
                              CreateGroupModal.show(context, orgId!);
                            }
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: SizedBox(
                            width: 48,
                            height: 48,
                            child: Icon(
                              _tab == OrgMembersTab.membros
                                  ? Icons.person_add
                                  : Icons.group_add,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: _tab == OrgMembersTab.membros
                ? MembersList(
                    state: membersState,
                    currentUserId: currentUser?.id ?? '',
                    scrollController: _scrollController,
                    onOptionsPressed: (m) {
                      ManageMemberModal.show(context, m, currentUser!, (
                        action,
                      ) {
                        _handleActionManageMember(action, m);
                        return true;
                      });
                    },
                  )
                : GroupsList(
                    state: groupsState,
                    organizationId: orgId ?? '',
                    canManageGroups: canManageGroups,
                    scrollController: _groupsScrollController,
                  ),
          ),
        ],
      ),
    );
  }
}
