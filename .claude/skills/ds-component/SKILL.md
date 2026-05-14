---
name: ds-component
description: Criar novo componente reutilizável dentro do Design System (lib/design_system/). Verifica duplicação, decide categoria (foundation vs component), consome tokens e registra no ds.dart.
---

# /ds-component

Adiciona novo componente ao Design System do Convoquei. O DS é a única fonte de verdade visual — novos componentes entram aqui, nunca em `lib/core/widgets/`.

## Antes de criar

**Verificar duplicação obrigatória.** Consultar `.claude/rules/design-system.md` seções 4 e 5 (catálogo de foundations e components). Se existir equivalente, abortar e sugerir reuso.

Também verificar:
```
lib/design_system/foundations/
lib/design_system/components/
```

Se já existe algo similar com parâmetros insuficientes, preferir **estender o existente** a criar um novo.

## Decidir categoria

| Categoria | Quando usar | Exemplos |
|-----------|-------------|----------|
| `foundations/` | Átomo — sem dependência de outros DS components | `DSText`, `DSIcon`, `DSAvatar`, `DSBadge`, `DSSkeleton` |
| `components/<grupo>/` | Composto — usa foundations ou widgets Flutter com lógica | `DSButton`, `DSCard`, `DSModal`, `DSMultiSelectModal` |

Grupos em `components/`: `buttons/`, `cards/`, `feedback/`, `inputs/`, `lists/`, `overlays/`

## Estrutura do arquivo

```dart
// Descrição de uma linha do componente.
// Exemplo de uso mínimo.
import 'package:flutter/material.dart';

import '../../theme/ds_context_extensions.dart';
import '../../tokens/ds_spacing.dart';
import '../../tokens/ds_radius.dart';
import '../../tokens/ds_motion.dart';

// Enum de variantes (se aplicável) — sempre top-level
enum DSExampleVariant { primary, subtle }

class DSExample extends StatelessWidget {
  final String label;
  final DSExampleVariant variant;
  final VoidCallback? onTap;

  const DSExample({
    super.key,
    required this.label,
    this.variant = DSExampleVariant.primary,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: DSSpacing.lg,
          vertical: DSSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: variant == DSExampleVariant.primary
              ? colors.primary
              : colors.surfaceSubtle,
          borderRadius: DSRadius.allMd,
        ),
        child: Text(label, style: textStyles.labelMedium),
      ),
    );
  }
}
```

## Regras de implementação

- **Tokens apenas:** `DSSpacing.*`, `DSRadius.*`, `DSElevation.*`, `DSMotion.*`
- **Cores via context:** `context.colors.*` — nunca `Color(0xFF...)`
- **Tipografia via context:** `context.textStyles.*` — nunca `TextStyle(...)`
- **Primitivos proibidos:** `DSColorsPrimitive` e `DSTypography` são internos do DS — não usar em novos componentes
- **Enums top-level:** variantes como `DSExampleVariant` declaradas fora da classe
- **Parâmetros opcionais com defaults sensatos:** o caso mais comum não deve exigir parâmetros
- **Complexidade:** o componente deve ser o mai simples possível, não deve haver complexidade desnecessária

## Registrar no ds.dart

Após criar o arquivo, adicionar o export no `lib/design_system/ds.dart` na seção correta:

```dart
// ── Components: <grupo> ──────────────────────────────────────────────────────
export 'components/<grupo>/ds_<nome>.dart';
```

Para foundations:
```dart
// ── Foundations ──────────────────────────────────────────────────────────────
export 'foundations/ds_<nome>.dart';
```

## Não criar

- Arquivos de teste, exemplo ou documentação separados
- Wrapper de `TextField` / `TextFormField` (inputs herdam tema)
- Componente que só é usado em uma feature específica — esses ficam em `lib/features/<feature>/widgets/`

## Validar

```
dart analyze lib/design_system/
```

Confirmar que `ds.dart` exporta o novo componente sem erros.
