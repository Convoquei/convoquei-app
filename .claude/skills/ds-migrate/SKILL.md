---
name: ds-migrate
description: Migrar página, widget ou feature legado para usar exclusivamente o Design System (DSButton, DSCard, context.colors, DSSpacing, etc.). Substitui shims @Deprecated e estilização ad-hoc.
---

# /ds-migrate

Migra código existente para o Design System do Convoquei. Mantém a lógica de negócio e estrutura da página — altera apenas a camada visual.

## Escopo

O argumento define o alvo:
- `/ds-migrate lib/features/events/pages/event_detail_page.dart`
- `/ds-migrate lib/features/members/`

## Processo

### 1. Ler e mapear

- Ler o(s) arquivo(s) alvo
- Listar: widgets legados usados, cores hardcoded, TextStyles crus, raios/espaçamentos soltos
- Consultar `design-system.md` seções 4–6 para o equivalente DS de cada item encontrado

### 2. Substituições diretas

| Legado | DS |
|--------|----|
| `ActionButton(...)` | `DSButton(...)` |
| `ActionCard(...)` | `DSActionCard(...)` |
| `AlertBanner(...)` | `DSAlertBanner(...)` |
| `TagLabel(...)` | `DSBadge(...)` |
| `AppTheme.xxx` | `DSTheme` ou `context.colors.*` |
| `UserAvatar(...)` | `DSAvatar(...)` |
| `ErrorRetryState(...)` | `DSErrorRetryState(...)` |
| `InfoBanner(...)` | `DSInfoBanner(...)` |
| `SelectableTile(...)` | `DSSelectableTile(...)` |
| `TimelineGroup(...)` | `DSTimelineGroup(...)` |
| `AppModal.show(...)` | `DSModal.show(...)` |
| `MultiSelectModal(...)` | `DSMultiSelectModal(...)` |
| `Color(0xFF...)` | `context.colors.<token>` |
| `TextStyle(fontSize: N)` | `context.textStyles.<variant>` |
| `BorderRadius.circular(N)` | `DSRadius.allLg` / `allMd` / `allSm` |
| `EdgeInsets.all(16)` | `EdgeInsets.all(DSSpacing.lg)` |
| `Duration(milliseconds: 250)` | `DSMotion.normal` |
| `import 'package:convoquei_app/core/widgets/...'` | `import 'package:convoquei_app/design_system/ds.dart'` |

### 3. Não tocar

- Lógica de negócio e providers Riverpod
- Navegação (`context.goNamed`, `context.pushNamed`)
- Estrutura de widgets (Column, Row, ListView, etc.) — apenas os leafs visuais
- Nomes de variáveis, parâmetros, métodos

### 4. Validar

Após as edições, rodar análise estática:
```
dart analyze lib/features/<pasta_migrada>/
```
(Via `mcp__dart-mcp__analyze_files` se disponível)

Confirmar que não há erros de compilação antes de encerrar.

## Regras

- Não introduzir refactoring além do necessário para a migração
- Não alterar comportamento da UI (layout, lógica de estado, navegação)
- Se um widget legado não tiver equivalente DS direto, reportar ao utilizador antes de prosseguir
- Se a migração exigir alteração de parâmetros públicos da página, confirmar com o utilizador
