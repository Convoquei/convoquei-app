# Microcopy — Tom de Voz pt-BR

Aplicar em **todos** os textos da UI: labels, mensagens de erro, estados vazios, botões, títulos de modal, toasts.

---

## Três princípios

**Empático.** Reconhece o contexto humano. Voluntários e líderes gerem tempo de outras pessoas — o app deve ser um aliado, não uma burocracia.

**Claro.** Sem jargão técnico. Uma frase, uma ideia. O utilizador não lê — ele escaneia.

**Ação explícita.** Botões dizem exatamente o que vão acontecer. Nunca "OK", "Salvar" genérico ou "Confirmar" sem contexto.

---

## Tabela de substituição

| Evitar | Usar |
|--------|------|
| `Erro ao processar disponibilidade.` | `Não foi possível guardar a sua resposta. Verifique a sua ligação e tente novamente.` |
| `Membro Indisponível` | `João informou que não pode participar neste evento.` |
| `Salvar` (em modal de grupos) | `Atribuir grupos` |
| `Salvar` (em modal de edição) | `Guardar alterações` |
| `Confirmar` (ação destrutiva) | `Sim, remover papel` / `Sim, sair da organização` |
| `OK` | (remover — usar botão com ação específica) |
| `Erro desconhecido.` | `Algo correu mal. Se o problema persistir, tente fechar e abrir o app.` |
| `Carregando...` | `Carregando eventos...` / `Buscando sua agenda` |
| `Nenhum resultado.` | `Nenhum evento encontrado. Crie o primeiro evento da sua organização.` |
| `Sem membros.` | `Ainda não há membros neste grupo. Adicione membros para começar.` |
| `Escala não disponível.` | `A escala deste evento ainda não foi publicada.` |
| `Convite pendente.` | `Você tem um convite de [Nome da Org] esperando pela sua resposta.` |

---

## Padrão de mensagens de erro

Estrutura: **causa provável** + **ação sugerida** + **tom neutro**.

```
Não foi possível [o que falhou].
[Causa provável, se conhecida.]
[Ação sugerida.]
```

Exemplos:
- `Não foi possível carregar os membros. Verifique sua conexão e tente novamente.`
- `Não foi possível enviar o convite. O endereço de e-mail pode já estar em uso.`
- `Não foi possível guardar a escala. Tente novamente em alguns instantes.`

---

## Labels de botões

Regra: verbo + objeto + contexto.

| Contexto | Label correto |
|----------|---------------|
| Salvar edição de papel | `Guardar alterações` |
| Atribuir grupos a membro | `Atribuir a X grupos` / `Atribuir grupos` |
| Remover membro de grupo | `Remover do grupo` |
| Confirmar saída da org | `Sim, sair da organização` |
| Excluir papel | `Apagar papel` |
| Aceitar convite | `Aceitar convite` |
| Recusar convite | `Recusar` |
| Retentar após erro | `Tentar novamente` |
| Criar primeiro evento | `Criar evento` |

---

## Estados vazios

Um estado vazio deve ter: **ilustração / ícone DS** + **título** (o quê) + **descrição** (por quê / o que fazer).

```dart
// Exemplo de estado vazio de eventos
DSText('Nenhum evento ainda', variant: DSTextVariant.titleMedium)
DSText(
  'Crie o primeiro evento da sua organização e convoque sua equipe.',
  variant: DSTextVariant.bodyMedium,
  color: context.colors.textSecondary,
)
DSButton(label: 'Criar evento', icon: Icons.add_rounded, onPressed: _createEvent)
```

---

## Toasts e confirmações

- **Sucesso:** voz ativa, resultado concreto — `Grupos atualizados com sucesso.` / `Papel criado.`
- **Aviso:** orientativo, não alarmista — `Atenção: esta ação não pode ser desfeita.`
- **Erro:** causa + ação — `Não foi possível salvar. Tente novamente.`

---

## Datas e horários

- Formato: `seg, 12 mai` / `12 de maio de 2025` / `às 14h30`
- Nunca formato ISO (2025-05-12) para o utilizador
- Expressões relativas quando próximo: `Hoje`, `Amanhã`, `Em 3 dias`
