import 'package:convoquei_app/design_system/ds.dart';
import 'package:convoquei_app/features/organizations/groups/providers/list_all_groups_query_provider.dart';
import 'package:convoquei_app/features/organizations/groups/widgets/modals/create_group_modal.dart';
import 'package:convoquei_app/features/organizations/groups/widgets/group_card.dart';
import 'package:convoquei_app/features/organizations/groups/widgets/group_card_skeleton.dart';
import 'package:convoquei_app/features/organizations/groups/widgets/no_groups_empty_state.dart';
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

  Future<void> _handleCreate() async {
    if (!mounted) return;
    await CreateGroupModal.show(context, widget.organization.id);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(groupsPagedProvider);
    if (!state.isInitialLoading) _hasLoadedOnce = true;

    final isPartialLoading = state.isInitialLoading && _hasLoadedOnce;
    final count = state.items.length;
    final counterLabel = '$count ${count == 1 ? 'grupo' : 'grupos'}';

    return Scaffold(
      appBar: AppBar(title: const Text('Gerenciar Grupos')),
      body: Builder(
        builder: (context) {
          if (state.isInitialLoading && !_hasLoadedOnce) {
            return const DSLoadingScreen(
              label: 'Carregando grupos...',
              description: 'Buscando grupos da organização',
              skeleton: DSLoadingSkeleton.list,
            );
          }

          if (state.hasError && state.items.isEmpty && !state.isInitialLoading) {
            return DSErrorRetryState(
              message: 'Não foi possível carregar os grupos.',
              description: 'Verifique sua conexão e tente novamente.',
              onRetry: () => ref.read(groupsPagedProvider.notifier).reset(),
            );
          }

          return RefreshIndicator(
        onRefresh: () => ref.read(groupsPagedProvider.notifier).resetAsync(),
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: DSListHeader(
                counterLabel: counterLabel,
                onActionTap: _handleCreate,
                actionTooltip: 'Criar grupo',
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
                  child: NoGroupsEmptyState(onCreateGroup: _handleCreate),
                ),
              )
            else ...[
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: DSSpacing.xl),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => Padding(
                      padding: const EdgeInsets.only(bottom: DSSpacing.sm),
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
                      onPressed: () => ref.read(groupsPagedProvider.notifier).loadNextPage(),
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
