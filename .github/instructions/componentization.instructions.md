---
description: Use estas instruções ao criar ou refatorar qualquer página, tela ou widget no app Convoquei — incluindo componentização, Riverpod e organização de arquivos.
applyTo: 'lib/**/*.dart'
---

## Diretrizes de Componentização

### Regra geral: páginas enxutas

Páginas (`*_page.dart`) devem ser **orquestradoras**, não implementadoras.
- Máximo de ~100 linhas por página. Se passar disso, extraia widgets.
- A página declara o layout geral, lê os providers necessários e delega a renderização para widgets filhos.
- Nunca coloque lógica visual complexa (listas, cards, formulários, seções grandes) diretamente no `build()` da página.

**Estrutura esperada de uma página:**
```dart
class OrgEventsPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(eventMembershipProvider);
    return BaseScrollablePage(
      child: Column(
        children: [
          EventsFilterSection(filter: state.filter, onChanged: ...),
          EventsList(state: state),
        ],
      ),
    );
  }
}
```

---

### Onde criar widgets

#### 1. Widgets reutilizáveis (agnósticos de feature)
Localização: `lib/core/widgets/`

Use os widgets já existentes antes de criar um novo:

| Widget | Uso |
|---|---|
| `BaseScrollablePage` | Página com scroll padrão |
| `BaseModalStatefulWidget` | Base para modais com estado |
| `ActionButton` | Botão de ação primário/secundário |
| `ActionCard` | Card clicável com ícone e título |
| `AlertBanner` / `InfoBanner` | Banners de alerta e informação |
| `AppLogo` | Logo do app |
| `AppSearchInput` | Campo de busca padronizado |
| `CustomCalendar` | Calendário interativo |
| `DateRangeFilterSection` | Filtro por período |
| `EmojiPickerWidget` | Seletor de emoji |
| `ErrorRetryState` | Estado de erro com botão de retry |
| `FilterButton` | Botão de filtro com badge |
| `HeaderModalTitleSubtitle` | Cabeçalho padrão para modais |
| `LabelDivider` | Divisor com label centralizado |
| `SelectableTile` | Tile selecionável (checkbox/radio visual) |
| `StatusCircle` | Indicador visual de status circular |
| `TagLabel` | Etiqueta colorida de status |
| `TimelineGroup` | Agrupador de itens por linha do tempo |
| `UserAvatar` | Avatar de usuário com fallback |
| `WizzardPage` | Estrutura de wizard multi-etapas |
| `AppModal` | Modal genérico com header e ações |
| `MultiSelectModal` | Modal de seleção múltipla |

**Se o widget que precisa NÃO existe:** crie-o em `lib/core/widgets/` quando for genérico.
**Se o widget existe, mas precisa de uma nova variação:** evolua-o via parâmetros opcionais — nunca quebre a assinatura existente (não remova parâmetros obrigatórios).

#### 2. Widgets específicos de feature
Localização:
```
lib/features/[feature]/widgets/
lib/features/[feature]/[subfeature]/widgets/
```

Use quando o widget contém lógica ou visual acoplado à feature (ex.: `EventCard`, `MemberListTile`, `AvailabilityBadge`). Esses widgets **não devem** ser movidos para `lib/core/widgets/` a menos que precisem ser reaproveitados em outra feature.

---

### Riverpod com Code Generation

O projeto usa **Riverpod com `riverpod_annotation`**. Sempre use o padrão de geração de código — nunca declare providers manualmente com `Provider(...)` ou `NotifierProvider(...)` sem o `@riverpod`.

#### Estrutura obrigatória de um provider

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'nome_provider.g.dart';

@riverpod
class NomeNotifier extends _$NomeNotifier {
  @override
  EstadoTipo build() {
    return EstadoTipo.inicial();
  }

  Future<void> algumMetodo() async {
    // ...
  }
}
```

Após criar ou modificar um provider, execute o build runner:
```
dart run build_runner build --delete-conflicting-outputs
```

#### Quando usar cada tipo de Notifier

| Tipo | Quando usar |
|---|---|
| `Notifier<T>` | Estado síncrono com mutações (ex.: filtros, seleções, listas paginadas) |
| `AsyncNotifier<T>` | Operações assíncronas únicas (ex.: criar, atualizar, deletar) |
| `@riverpod Future<T>` | Queries sem estado (ex.: buscar lista, buscar por ID) |

#### Onde criar providers

```
lib/features/[feature]/providers/
lib/features/[feature]/[subfeature]/providers/
```

Convenção de nomenclatura:
- Queries: `find_all_*_provider.dart`, `get_*_provider.dart`
- Mutations: `create_*_provider.dart`, `update_*_provider.dart`, `delete_*_provider.dart`
- Estado de UI: `*_query_provider.dart`, `*_filter_provider.dart`

#### Consumindo providers nos widgets

- Use `ConsumerWidget` para widgets sem estado local.
- Use `ConsumerStatefulWidget` quando precisar de `initState`, `dispose` ou animações.
- Nunca use `StatefulWidget` + `ProviderScope`/`ProviderContainer` diretamente — sempre herde de `Consumer*`.

```dart
// Correto
class MinhaPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(meuProvider);
    ...
  }
}

// Correto com estado local
class MinhaPage extends ConsumerStatefulWidget {
  @override
  ConsumerState<MinhaPage> createState() => _MinhaPageState();
}

class _MinhaPageState extends ConsumerState<MinhaPage> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(meuProvider);
    ...
  }
}
```

- Use `ref.watch` para valores que devem reconstruir o widget.
- Use `ref.read` dentro de callbacks e event handlers (nunca no `build`).

---

### Resumo

| Regra | Ação |
|---|---|
| Página com mais de ~100 linhas | Extraia widgets |
| Widget genérico necessário | Verifique `lib/core/widgets/` primeiro |
| Widget genérico não existe | Crie em `lib/core/widgets/` |
| Widget genérico existe, mas precisa evoluir | Adicione parâmetros opcionais — sem quebrar a assinatura |
| Widget acoplado à feature | Crie em `lib/features/[feature]/widgets/` |
| Novo provider | Use `@riverpod` + geração de código, nunca manual |
| Leitura reativa no `build` | `ref.watch` |
| Leitura em callback/event handler | `ref.read` |
