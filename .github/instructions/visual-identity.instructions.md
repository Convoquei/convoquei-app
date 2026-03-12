---
description: Use estas instruções ao trabalhar em UI/UX, estilos, temas, design system ou qualquer componente visual do app Convoquei.
applyTo: 'lib/**/*.dart'
---

## Convoquei – Diretrizes de Identidade Visual

Este documento é a **referência de design** do Convoquei. Toda implementação visual deve seguir estas diretrizes e ser concretizada através do `#file:app_theme.dart`, conforme as regras de `#file:apptheme.instructions.md`.

### Contexto do Projeto

Convoquei é um app mobile para gerenciamento de organizações, equipes e eventos. Centraliza comunicação, disponibilidade e escalas (manuais ou automáticas). O público-alvo inclui líderes de ministérios, coordenadores de equipes voluntárias e membros em geral.

**Palavras-chave da marca:** Organização · Justiça · Transparência · Comunidade · Agilidade · Confiança · Previsibilidade

---

### Paleta de Cores

Todas as cores abaixo devem estar declaradas como constantes no `AppTheme`. Nunca use os valores hex diretamente nos widgets — sempre via `AppTheme.*`.

#### Cores Principais (já existem no `AppTheme`)
| Constante no AppTheme | Hex | Uso |
|---|---|---|
| `AppTheme.primaryColor` | `#1D4ED8` | Botões principais, cabeçalhos, destaques ativos |
| `AppTheme.secondaryColor` | `#F97316` | FABs, notificações de convite, badges "Aguardando" |
| `AppTheme.backgroundColor` | `#F8FAFC` | Fundo geral (cinza levemente azulado) |
| `AppTheme.textPrimary` | `#1E293B` | Textos principais |
| `AppTheme.textSecondary` | `#64748B` | Descrições, horários, locais |

#### Cores Semânticas (já existem no `AppTheme`)
| Constante no AppTheme | Hex | Uso |
|---|---|---|
| `AppTheme.errorColor` | `#EF4444` | Indisponível / Cancelado / Erro |

#### Cores Semânticas (ciclo de vida dos eventos — adicionadas ao AppTheme)
Estas cores representam estados do sistema e estão disponíveis via `AppTheme`.

| Constante no AppTheme | Hex | Significado |
|---|---|---|
| `AppTheme.successColor` | `#10B981` | Disponível / Escalado / Sucesso |
| `AppTheme.warningColor` | `#F59E0B` | Aguardando Resposta / Alerta |
| `AppTheme.infoColor` | `#3B82F6` | Em Andamento / Informação |

#### Logo e Assinatura Visual
- **Light Mode:** Linha superior `#1D4ED8`, linha inferior com 40% de opacidade, texto `#1E293B`.
- **Dark Mode:** Linha superior `#FFFFFF`, linha inferior com 40% de opacidade, texto `#FFFFFF`.
- **App Icon (lojas):** Fundo sempre `#1D4ED8`, linhas sempre brancas — não muda entre temas.

---

### Tipografia

Utilize apenas as fontes declaradas no `AppTheme`. Nunca defina `fontFamily` inline nos widgets.

| Fonte | Uso |
|---|---|
| `Poppins` | Títulos, display, AppBar — tom amigável e comunitário |
| `Inter` | Corpo de texto, labels, UI — legibilidade em tamanhos pequenos |

> `Montserrat` e `Roboto` **não fazem parte** do `AppTheme` e não devem ser usadas.

---

### UI & Componentes

#### Border Radius
- Cards e modais: `16px` (`BorderRadius.circular(16)`).
- Botões e inputs: `12px` (`BorderRadius.circular(12)`).
- Nunca use cantos retos (`BorderRadius.zero`) em superfícies de conteúdo. Interfaces devem ser amigáveis e não intimidadoras.

#### Ícones
- Estado **ativo** (item selecionado): ícone preenchido (sólido).
- Estado **inativo** (menu não selecionado): ícone outline.
- Preferir ícones universais: calendário, pessoas, engrenagem, sino.

#### Sombras
- Cards em listas longas de escalas devem ter sombra suave (`elevation: 2`) para separar visualmente as informações — já configurado no `cardTheme` do `AppTheme`.
- Não aplique sombras customizadas fora do `cardTheme`.

#### Badges de Status
Etiquetas coloridas e arredondadas para representar o ciclo de vida dos eventos — use as cores semânticas da seção acima:

| Status | Cor |
|---|---|
| Aguardando Escalação | `warningColor` |
| Escala Fechada | `infoColor` |
| Em Andamento | `infoColor` |
| Finalizado | `successColor` |
| Cancelado | `errorColor` |

---

### Tom de Voz (Microcopy)

Direto, empático e transparente. Nunca robótico ou militar.

| ❌ Evitar | ✅ Usar |
|---|---|
| "Falha na submissão de disponibilidade." | "Ops! Não conseguimos salvar sua resposta. Tente novamente." |
| "Usuário não escalado." | "Você está de folga neste evento." |
| "Operação concluída." | "Tudo certo! Sua disponibilidade foi salva." |

Sempre informar o próximo passo ao usuário. Ex.: _"Sua disponibilidade foi enviada. Aguardando o líder fechar a escala."_