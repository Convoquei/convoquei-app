# Design System — Catálogo e Regras

Leia este documento **antes de criar ou modificar qualquer widget ou tela**.
Estas regras são **obrigatórias e não negociáveis**.

---

## Princípio absoluto

Import único para qualquer símbolo do DS:

```dart
import 'package:convoquei_app/design_system/ds.dart';
```

**Proibido:**
- Importar de `tokens/`, `theme/`, `foundations/` ou `components/` diretamente
- `Color(0xFF...)` ou `Color(0x...)` hardcoded fora de `lib/design_system/`
- `TextStyle(...)` cru em features — use `context.textStyles.<variant>`
- `BorderRadius.circular(N)` com número solto — use `DSRadius.allLg` etc.
- `BoxShadow(...)` custom — use `DSElevation.sm / md / lg`
- `Duration(milliseconds: N)` em animações de UI — use `DSMotion.fast / normal / slow`
- Criar wrapper de `TextField` / `TextFormField` — inputs herdam o tema automaticamente

---

## Tokens

### DSSpacing (dp)
| Token | Valor |
|-------|-------|
| `DSSpacing.xs` | 4 |
| `DSSpacing.sm` | 8 |
| `DSSpacing.md` | 12 |
| `DSSpacing.lg` | 16 |
| `DSSpacing.xl` | 24 |
| `DSSpacing.xxl` | 32 |
| `DSSpacing.huge` | 48 |

### DSRadius (dp)
| Token | Valor | Getter BorderRadius |
|-------|-------|---------------------|
| `DSRadius.sm` | 8 | `DSRadius.allSm` |
| `DSRadius.md` | 12 | `DSRadius.allMd` |
| `DSRadius.lg` | 16 | `DSRadius.allLg` |
| `DSRadius.xl` | 20 | `DSRadius.allXl` |

Raio custom: `DSRadius.all(valor)`.

### DSElevation
| Token | Uso |
|-------|-----|
| `DSElevation.sm` | cards e chips sutis |
| `DSElevation.md` | cards principais, inputs focados |
| `DSElevation.lg` | modais, bottom sheets, overlays |

### DSMotion
| Token | Duração |
|-------|---------|
| `DSMotion.fast` | 150 ms |
| `DSMotion.normal` | 250 ms |
| `DSMotion.slow` | 400 ms |

Curves: `DSMotion.standard` (easeInOut) · `DSMotion.emphasized` (fastOutSlowIn) · `DSMotion.decelerate`

---

## Acesso semântico via context

```dart
// Cores
context.colors.primary          // ação principal
context.colors.surface          // fundo de card / modal
context.colors.background       // fundo do scaffold
context.colors.surfaceSubtle    // fundo secundário, chips inativos
context.colors.surfaceElevated  // superfícies sobrepostas
context.colors.border           // bordas de cards e inputs
context.colors.divider          // linhas separadoras
context.colors.textPrimary      // títulos, high-emphasis
context.colors.textSecondary    // subtítulos, placeholders
context.colors.onPrimary        // texto sobre fundo primary
context.colors.success / successTint
context.colors.warning / warningTint
context.colors.danger  / dangerTint
context.colors.info    / infoTint

// Tipografia
context.textStyles.displayLarge   // Poppins 32 w700
context.textStyles.displayMedium  // Poppins 24 w600
context.textStyles.titleLarge     // Poppins 20 w600
context.textStyles.titleMedium    // Inter  16 w600
context.textStyles.titleSmall     // Inter  14 w600
context.textStyles.labelLarge     // Inter  14 w600
context.textStyles.labelMedium    // Inter  13 w500
context.textStyles.labelSmall     // Inter  11 w500
context.textStyles.bodyLarge      // Inter  14 w400
context.textStyles.bodyMedium     // Inter  14 w400
context.textStyles.bodySmall      // Inter  12 w400
```

---

## Catálogo de Foundations

### DSText
```dart
DSText('Olá', variant: DSTextVariant.titleLarge)
DSText('desc', variant: DSTextVariant.bodySmall, color: context.colors.textSecondary)
```
Variantes: `displayLarge | displayMedium | titleLarge | titleMedium | titleSmall | labelLarge | labelMedium | labelSmall | bodyLarge | bodyMedium | bodySmall`

### DSIcon
```dart
DSIcon(Icons.star_rounded, size: DSIconSize.md)   // default: textSecondary
DSIcon(Icons.star_rounded, color: context.colors.primary)
```
Tamanhos: `xs=14 | sm=18 | md=24 | lg=32`

### DSAvatar
```dart
DSAvatar(name: member.displayName, avatarUrl: member.avatarUrl, radius: 20)
```
Gera iniciais e cor determinística quando não há foto.

### DSBadge
```dart
DSBadge(label: 'Ativo', color: context.colors.success, variant: DSBadgeVariant.soft)
DSBadge(label: 'Admin', color: context.colors.primary, variant: DSBadgeVariant.filled, size: DSBadgeSize.md)
```
Variants: `filled | outlined | soft | ghost | elevated`
Sizes: `sm | md | lg`

### DSSkeleton
```dart
DSSkeleton(height: 48, width: 200)
DSSkeleton(height: 16, borderRadius: DSRadius.sm)
```

### DSSpinner
```dart
DSSpinner()          // size=96 — loader brand principal
DSSpinner(size: 48)
```

### DSDivider
```dart
DSDivider()
DSDivider(indent: DSSpacing.lg, endIndent: DSSpacing.lg)
```

---

## Catálogo de Components

### Buttons

#### DSButton
```dart
DSButton(label: 'Salvar', onPressed: _save)
DSButton(label: 'Excluir', schema: DSButtonSchema.danger, size: DSButtonSize.sm)
DSButton(label: 'Carregando', isLoading: true)
DSButton(label: 'Cancelar', outlined: true, schema: DSButtonSchema.ghost)
DSButton(label: 'Criar evento', icon: Icons.add_rounded, fullWidth: false)
```
Schemas: `primary | secondary | success | danger | ghost`
Sizes: `md(h52) | sm(h40) | xs(h32)`

#### DSIconButton
```dart
DSIconButton(icon: Icons.close_rounded, onPressed: _close)
DSIconButton(icon: Icons.edit_rounded, backgroundColor: context.colors.surfaceSubtle)
```

### Inputs
`TextField` e `TextFormField` puros — herdam `inputDecorationTheme` do `DSTheme` automaticamente.
**Não criar wrapper.** Usar apenas `InputDecoration(labelText: ..., hintText: ...)`.

#### DSSearchInput
```dart
DSSearchInput(
  controller: _controller,
  hintText: 'Buscar membros...',
  onChanged: (q) => ref.read(filterProvider.notifier).search(q),
  onClear: () => _controller.clear(),
)
```

### Feedback

#### DSAlertBanner
```dart
DSAlertBanner(
  text: 'Convite pendente de aceitação',
  icon: Icons.mail_outline_rounded,
  color: context.colors.warning,
)
```

#### DSInfoBanner
```dart
DSInfoBanner(
  bgColor: context.colors.infoTint,
  borderColor: context.colors.info,
  icon: Icons.info_outline_rounded,
  iconColor: context.colors.info,
  label: 'Lembre-se',
  sublabel: 'Confirme sua disponibilidade até sexta.',
)
```

#### DSErrorRetryState
```dart
DSErrorRetryState(
  message: 'Não foi possível carregar os eventos.',
  description: 'Verifique sua conexão e tente novamente.',
  onRetry: () => ref.invalidate(eventsProvider),
)
```

#### DSLoadingScreen
```dart
DSLoadingScreen(
  label: 'Carregando eventos...',
  description: 'Buscando sua agenda',
  skeleton: DSLoadingSkeleton.list,     // ou .details
)
```

### Cards

#### DSCard
```dart
DSCard(child: MyContent())
DSCard(padding: EdgeInsets.zero, onTap: _onTap, child: MyRow())
DSCard(hasElevation: true, child: MyContent())
```
Padrão: `padding=16(lg)`, `hasBorder=true`, `hasElevation=false`.

#### DSActionCard
```dart
DSActionCard(
  icon: Icons.group_rounded,
  title: 'Equipe',
  subtitle: 'Gerencie os membros',
  outlined: true,
  onTap: () => context.pushNamed(AppRoutes.team),
)
```

### Lists

#### DSSelectableTile
```dart
DSSelectableTile(
  title: group.name,
  description: '${group.memberCount} membros',
  isSelected: selectedIds.contains(group.id),
  onTap: () => _toggle(group.id),
)
```

#### DSTimelineGroup
```dart
DSTimelineGroup(
  title: 'Março',
  children: events.map((e) => EventCard(e)).toList(),
)
```

### Overlays

#### DSModal (avulso)
```dart
DSModal.show(context, MyCustomModal());
DSModal.hide(context, result);
```

#### DSBaseModal (estruturado)
```dart
class EditRoleModal extends DSBaseModal {
  const EditRoleModal({super.key});
  @override
  State<EditRoleModal> createState() => _EditRoleModalState();
}

class _EditRoleModalState extends DSBaseModalState<EditRoleModal> {
  @override
  String? get titleText => 'Editar papel';

  @override
  List<Widget> buildBody(BuildContext context) => [
    Padding(
      padding: EdgeInsets.all(DSSpacing.xl),
      child: ...,
    ),
  ];
}

// Abrir:
DSBaseModal.show(context, const EditRoleModal());
```

#### DSModalHeader
```dart
DSModalHeader(title: 'João Silva', subtitle: 'Membro desde jan/2024')
```

#### DSMultiSelectModal
```dart
final saved = await DSMultiSelectModal.show<GroupModel>(
  context,
  title: 'Grupos',
  subtitle: 'Atribuir a grupos',
  fetcher: (ref) => ref.read(groupsProvider.future),
  idExtractor: (g) => g.id,
  initialSelectedIds: member.groupIds.toSet(),
  itemBuilder: (group, isSelected, onTap) =>
      DSSelectableTile(title: group.name, isSelected: isSelected, onTap: onTap),
  onSave: (ids) => ref.read(assignGroupsProvider(member.id).notifier).save(ids),
  saveLabel: 'Atribuir grupos',
);
```

---

## Mapa de legados → DS

Shims `@Deprecated` em `lib/core/widgets/` — **substituir em código novo**:

| Legado | DS equivalente |
|--------|----------------|
| `ActionButton` | `DSButton` |
| `ActionButtonSchema` | `DSButtonSchema` |
| `ActionButtonSize` | `DSButtonSize` |
| `ActionCard` | `DSActionCard` |
| `AlertBanner` | `DSAlertBanner` |
| `TagLabel` | `DSBadge` |
| `TagLabelVariant` | `DSBadgeVariant` |
| `TagLabelSize` | `DSBadgeSize` |
| `AppTheme` | `DSTheme` |

Widgets **não migrados** (não usar como referência de estilo — todos têm equivalente DS):
`app_logo`, `wizard_page`, `base_scrollable_page`, `custom_calendar`, `emoji_picker_widget`,
`filter_button`, `label_divider`, `status_circle`, `convoquei_loading_icon`,
`date_range_filter_section`, `header_modal_title_subtitle`, `info_banner`,
`selectable_tile`, `timeline_group`, `user_avatar`, `error_retry_state`,
`app_loading_info`, `base_modal_stateful_widget`, `modals/app_modal`, `modals/multi_select_modal`

---

## Checklist de revisão

Antes de concluir qualquer PR que toque UI, verificar:

- [ ] Nenhum `Color(0xFF...)` ou `Color(0x...)` fora de `lib/design_system/`
- [ ] Nenhum `import` direto de `tokens/`, `theme/`, `foundations/` ou `components/`
- [ ] Nenhum `TextStyle(...)` cru — usar `context.textStyles.*`
- [ ] Nenhum `BorderRadius.circular(N)` com número solto
- [ ] Nenhum `BoxShadow(...)` custom
- [ ] Nenhum `Duration(milliseconds: N)` em animações — usar `DSMotion.*`
- [ ] Inputs sem wrapper customizado
- [ ] Animações usam `DSMotion.standard / emphasized / decelerate`
- [ ] Nenhum shim `@Deprecated` introduzido em código novo
- [ ] Nenhuma importação de `lib/core/widgets/` legado em código novo (exceto widgets ainda não migrados listados acima)
