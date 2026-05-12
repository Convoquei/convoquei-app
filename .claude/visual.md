# Identidade Visual e AppTheme

`app_theme.dart` é a **única fonte de verdade** para todo estilo visual.
Nunca use valores `Color(...)`, `Colors.*` ou `TextStyle` inline nos widgets — sempre via `AppTheme.*` ou `Theme.of(context)`.

---

## Paleta de Cores

### Cores principais (já existem no `AppTheme`)

| Constante | Hex | Uso |
|---|---|---|
| `AppTheme.primaryColor` | `#1D4ED8` | Botões principais, cabeçalhos, destaques ativos |
| `AppTheme.secondaryColor` | `#F97316` | FABs, notificações de convite, badges "Aguardando" |
| `AppTheme.backgroundColor` | `#F8FAFC` | Fundo geral (cinza levemente azulado) |
| `AppTheme.textPrimary` | `#1E293B` | Textos principais |
| `AppTheme.textSecondary` | `#64748B` | Descrições, horários, locais |
| `AppTheme.borderColor` | `#E2E8F0` | Bordas neutras de inputs, dividers sutis |

### Cores semânticas — ciclo de vida dos eventos

| Constante proposta | Hex | Significado |
|---|---|---|
| `AppTheme.successColor` | `#10B981` | Disponível / Escalado / Sucesso |
| `AppTheme.errorColor` | `#EF4444` | Indisponível / Cancelado / Erro |
| `AppTheme.warningColor` | `#F59E0B` | Aguardando Resposta / Alerta |
| `AppTheme.infoColor` | `#3B82F6` | Em Andamento / Informação |

> Cores semânticas marcadas como "propostas" ainda precisam ser adicionadas ao `AppTheme` antes de serem usadas. Siga o fluxo da seção abaixo.

### Logo e Assinatura Visual

- **Light Mode:** Linha superior `#1D4ED8`, linha inferior com 40% de opacidade, texto `#1E293B`.
- **Dark Mode:** Linha superior `#FFFFFF`, linha inferior com 40% de opacidade, texto `#FFFFFF`.
- **App Icon (lojas):** Fundo sempre `#1D4ED8`, linhas sempre brancas — não muda entre temas.

---

## Tipografia

Utilize apenas as fontes declaradas no `AppTheme` via `Theme.of(context).textTheme.*`. Nunca defina `fontFamily`, `fontSize`, `fontWeight` ou `color` inline nos widgets.

| Fonte | Uso |
|---|---|
| `Poppins` | Títulos, display, AppBar |
| `Inter` | Corpo de texto, labels, UI |

> `Montserrat` e `Roboto` **não fazem parte** do `AppTheme` e não devem ser usadas.

---

## Componentes

### Border Radius
- Cards e modais: `16px` (`BorderRadius.circular(16)`)
- Botões e inputs: `12px` (`BorderRadius.circular(12)`)
- Nunca use cantos retos (`BorderRadius.zero`) em superfícies de conteúdo.

### Ícones
- Estado **ativo** (item selecionado): ícone preenchido (sólido).
- Estado **inativo** (menu não selecionado): ícone outline.

### Sombras
- Use `elevation: 2` via `cardTheme` do `AppTheme` — não aplique sombras customizadas fora dele.

### Inputs
- Todos os campos (`TextField`, `TextFormField`, `DropdownButtonFormField`) herdam de `inputDecorationTheme` no `AppTheme`. **Não crie wrappers customizados** (`StyledTextField`, `AppSearchInput`, etc.).
- Use `TextField`/`TextFormField` direto, passando apenas: `labelText`, `hintText`, `prefixIcon`, `suffixIcon`, `helperText`, `errorText`, `validator`, `controller`, `keyboardType`, `maxLines`.
- Para busca: `prefixIcon: Icon(Icons.search_rounded, size: 20)`.
- Exceção válida: campos sobre superfícies coloridas (ex: search no header primário) podem sobrescrever `fillColor`/`border` inline, desde que justificado.

### Badges de Status

| Status | Cor |
|---|---|
| Aguardando Escalação | `warningColor` |
| Escala Fechada | `infoColor` |
| Em Andamento | `infoColor` |
| Finalizado | `successColor` |
| Cancelado | `errorColor` |

---

## Quando um token não existe no AppTheme

Se um layout precisar de cor, estilo de texto, espaçamento ou componente que **não existe** no `AppTheme`:

1. **Não** codifique o valor inline.
2. **Pare e mostre ao usuário** exatamente:
   - Qual token está faltando.
   - O código exato da adição proposta.
3. Somente após confirmação, adicione ao `AppTheme` e use no widget.

**Exemplo:**
> O layout precisa de uma cor de sucesso que ainda não existe no `AppTheme`. Gostaria de adicionar:
> ```dart
> static const successColor = Color(0xFF10B981);
> ```
> Posso adicionar isso ao `AppTheme` e usar aqui?

---

## Sincronização ao editar `app_theme.dart`

Toda vez que `app_theme.dart` for modificado, **atualize também** `.claude/visual.md` na mesma operação:

| Tipo de mudança | O que atualizar em `visual.md` |
|---|---|
| Nova constante de cor | Adicione à tabela correspondente com hex e uso |
| Constante removida/renomeada | Remova/renomeie a entrada — nunca deixe referências mortas |
| Novo estilo de texto | Documente na seção "Tipografia" |
| Novo tema de componente | Documente na seção "Componentes" |

> **Nunca** edite `app_theme.dart` sem sincronizar `visual.md` na mesma operação.
