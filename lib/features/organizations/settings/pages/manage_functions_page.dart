import 'dart:async';

import 'package:convoquei_app/core/theme/app_theme.dart';
import 'package:convoquei_app/core/widgets/app_loading_info.dart';
import 'package:convoquei_app/core/widgets/app_loading_screen.dart';
import 'package:convoquei_app/core/widgets/error_retry_state.dart';
import 'package:convoquei_app/features/organizations/members/providers/list_all_functions_query_provider.dart';
import 'package:convoquei_app/features/organizations/members/widgets/modals/create_function_modal.dart';
import 'package:convoquei_app/features/organizations/settings/widgets/function_card.dart';
import 'package:convoquei_app/features/organizations/settings/widgets/function_card_skeleton.dart';
import 'package:convoquei_app/features/organizations/settings/widgets/no_functions_empty_state.dart';
import 'package:convoquei_app/features/organizations/shared/models/organization_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ManageFunctionsPage extends ConsumerStatefulWidget {
  final OrganizationModel organization;

  const ManageFunctionsPage({super.key, required this.organization});

  @override
  ConsumerState<ManageFunctionsPage> createState() =>
      _ManageFunctionsPageState();
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

  Future<void> _handleCreateFunction() async {
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
      return const AppLoadingScreen(
        skeleton: AppLoadingSkeleton.list,
        content: AppLoadingInfo(
          label: 'Carregando funções...',
          description: 'Buscando funções da organização',
        ),
      );
    }

    if (state.error != null && state.items.isEmpty && !state.isInitialLoading) {
      return Scaffold(
        body: Center(
          child: ErrorRetryState(
            onRetry: () =>
                ref.read(functionsProvider.notifier).reset(name: _currentName),
            message: state.error.toString(),
          ),
        ),
      );
    }

    final isPartialLoading = state.isInitialLoading && _hasLoadedOnce;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(functionsProvider.notifier).resetAsync(name: _currentName),
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
                          hintText: 'Buscar função...',
                          prefixIcon: Icon(Icons.search_rounded, size: 20),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Opacity(
                      opacity: isPartialLoading ? 0.4 : 1.0,
                      child: AbsorbPointer(
                        absorbing: isPartialLoading,
                        child: Material(
                          color: AppTheme.primaryColor,
                          borderRadius: BorderRadius.circular(6),
                          child: InkWell(
                            onTap: _handleCreateFunction,
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
                  child: NoFunctionsEmptyState(
                    onCreateFunction: _handleCreateFunction,
                  ),
                ),
              )
            else ...[
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
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
                            ref.read(functionsProvider.notifier).loadNextPage(),
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
