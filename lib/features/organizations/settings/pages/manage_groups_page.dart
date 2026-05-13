import 'package:convoquei_app/core/theme/app_theme.dart';
import 'package:convoquei_app/core/widgets/app_loading_info.dart';
import 'package:convoquei_app/core/widgets/app_loading_screen.dart';
import 'package:convoquei_app/core/widgets/error_retry_state.dart';
import 'package:convoquei_app/features/organizations/members/providers/list_all_groups_query_provider.dart';
import 'package:convoquei_app/features/organizations/members/widgets/modals/create_group_modal.dart';
import 'package:convoquei_app/features/organizations/settings/widgets/group_card.dart';
import 'package:convoquei_app/features/organizations/settings/widgets/group_card_skeleton.dart';
import 'package:convoquei_app/features/organizations/settings/widgets/no_groups_empty_state.dart';
import 'package:convoquei_app/features/organizations/shared/models/organization_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ManageGroupsPage extends ConsumerStatefulWidget {
  final OrganizationModel organization;

  const ManageGroupsPage({super.key, required this.organization});

  @override
  ConsumerState<ManageGroupsPage> createState() => _ManageGroupsPageState();
}

class _ManageGroupsPageState extends ConsumerState<ManageGroupsPage> {
  final _scrollController = ScrollController();
  bool _hasLoadedOnce = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(groupsPagedProvider.notifier).reset();
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

    final s = ref.read(groupsPagedProvider);
    if (s.isLoadingMore || s.isInitialLoading || !s.hasNextPage) return;

    ref.read(groupsPagedProvider.notifier).loadNextPage();
  }

  Future<void> _handleCreateGroup() async {
    if (!mounted) return;
    await CreateGroupModal.show(context, widget.organization.id);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(groupsPagedProvider);

    if (!state.isInitialLoading) _hasLoadedOnce = true;

    if (state.isInitialLoading && !_hasLoadedOnce) {
      return const AppLoadingScreen(
        skeleton: AppLoadingSkeleton.list,
        content: AppLoadingInfo(
          label: 'Carregando grupos...',
          description: 'Buscando grupos da organização',
        ),
      );
    }

    if (state.error != null && state.items.isEmpty && !state.isInitialLoading) {
      return Scaffold(
        body: Center(
          child: ErrorRetryState(
            onRetry: () => ref.read(groupsPagedProvider.notifier).reset(),
            message: state.error.toString(),
          ),
        ),
      );
    }

    final isPartialLoading = state.isInitialLoading && _hasLoadedOnce;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => ref.read(groupsPagedProvider.notifier).resetAsync(),
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
                      child: Text(
                        '${state.items.length} ${state.items.length == 1 ? 'grupo' : 'grupos'}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                    Opacity(
                      opacity: isPartialLoading ? 0.4 : 1.0,
                      child: AbsorbPointer(
                        absorbing: isPartialLoading,
                        child: Material(
                          color: AppTheme.primaryColor,
                          borderRadius: BorderRadius.circular(6),
                          child: InkWell(
                            onTap: _handleCreateGroup,
                            borderRadius: BorderRadius.circular(6),
                            child: const SizedBox(
                              height: 40,
                              width: 40,
                              child: Icon(Icons.add, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ),
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
                      padding: EdgeInsets.only(bottom: 8),
                      child: GroupCardSkeleton(),
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
                  child: NoGroupsEmptyState(onCreateGroup: _handleCreateGroup),
                ),
              )
            else ...[
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: GroupCard(
                        key: ValueKey(state.items[index].id),
                        group: state.items[index],
                        organizationId: widget.organization.id,
                      ),
                    ),
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
                            ref.read(groupsPagedProvider.notifier).loadNextPage(),
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
