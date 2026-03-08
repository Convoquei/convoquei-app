import 'package:convoquei_app/core/network/exceptions/api_exception.dart';
import 'package:convoquei_app/core/services/toast_feedback_service.dart';
import 'package:convoquei_app/core/services/user_feedback_service.dart';
import 'package:convoquei_app/core/theme/app_theme.dart';
import 'package:convoquei_app/core/widgets/app_search_input.dart';
import 'package:convoquei_app/features/organizations/members/models/enums/manage_member_action.dart';
import 'package:convoquei_app/features/organizations/members/providers/invite_member_provider.dart';
import 'package:convoquei_app/features/organizations/members/providers/kick_member_provider.dart';
import 'package:convoquei_app/features/organizations/members/widgets/modals/create_group_modal.dart';
import 'package:convoquei_app/features/organizations/members/widgets/group_list.dart';
import 'package:convoquei_app/features/organizations/members/widgets/modals/invite_member_by_email_modal.dart';
import 'package:convoquei_app/features/organizations/members/widgets/modals/manage_functions_member_modal.dart';
import 'package:convoquei_app/features/organizations/members/widgets/modals/manage_groups_member_modal.dart';
import 'package:convoquei_app/features/organizations/members/widgets/modals/manage_member_modal.dart';
import 'package:convoquei_app/features/organizations/members/widgets/modals/manage_roles_member_modal.dart';
import 'package:convoquei_app/features/organizations/members/widgets/member_list.dart';
import 'package:convoquei_app/features/organizations/settings/pages/manage_functions_page.dart';
import 'package:convoquei_app/features/organizations/settings/pages/manage_roles_page.dart';
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
  final OrgMembersTab initialTab;
  final void Function({required String title, required Widget page})? onOpenSettingsPage;

  const OrgMembersPage({
    super.key,
    this.initialTab = OrgMembersTab.membros,
    this.onOpenSettingsPage,
  });

  @override
  ConsumerState<OrgMembersPage> createState() => _OrgMembersPageState();
}

class _OrgMembersPageState extends ConsumerState<OrgMembersPage> {
  late OrgMembersTab _tab = widget.initialTab;
  final _searchController = TextEditingController();
  String? _searchQuery;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    if (value.length < 3 && value.isNotEmpty) return;

    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      setState(() => _searchQuery = value.isEmpty ? null : value);
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
            ManageGroupsMemberModal.show(
              context,
              member,
              organizationId,
              onNavigateToSettings: () {
                setState(() => _tab = OrgMembersTab.grupos);
              },
            );
          });
          break;
        }
      case ManageMemberActionEnum.manageFunctions:
        {
          final organizationId = ref.read(selectedOrganizationProvider)?.id;
          if (organizationId == null) break;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            ManageFunctionsMemberModal.show(
              context,
              member,
              organizationId,
              onNavigateToSettings: () {
                final org = ref.read(selectedOrganizationProvider);
                if (org == null || !mounted) return;
                widget.onOpenSettingsPage?.call(
                  title: 'Gerenciar Funções',
                  page: ManageFunctionsPage(organization: org),
                );
              },
            );
          });
          break;
        }
      case ManageMemberActionEnum.manageRoles:
        {
          final organizationId = ref.read(selectedOrganizationProvider)?.id;
          if (organizationId == null) break;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            ManageRolesMemberModal.show(
              context,
              member,
              organizationId,
              onNavigateToSettings: () {
                final org = ref.read(selectedOrganizationProvider);
                if (org == null || !mounted) return;
                widget.onOpenSettingsPage?.call(
                  title: 'Gerenciar Papéis',
                  page: ManageRolesPage(organization: org),
                );
              },
            );
          });
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
        ? ref.watch(currentUserMembershipOrganizationProvider(orgId)).asData?.value
        : null;

    final canInviteMembers =
        currentUser?.hasPermission(OrganizationPermissionEnum.inviteMembers) ??
        false;
    final canManageGroups =
        currentUser?.hasPermission(OrganizationPermissionEnum.manageGroups) ??
        false;

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
                    setState(() {
                      _tab = tab;
                      _searchQuery = null;
                    });
                    _searchController.clear();
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
                    currentUserId: currentUser?.id ?? '',
                    searchQuery: _searchQuery,
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
                    organizationId: orgId ?? '',
                    canManageGroups: canManageGroups,
                  ),
          ),
        ],
      ),
    );
  }
}
