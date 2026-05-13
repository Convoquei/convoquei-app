# Brand — Identidade Visual

---

## Logotipo

A geometria forma a letra **"C"**, composta por dois arcos:

- **Arco superior (sólido):** Representa a Organização — estrutura, liderança, base.
- **Arco inferior (translúcido, alpha 40%):** Representa a Equipa/Membros — fluidez, flexibilidade, ação.
- **Respiro visual (gap à esquerda):** Transparência e portas abertas.

### Regras absolutas do logotipo

| Proibido | Motivo |
|----------|--------|
| Sombras duras | Destrói a leveza vetorial |
| Gradientes complexos | Distorce a identidade minimalista |
| Distorção de proporções | A beleza está na geometria exata |
| Recolorir arbitrariamente | Cores são parte da identidade |

### Implementação

O logotipo animado está em `DSSpinner` — é o loader brand principal da app.
Usar `DSSpinner` em todas as telas de loading. Nunca substituir por `CircularProgressIndicator` genérico.

---

## Cores de marca

Referenciar **sempre** via `context.colors.*` — nunca hex hardcoded em features.

| Papel | Token semântico | Valor de referência (informativo) |
|-------|----------------|-----------------------------------|
| Ação principal / brand | `context.colors.primary` | `#2563EB` (light) / `#1D4ED8` (dark primary) |
| Fundo claro do tint | `context.colors.primaryTint` | `#EFF6FF` |
| Fundo de scaffold | `context.colors.background` | `#F8FAFC` (slate50) |
| Superfície de card | `context.colors.surface` | `#FFFFFF` |
| Sucesso / disponível | `context.colors.success` | `#10B981` |
| Aviso / pendente | `context.colors.warning` | `#F97316` |
| Perigo / destrutivo | `context.colors.danger` | `#EF4444` |
| Informativo | `context.colors.info` | `#3B82F6` |

Os valores hex são **apenas informativos** para referência de design — o código usa sempre os tokens.

---

## Tipografia de marca

| Uso | Família | Configuração |
|-----|---------|-------------|
| Display e headings | **Poppins** | SemiBold (600) / Bold (700) |
| Body e UI controls | **Inter** | Regular (400) / Medium (500) / SemiBold (600) |

Já configuradas no `DSTheme.textTheme`. Nunca especificar `fontFamily:` manualmente em features.

Usar sempre `context.textStyles.<variant>` — a família correta é aplicada automaticamente.

---

## Princípio de marca aplicado à UI

O Convoquei é **funcional, transparente e humano**.

- Interfaces limpas com fundo branco/translúcido (os dados são o produto, não o chrome)
- Animações suaves e propositais (DSMotion.normal = 250ms como default)
- Hierarquia visual clara: o utilizador sabe sempre onde está e o que pode fazer
- Sem ornamentos desnecessários — cada pixel serve a um propósito
