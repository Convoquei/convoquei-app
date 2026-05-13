# UI Patterns — Clean UI (Apple HIG iOS 17 + SaaS moderno)

Leia este documento ao criar ou modificar qualquer tela ou composição de layout.

---

## Princípios

**Foco no conteúdo.** Fundos brancos ou translúcidos. Os dados (escalas, eventos, membros) respiram — sem blocos de cor pesados como cabeçalhos azuis sólidos.

**Hierarquia por contexto.** O utilizador é a âncora: sempre visível "Quem sou" e "Onde estou". Navegação reflete pilhas claras (breadcrumbs, não só seta).

**Familiaridade nativa.** Padrões reconhecíveis: listas inset grouped, bottom sheets para ações secundárias, toggles em vez de checkboxes para estados binários.

---

## App Bar

- Fundo **translúcido** — herdado do `DSTheme.appBarTheme`. Nunca passar `backgroundColor:` custom.
- Título alinhado à **esquerda** como "Large Title" no topo; ao rolar, vira "Inline Title" centralizado.
- Em telas internas, usar **breadcrumb** no leading: `< Configurações` (não apenas seta sem contexto).
- Nunca colocar `AppBar(backgroundColor: context.colors.primary)` — viola o princípio de fundo limpo.

```dart
// Correto
AppBar(title: Text('Papéis', style: context.textStyles.titleLarge))

// Errado — fundo pesado
AppBar(backgroundColor: Colors.blue, title: Text('Papéis'))
```

---

## Identity Card / Switcher

No topo da Home (e telas raiz de org), o perfil do utilizador é **sempre visível**:

```
[Avatar] João Silva         [ícone switch]
         ICOE — Louvor
```

- `DSAvatar` + nome (titleMedium) + nome da org atual (bodySmall, textSecondary)
- Ícone de switch (`Icons.unfold_more_rounded`) abre `DSModal.show(context, OrgSwitcherModal())`
- Nunca esconder em menu hamburger ou drawer oculto

---

## Inset Grouped Lists

Para listas de opções, configurações, papéis ou qualquer set de itens relacionados:

```dart
DSCard(
  padding: EdgeInsets.zero,
  child: Column(
    children: [
      _RoleItem(role: roles[0]),
      DSDivider(indent: DSSpacing.lg, endIndent: DSSpacing.lg),
      _RoleItem(role: roles[1]),
      DSDivider(indent: DSSpacing.lg, endIndent: DSSpacing.lg),
      _RoleItem(roles[2]),   // último: sem divider
    ],
  ),
)
```

- `DSCard(padding: EdgeInsets.zero)` como container
- `DSDivider` com indent entre itens — sem divider no último
- Raio automático `DSRadius.allLg` via DSCard
- Reservar para listas de opções/configs/papéis (não para feeds de eventos — esses usam cards individuais)

---

## Bottom Sheets

Toda ação secundária rápida abre um bottom sheet — **nunca `Navigator.push` de tela cheia** para isso:

| Ação | Pattern |
|------|---------|
| Selecionar grupos de um membro | `DSMultiSelectModal` |
| Editar permissões de um papel | `DSBaseModal` subclass |
| Trocar de organização | `DSBaseModal` subclass |
| Confirmar ação destrutiva | `DSModal.show(context, _ConfirmModal())` |

```dart
// Abrir bottom sheet estruturado
DSBaseModal.show(context, const EditPermissionsModal(roleId: id));

// Abrir widget avulso
DSModal.show(context, const OrgSwitcherSheet());
```

O modal já inclui drag handle (pill cinza no topo), botão fechar, e safe area para teclado.

---

## Toggles e Seletores

- **Estado binário de configuração** (ativo/inativo, notificação on/off): usar `Switch` — nunca Checkbox
- **Seleção múltipla de uma lista**: usar `DSSelectableTile` (tem animação de checkbox embutida)
- **Seleção de uma opção entre várias**: Radio ou segmented control — nunca dropdown onde cabe na tela

---

## Loading e Skeleton

| Situação | Widget |
|----------|--------|
| Tela que carrega dados de rede | `DSLoadingScreen(skeleton: DSLoadingSkeleton.list)` |
| Tela de detalhe com hero card | `DSLoadingScreen(skeleton: DSLoadingSkeleton.details)` |
| Bloco inline aguardando dado | `DSSkeleton(height: 16, width: 120)` |
| Spinner brand isolado | `DSSpinner(size: 48)` |

**Proibido:** tela em branco com `CircularProgressIndicator` genérico.

---

## Glassmorphism

AppBars e Tab Bars usam superfície translúcida (frosted glass).
Isso já está configurado no `DSTheme.appBarTheme` e `navigationBarTheme`.

**Não compor `BackdropFilter` + `ImageFilter.blur` manualmente em features.**
Se a tela precisar de overlay translúcido personalizado, abrir issue para adicionar ao DS.

---

## Cores semânticas de estado

Usar sempre tokens semânticos — nunca cores hardcoded:

| Estado | Token |
|--------|-------|
| Convite pendente / countdown / ação necessária | `context.colors.warning` / `warningTint` |
| Confirmado / disponível / toggle ativo / escalado | `context.colors.success` / `successTint` |
| Indisponível / destrutivo / sair / apagar | `context.colors.danger` / `dangerTint` |
| Informativo neutro / dica / help | `context.colors.info` / `infoTint` |
| Ação principal | `context.colors.primary` |

```dart
// Badge de membro confirmado
DSBadge(label: 'Escalado', color: context.colors.success, variant: DSBadgeVariant.soft)

// Banner de convite pendente
DSAlertBanner(text: '...', icon: Icons.mail_outline_rounded, color: context.colors.warning)
```

---

## Paginação (substitui paginated-lists.md)

**Regra:** scroll infinito com `Notifier<StateListPaged<T>>`.

```
loading inicial  → DSLoadingScreen(skeleton: DSLoadingSkeleton.list)
erro             → DSErrorRetryState(message: ..., onRetry: ...)
lista vazia      → Empty state com DSText + DSButton
load more        → DSSpinner(size: 32) no rodapé da lista
```

Flag `_hasLoadedOnce` é **load-bearing** — sem ela o `RefreshIndicator` quebra o spinner.

Reset por filtro/busca: chamar método do notifier que zera a lista antes do fetch.

Não usar `BaseScrollablePage` (legado — usa `SingleChildScrollView`, incompatível com `StateListPaged`).

---

## Responsividade

| Contexto | Layout |
|----------|--------|
| Mobile (`AppBreakpoints.isWide == false`) | Bottom navigation tabs |
| Desktop/tablet (`AppBreakpoints.isWide == true`) | `NavigationRail` lateral |

Telas dentro de org herdam o shell do `OrganizationShell` — não reimplementar navegação.
Modais: `DSModal.show` detecta automaticamente e usa dialog em wide / bottom sheet em mobile.
