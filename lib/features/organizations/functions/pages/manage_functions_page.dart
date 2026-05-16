import 'dart:async';

import 'package:convoquei_app/design_system/ds.dart';
import 'package:convoquei_app/features/organizations/functions/providers/list_all_functions_query_provider.dart';
import 'package:convoquei_app/features/organizations/functions/widgets/function_card.dart';
import 'package:convoquei_app/features/organizations/functions/widgets/function_card_skeleton.dart';
import 'package:convoquei_app/features/organizations/functions/widgets/modals/create_function_modal.dart';
import 'package:convoquei_app/features/organizations/functions/widgets/no_functions_empty_state.dart';
import 'package:convoquei_app/features/organizations/shared/models/organization_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ManageFunctionsPage extends ConsumerStatefulWidget {
  final OrganizationModel organization;

  const ManageFunctionsPage({super.key, required this.organization});

  @override
  ConsumerState<ManageFunctionsPage> createState() => _ManageFunctionsPageState();
}

class _ManageFunctionsPageState extends ConsumerState<ManageFunctionsPage> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  Timer? _debounce;
  bool _hasLoadedOnce = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(functionsProvider.notifier).reset();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final pos = _scrollController.position;
    if (pos.pixels < pos.maxScrollExtent - 200) return;
    final s = ref.read(functionsProvider);
    if (s.isLoadingMore || s.isInitialLoading || !s.hasNextPage) return;
    ref.read(functionsProvider.notifier).loadNextPage();
  }

  void _handleSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      final name = value.trim().isEmpty ? null : value.trim();
      ref.read(functionsProvider.notifier).reset(name: name);
    });
  }

  Future<void> _handleCreate() async {
    if (!mounted) return;
    await CreateFunctionModal.show(context, widget.organization.id);
  }

  String? get _currentName {
    final text = _searchController.text.trim();
    return text.isEmpty ? null : text;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(functionsProvider);
    if (!state.isInitialLoading) _hasLoadedOnce = true;

    if (state.isInitialLoading && !_hasLoadedOnce) {
      return const DSLoadingScreen(
        label: 'Carregando funções...',
        description: 'Buscando funções da organização',
        skeleton: DSLoadingSkeleton.list,
      );
    }

    if (state.hasError && state.items.isEmpty && !state.isInitialLoading) {
      return Scaffold(
        body: DSErrorRetryState(
          message: 'Não foi possível carregar as funções.',
          description: 'Verifique sua conexão e tente novamente.',
          onRetry: () => ref.read(functionsProvider.notifier).reset(name: _currentName),
        ),
      );
    }

    final isPartialLoading = state.isInitialLoading && _hasLoadedOnce;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => ref.read(functionsProvider.notifier).resetAsync(name: _currentName),
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: DSListHeader(
                searchController: _searchController,
                searchHint: 'Buscar função...',
                onSearchChanged: _handleSearchChanged,
                onClear: () {
                  _searchController.clear();
                  ref.read(functionsProvider.notifier).reset();
                },
                onActionTap: _handleCreate,
                actionTooltip: 'Criar função',
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
                      child: FunctionCardSkeleton(),
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
                  child: NoFunctionsEmptyState(onCreateFunction: _handleCreate),
                ),
              )
            else ...[
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: DSSpacing.xl),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => Padding(
                      padding: const EdgeInsets.only(bottom: DSSpacing.sm),
                      child: FunctionCard(
                        key: ValueKey(state.items[index].id),
                        function: state.items[index],
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
                      onPressed: () => ref.read(functionsProvider.notifier).loadNextPage(),
                    ),
                  ),
                ),
              if (!state.hasNextPage && !state.isLoadingMore)
                const SliverToBoxAdapter(child: SizedBox(height: DSSpacing.xxl)),
            ],
          ],
        ),
      ),
    );
  }
}
