---
name: ds-scaffold
description: Criar nova página, tela ou widget de feature já no padrão DS. Aplica Clean UI (AppBar translúcido, inset grouped, bottom sheets, skeletons), Riverpod @riverpod e microcopy pt-BR.
---

# /ds-scaffold

Scaffolding de nova UI no padrão Convoquei. Sempre DS-first, Clean UI, Riverpod via code gen.

## Antes de criar

1. Identificar o tipo de tela (argumento ou contexto):
   - **Página de lista** — `DSLoadingScreen(skeleton: .list)`, scroll infinito, `StateListPaged`
   - **Página de detalhe** — `DSLoadingScreen(skeleton: .details)`, seções em `DSCard`
   - **Modal / bottom sheet** — `DSBaseModal` subclass, aberto via `DSBaseModal.show()`
   - **Widget de feature** — sem scaffolding de página, apenas widget reutilizável

2. Confirmar onde fica dentro da navegação (ver `CLAUDE.md` — seção Navegação).

## Estrutura de página de lista

```dart
class OrgExamplePage extends ConsumerWidget {
  const OrgExamplePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(exampleListProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Título', style: context.textStyles.titleLarge)),
      body: switch (state) {
        AsyncLoading() => DSLoadingScreen(
            label: 'Carregando...',
            description: 'Buscando dados',
            skeleton: DSLoadingSkeleton.list,
          ),
        AsyncError(:final error) => DSErrorRetryState(
            message: 'Não foi possível carregar.',
            description: 'Verifique sua conexão e tente novamente.',
            onRetry: () => ref.invalidate(exampleListProvider),
          ),
        AsyncData(:final value) => _ExampleList(items: value),
      },
    );
  }
}
```

## Estrutura de lista paginada

```dart
body: Builder(builder: (context) {
  if (!notifier.hasLoadedOnce) {
    return DSLoadingScreen(label: '...', description: '...', skeleton: DSLoadingSkeleton.list);
  }
  if (state.items.isEmpty && state.error != null) {
    return DSErrorRetryState(message: '...', onRetry: () => notifier.load());
  }
  return RefreshIndicator(
    onRefresh: () async => notifier.reset(),
    child: ListView.separated(
      itemCount: state.items.length + (state.hasMore ? 1 : 0),
      separatorBuilder: (_, __) => SizedBox(height: DSSpacing.sm),
      itemBuilder: (context, i) {
        if (i == state.items.length) return Center(child: DSSpinner(size: 32));
        return ExampleCard(item: state.items[i]);
      },
    ),
  );
}),
```

## Regras de composição

### AppBar
```dart
AppBar(title: Text('Nome da tela', style: context.textStyles.titleLarge))
// Em tela interna:
AppBar(
  leading: BackButton(),
  title: Text('< Configurações', style: context.textStyles.titleLarge),
)
```

### Cards e inset grouped
```dart
// Card simples
DSCard(child: MyContent())

// Inset grouped (lista de opções)
DSCard(
  padding: EdgeInsets.zero,
  child: Column(children: [
    OptionTile(option: a),
    DSDivider(indent: DSSpacing.lg, endIndent: DSSpacing.lg),
    OptionTile(option: b),  // último: sem divider
  ]),
)
```

### Ações secundárias
```dart
// Botão que abre modal
DSButton(
  label: 'Atribuir grupos',
  schema: DSButtonSchema.secondary,
  onPressed: () => DSBaseModal.show(context, AssignGroupsModal(memberId: id)),
)
```

### Estado vazio
```dart
Center(
  child: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      DSIcon(Icons.event_outlined, size: DSIconSize.lg, color: context.colors.textSecondary),
      SizedBox(height: DSSpacing.lg),
      DSText('Nenhum evento ainda', variant: DSTextVariant.titleMedium),
      SizedBox(height: DSSpacing.sm),
      DSText(
        'Crie o primeiro evento da sua organização.',
        variant: DSTextVariant.bodyMedium,
        color: context.colors.textSecondary,
        textAlign: TextAlign.center,
      ),
      SizedBox(height: DSSpacing.xl),
      DSButton(label: 'Criar evento', icon: Icons.add_rounded, onPressed: _create),
    ],
  ),
)
```

## Riverpod

Sempre `@riverpod` + code gen. Consultar `.claude/riverpod-reference.md` para providers.

```dart
@riverpod
Future<List<ExampleModel>> exampleList(Ref ref) async {
  final repo = ref.read(exampleRepositoryProvider);
  return repo.findAll();
}
```

## Microcopy

Consultar `.claude/rules/microcopy.md` para todos os textos de UI (loading, erro, vazio, botões).

## Validar

Após criar, rodar:
```
dart analyze lib/features/<pasta>/
```
