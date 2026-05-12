# Componentização — Diretrizes

## Páginas enxutas

Páginas (`*_page.dart`) devem ser **orquestradoras**, não implementadoras.
- Máximo de ~100 linhas. Se passar, extraia widgets.
- Declara o layout geral, lê os providers e delega renderização para widgets filhos.
- Nunca coloque lógica visual complexa (listas, cards, formulários) diretamente no `build()`.

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

## Onde criar widgets

### Widgets reutilizáveis (agnósticos de feature)
Localização: `lib/core/widgets/`

**Use os widgets já existentes antes de criar um novo:**

| Widget | Uso |
|---|---|
| `BaseScrollablePage` | Página com scroll padrão |
| `BaseModalStatefulWidget` | Base para modais com estado |
| `ActionButton` | Botão de ação primário/secundário |
| `ActionCard` | Card clicável com ícone e título |
| `AlertBanner` / `InfoBanner` | Banners de alerta e informação |
| `AppLogo` | Logo do app |
| `AppLoadingScreen` | Tela de carregamento com skeleton + spinner da marca |
| `ConvoqueiLoadingIcon` | Spinner animado da marca (isolado) |
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

- **Widget não existe:** crie em `lib/core/widgets/`.
- **Widget existe, mas precisa de variação:** adicione parâmetros opcionais — nunca quebre a assinatura existente.

### Widgets específicos de feature
Localização: `lib/features/[feature]/widgets/` ou `lib/features/[feature]/[subfeature]/widgets/`

Use quando o widget contém lógica ou visual acoplado à feature (ex.: `EventCard`, `MemberListTile`). Não mova para `lib/core/widgets/` a menos que precise ser reaproveitado em outra feature.

---

## Providers — Convenções de Nomenclatura de Arquivos

```
lib/features/[feature]/providers/
lib/features/[feature]/[subfeature]/providers/
```

| Tipo | Padrão de nome do arquivo |
|---|---|
| Queries | `find_all_*_provider.dart`, `get_*_provider.dart` |
| Mutations | `create_*_provider.dart`, `update_*_provider.dart`, `delete_*_provider.dart` |
| Estado de UI | `*_query_provider.dart`, `*_filter_provider.dart` |

### Quando usar cada tipo de Notifier

| Tipo | Quando usar |
|---|---|
| `Notifier<T>` | Estado síncrono com mutações (filtros, seleções, listas paginadas) |
| `AsyncNotifier<T>` | Operações assíncronas únicas (criar, atualizar, deletar) |
| `@riverpod Future<T>` | Queries sem estado (buscar lista, buscar por ID) |
