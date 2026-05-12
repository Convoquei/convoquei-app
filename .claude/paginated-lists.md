# Telas com listas paginadas e scroll infinito

Use este guia ao criar ou modificar qualquer tela que consome um endpoint paginado.

---

## Modelo mental: máquina de estados de UI

Derive 5 estados do `StateListPaged<T>` nesta ordem de prioridade:

| Estado | Condição | Renderização |
|---|---|---|
| **Initial loading** | `state.isInitialLoading` | `AppLoadingScreen(skeleton: AppLoadingSkeleton.list, content: AppLoadingInfo(...))` |
| **Initial error** | `state.error != null && state.items.isEmpty` | `ErrorRetryState(onRetry: _handleRetry, message: '...')` |
| **Empty** | `state.isEmpty` | Empty state da feature |
| **Data** | `state.items.isNotEmpty` | Lista scrollável + footer |
| **Loading more** | `state.isLoadingMore` (no footer) | `CircularProgressIndicator()` no rodapé |

> `state.isEmpty` já considera `!isInitialLoading && items.isEmpty && error == null` — nunca cheque `items.isEmpty` diretamente para decidir o empty state.

---

## Estrutura padrão de `Page`

```dart
class MyPage extends ConsumerStatefulWidget { ... }

class _MyPageState extends ConsumerState<MyPage> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  Timer? _debounce;
  MyFilter _filter = MyFilter();   // filtro atual aplicado
  // campos de filtro pendente para o painel de filtros

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // addPostFrameCallback é necessário para não modificar provider durante o build.
    // O flicker é evitado porque StateListPaged() já começa com isInitialLoading: true.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(myProvider.notifier).reset(widget.orgId, _filter);
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

    final s = ref.read(myProvider);
    if (s.isLoadingMore || s.isInitialLoading || !s.hasNextPage) return;

    ref.read(myProvider.notifier).loadNextPage(widget.orgId, _filter);
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _applyFilter(_buildFilter(name: value));
    });
  }

  void _applyFilter(MyFilter newFilter) {
    setState(() => _filter = newFilter);
    ref.read(myProvider.notifier).reset(widget.orgId, newFilter);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(myProvider);

    // ── 1. Initial loading ────────────────────────────────────────────────
    if (state.isInitialLoading) {
      return const AppLoadingScreen(
        skeleton: AppLoadingSkeleton.list,
        content: AppLoadingInfo(label: 'Carregando...', description: ''),
      );
    }

    // ── 2. Initial error ──────────────────────────────────────────────────
    if (state.error != null && state.items.isEmpty) {
      return Scaffold(
        body: Center(
          child: ErrorRetryState(
            onRetry: () => ref.read(myProvider.notifier).reset(widget.orgId, _filter),
            message: 'Não foi possível carregar os dados',
          ),
        ),
      );
    }

    return Scaffold(
      body: RefreshIndicator(
        // resetAsync aguarda a resposta antes de esconder o indicador
        onRefresh: () => ref.read(myProvider.notifier).resetAsync(widget.orgId, _filter),
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // ── Barra de busca / filtros ────────────────────────────────
            SliverToBoxAdapter(child: _buildHeader()),

            // ── 3. Empty state ──────────────────────────────────────────
            if (state.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: MyEmptyState(...),
              )
            else ...[
              // ── 4. Data ─────────────────────────────────────────────
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => MyItemCard(item: state.items[index]),
                    childCount: state.items.length,
                  ),
                ),
              ),

              // ── 5. Footer: loading more ──────────────────────────────
              if (state.isLoadingMore)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),

              // ── Footer: retry paginação subsequente ──────────────────
              if (state.error != null && state.items.isNotEmpty)
                SliverToBoxAdapter(
                  child: Center(
                    child: TextButton.icon(
                      onPressed: () => ref.read(myProvider.notifier).loadNextPage(widget.orgId, _filter),
                      icon: const Icon(Icons.refresh_rounded, size: 16),
                      label: const Text('Tentar novamente'),
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
```

---

## Template de notifier paginado com filtro

Use `_generation` para invalidar respostas obsoletas quando filtros mudam rapidamente:

```dart
@riverpod
class MyNotifier extends _$MyNotifier {
  int _generation = 0;

  @override
  StateListPaged<MyModel> build() => const StateListPaged();

  Future<void> loadNextPage(String orgId, MyFilter filter) async {
    if (!state.hasNextPage || state.isLoadingMore || state.isInitialLoading) return;

    final gen = _generation;
    state = state.copyWith(
      isInitialLoading: state.page == 0,
      isLoadingMore: state.page > 0,
      clearError: true,
    );

    try {
      final result = await ref.read(myRepositoryProvider).findAll(
        orgId: orgId,
        request: MyRequest(page: state.page, size: 20, ...filter),
      );

      if (!ref.mounted || _generation != gen) return;

      state = state.copyWith(
        items: [...state.items, ...result.items],
        page: state.page + 1,
        hasNextPage: result.hasNextPage,
        isInitialLoading: false,
        isLoadingMore: false,
      );
    } catch (e) {
      if (!ref.mounted || _generation != gen) return;

      state = state.copyWith(
        isInitialLoading: false,
        isLoadingMore: false,
        error: e,
      );
    }
  }

  void reset(String orgId, MyFilter filter) {
    _generation++;
    state = const StateListPaged();
    loadNextPage(orgId, filter);
  }

  Future<void> resetAsync(String orgId, MyFilter filter) {
    _generation++;
    state = const StateListPaged();
    return loadNextPage(orgId, filter);
  }
}
```

> `const StateListPaged()` tem `isInitialLoading: true` por default — a tela exibe skeleton imediatamente, antes mesmo de `loadNextPage` retornar.

---

## Regras invioláveis

- **Sempre** use `addPostFrameCallback` para disparar o fetch inicial (Riverpod proíbe modificar providers durante o build). O flicker é evitado porque `StateListPaged()` já começa com `isInitialLoading: true`.
- **Nunca** filtre `state.items` localmente após mudança de filtro — chame sempre `notifier.reset(novoFilter)`.
- **Nunca** use `items.isEmpty` puro para decidir empty — use o getter `state.isEmpty` do `StateListPaged`.
- **Sempre** anexe `ScrollController` ao `CustomScrollView`/`ListView` raiz.
- **Sempre** use `resetAsync` no `RefreshIndicator.onRefresh` para que o spinner aguarde a resposta.
- Barra de busca com debounce de **500ms**; o debounce chama `reset`, não filtra local.

---

## Widgets de suporte disponíveis

| Widget | Arquivo | Uso |
|---|---|---|
| `AppLoadingScreen` | `core/widgets/app_loading_screen.dart` | Tela de loading com skeleton + blur |
| `AppLoadingSkeleton.list` | idem | Skeleton de busca + tabs + cards de linha |
| `AppLoadingSkeleton.details` | idem | Skeleton de card hero + tabs + membros |
| `AppLoadingInfo` | `core/widgets/app_loading_info.dart` | Ícone animado + label + description |
| `ErrorRetryState` | `core/widgets/error_retry_state.dart` | Estado de erro com botão de retry |

---

## Implementações de referência

- `lib/features/organizations/events/pages/org_events_page.dart` — padrão completo com filtros, tabs e agrupamento por mês
- `lib/features/organizations/events/providers/find_all_events_membership_provider.dart` — notifier com `_generation`
- `lib/features/organizations/members/widgets/group_list.dart` — scroll infinito em `ListView`
