---
name: ds-audit
description: Auditar conformidade com o design system em um arquivo, pasta ou feature. Detecta violações (cores hardcoded, TextStyle cru, imports diretos, widgets legados) e reporta punch list sem editar.
---

# /ds-audit

Audita conformidade com o Design System do Convoquei. Somente leitura — reporta violações, não edita.

## Escopo

O argumento do comando define o escopo:
- `/ds-audit lib/features/events/` → audita a pasta inteira
- `/ds-audit lib/features/events/pages/event_detail_page.dart` → audita um arquivo
- `/ds-audit` (sem argumento) → audita `lib/features/` completo

## O que verificar

### 1. Padrões proibidos (grep)

```
Color\(0xFF           → cor hardcoded
Color\(0x             → cor hardcoded (alpha)
TextStyle\(           → TextStyle cru (fora de lib/design_system/)
BorderRadius\.circular\(\d  → raio com número solto
BoxShadow\(           → sombra custom
Duration\(milliseconds:     → duração de animação hardcoded
import.*design_system/(tokens|theme|foundations|components)/  → import direto de subpasta (deve ser via ds.dart)
import.*core/widgets/       → import de widget legado
```

### 2. Uso correto (validar presença)

Para arquivos que produzem UI:
- Cores via `context.colors.*`
- Tipografia via `context.textStyles.*`
- Espaçamento via `DSSpacing.*`
- Raios via `DSRadius.*`
- Animações via `DSMotion.*`

### 3. Shims @Deprecated

Verificar uso de: `ActionButton`, `ActionCard`, `AlertBanner`, `TagLabel`, `AppTheme`
→ sinalizar para migração para `DSButton`, `DSActionCard`, `DSAlertBanner`, `DSBadge`, `DSTheme`

## Formato do relatório

```
VIOLAÇÕES ENCONTRADAS — lib/features/events/

❌ lib/features/events/pages/event_detail_page.dart:47
   Color(0xFF1D4ED8) → usar context.colors.primary

❌ lib/features/events/widgets/event_card.dart:23
   TextStyle(fontSize: 14) → usar context.textStyles.bodyMedium

❌ lib/features/events/widgets/event_card.dart:89
   import 'package:convoquei_app/core/widgets/tag_label.dart' (shim @Deprecated)
   → migrar para DSBadge

RESUMO: 3 violações em 2 arquivos.
```

## Instruções de execução

1. Identificar o escopo pelos argumentos do comando
2. Usar Grep para cada padrão proibido dentro do escopo
3. Filtrar resultados excluindo `lib/design_system/` (o DS pode usar primitivos internamente)
4. Para cada hit: reportar arquivo:linha + padrão encontrado + substituição sugerida
5. Ao final: RESUMO com contagem de violações e arquivos afetados
6. NÃO editar nenhum arquivo — apenas reportar
