import 'package:convoquei_app/core/theme/app_theme.dart';
import 'package:convoquei_app/core/widgets/app_search_input.dart';
import 'package:convoquei_app/features/organizations/members/providers/list_all_members_query_provider.dart';
import 'package:convoquei_app/features/organizations/members/widgets/member_list_tile.dart';
import 'package:convoquei_app/features/organizations/shared/models/enums/organization_permission.dart';
import 'package:convoquei_app/features/organizations/shared/models/organization_member_model.dart';
import 'package:convoquei_app/features/organizations/shared/providers/organization_providers.dart';
import 'package:convoquei_app/features/organizations/home/widgets/team_toggle_widget.dart';
import 'package:convoquei_app/features/organizations/shared/providers/selected_organization_provider.dart';
import 'package:convoquei_app/core/models/state_list_paged.dart';
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
  final _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
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
          name: _searchController.text.isEmpty
              ? null
              : _searchController.text,
        );
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

  @override
  Widget build(BuildContext context) {
    final orgId = ref.watch(selectedOrganizationProvider)?.id;
    final member = orgId != null
        ? ref.watch(currentOrgMemberProvider(orgId)).asData?.value
        : null;

    final canInviteMembers =
        member?.hasPermission(OrganizationPermissionEnum.inviteMembers) ??
        false;
    final canManageGroups =
        member?.hasPermission(OrganizationPermissionEnum.manageGroups) ?? false;

    final membersState = ref.watch(membersPagedProvider);

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
                          onTap: () {},
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
                ? _MembersList(
                    state: membersState,
                    currentUserId: 'TODO COLOCAR O ID',
                    scrollController: _scrollController,
                    onOptionsPressed: (m) {
                      // TODO: abrir bottom sheet de ações
                    },
                  )
                : const Center(child: Text('Grupos')),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _MembersList extends StatelessWidget {
  const _MembersList({
    required this.state,
    required this.currentUserId,
    required this.scrollController,
    this.onOptionsPressed,
  });

  final StateListPaged<OrganizationMemberModel> state;
  final String currentUserId;
  final ScrollController scrollController;
  final void Function(OrganizationMemberModel member)? onOptionsPressed;

  @override
  Widget build(BuildContext context) {
    if (state.isInitialLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && state.items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Erro ao carregar membros'),
            TextButton(onPressed: () {}, child: const Text('Tentar novamente')),
          ],
        ),
      );
    }

    if (state.items.isEmpty) {
      return const Center(child: Text('Nenhum membro encontrado'));
    }

    return ListView.separated(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      itemCount: state.items.length + (state.hasNextPage ? 1 : 0),
      separatorBuilder: (_, __) => const SizedBox(height: 4),
      itemBuilder: (context, index) {
        if (index == state.items.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final m = state.items[index];
        return MemberListTile(
          member: m,
          isCurrentUser: m.id == currentUserId,
          onOptionsPressed: onOptionsPressed != null
              ? () => onOptionsPressed!(m)
              : null,
        );
      },
    );
  }
}
