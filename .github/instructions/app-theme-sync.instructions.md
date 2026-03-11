---
description: Use estas instruções sempre que o arquivo app_theme.dart for criado ou modificado.
applyTo: 'lib/core/theme/app_theme.dart'
---

## Sincronização ao Editar o AppTheme

Toda vez que `app_theme.dart` for modificado, **atualize também** os arquivos de instruções abaixo na mesma operação, refletindo exatamente o que mudou:

### Arquivos que devem ser mantidos em sincronia

| Arquivo | O que atualizar |
|---|---|
| `.github/instructions/apptheme.instructions.md` | Lista de constantes em "Práticas obrigatórias" (cores, fontes, componentes) |
| `.github/instructions/visual-identity.instructions.md` | Tabelas de cores principais, cores semânticas e tipografia |

### Regras por tipo de mudança

- **Nova constante de cor adicionada** → Adicione-a nas tabelas de ambos os arquivos acima, com nome, valor hex e descrição de uso.
- **Constante removida ou renomeada** → Remova ou renomeie a entrada correspondente em ambos os arquivos. Nunca deixe referências a constantes que não existem mais.
- **Novo estilo de texto adicionado** → Documente em `apptheme.instructions.md` sob "Tipografia" e em `visual-identity.instructions.md` sob "Tipografia".
- **Novo tema de componente adicionado** (ex: `inputDecorationTheme`) → Adicione em `apptheme.instructions.md` sob "Estilos de componentes".

### Exemplo

Se `static const successColor = Color(0xFF10B981)` for adicionado ao `AppTheme`:

1. Em `apptheme.instructions.md`, adicione `AppTheme.successColor` na lista de constantes de cores.
2. Em `visual-identity.instructions.md`, mova `successColor` da tabela "Cores semânticas propostas" para a tabela "já existem no AppTheme", com hex `#10B981` e uso correspondente.

> **Nunca** edite `app_theme.dart` sem sincronizar os arquivos de instruções na mesma operação.
