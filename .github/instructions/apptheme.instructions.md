---
description: Use estas instruções ao criar ou editar qualquer layout, tela, widget ou componente no app Flutter.
applyTo: 'lib/**/*.dart'
---

## Regras de Uso do AppTheme

Sempre utilize `#file:app_theme.dart` como única fonte de verdade para todo estilo visual ao construir ou modificar qualquer layout, tela ou widget.

### Práticas obrigatórias

1. **Cores** — Nunca use valores `Color(...)` brutos ou constantes `Colors.*` diretamente nos widgets. Sempre referencie as constantes do `AppTheme`:
   - `AppTheme.primaryColor`
   - `AppTheme.secondaryColor`
   - `AppTheme.backgroundColor`
   - `AppTheme.textPrimary`
   - `AppTheme.textSecondary`

2. **Tipografia** — Sempre use os estilos de texto definidos em `AppTheme.light.textTheme` via `Theme.of(context).textTheme.*`. Nunca defina `TextStyle` inline com `fontFamily`, `fontSize`, `fontWeight` ou `color` fixos nos widgets.

3. **Estilos de componentes** — Reutilize os temas `elevatedButtonTheme`, `cardTheme` e `appBarTheme` via `Theme.of(context)` em vez de sobrescrever estilos localmente.

4. **Fontes** — Utilize apenas `Poppins` e `Inter`, conforme declarado no `AppTheme`.

### Quando algo não existe no AppTheme

Se um layout precisar de uma cor, estilo de texto, constante de espaçamento, estilo de componente ou qualquer outro token de design que **não exista** ainda no `AppTheme`:

1. **Não** codifique o valor inline no widget.
2. **Pare e pergunte ao usuário** antes de prosseguir, mostrando exatamente:
   - Qual token está faltando (ex: uma nova cor, uma nova variante de estilo de texto).
   - A adição proposta ao `AppTheme` (o código exato que pretende adicionar).
3. Somente após a confirmação do usuário, adicione o novo token ao `AppTheme` e então utilize-o no layout.

**Exemplo de mensagem ao usuário:**

> O layout precisa de uma cor de sucesso que ainda não existe no `AppTheme`. Gostaria de adicionar o seguinte:
> ```dart
> static const successColor = Color(0xFF16A34A);
> ```
> Posso adicionar isso ao `AppTheme` e usar aqui?

### Sincronização das Instructions

Sempre que o arquivo `app_theme.dart` for modificado — seja para adicionar, remover ou alterar qualquer token (cor, estilo de texto, componente, fonte) — **atualize imediatamente** os seguintes arquivos para refletir a mudança:

1. **`apptheme.instructions.md`** — Atualize a lista de constantes na seção "Práticas obrigatórias" se uma nova constante foi adicionada ou removida.
2. **`visual-identity.instructions.md`** — Atualize a tabela de cores principais/semânticas ou tipografia correspondente.

Essa sincronização deve acontecer **na mesma operação** que a edição do `app_theme.dart`, nunca separadamente.

---

### Resumo

| Cenário | Ação |
|---|---|
| Token existe no `AppTheme` | Use diretamente — sem valores inline |
| Token está faltando | Pergunte ao usuário com a mudança proposta antes de implementar |
| Cor / fonte bruta no widget | Substitua pela referência do `AppTheme` |
| `app_theme.dart` foi editado | Atualize `apptheme.instructions.md` e `visual-identity.instructions.md` na mesma operação |