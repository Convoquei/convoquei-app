# Convoquei – Domínio e Conceitos

## Conceitos Principais

Entender esses conceitos é essencial para nomear variáveis, widgets, rotas, providers e lógica de estado de forma consistente.

### Organização
Estrutura principal do sistema. Qualquer usuário pode criar uma organização e se torna seu administrador inicial.
- Possui identidade própria (nome, foto)
- Funciona de forma independente: membros, eventos e escalas são isolados por organização
- Um usuário pode pertencer a múltiplas organizações simultaneamente

### Membro (`OrganizationMember`)
Representa o vínculo de um usuário com uma organização.
- Todo ator dentro de uma organização é sempre referenciado como **membro**, nunca como usuário diretamente
- Membros removidos permanecem no histórico com status `inactive` — nunca são excluídos do histórico visual

### Papéis e Permissões
Sistema flexível de papéis por organização.
- Permissões são calculadas via **bitmask** — nunca compare permissões com strings literais
- Um membro pode ter múltiplos papéis simultaneamente
- Papéis do sistema (`is_system = true`) não podem ser editados pelo usuário

### Grupos de Membros (`OrganizationGroup`)
Agrupamentos internos para segmentar membros (ex.: Músicos, Vocal, Sonoplastia, Recepção).
- Um membro pode pertencer a um ou mais grupos
- Grupos determinam restrições de escalação e filtros de disponibilidade em eventos

### Evento (`OrganizationEvent`)
Atividade realizada dentro de uma organização (culto, ensaio, reunião, apresentação, treinamento, etc.).

**Ciclo de vida (status):**
`Aguardando Escalação` → `Escala Fechada` → `Em Andamento` → `Finalizado` | `Cancelado`

**Modos de escalação:**
- `Manual`: disponibilidade registrada não implica escala; um responsável aprova e inclui o participante
- `Automático`: ao informar disponibilidade, o participante é automaticamente escalado

### Participante do Evento
Cada participante possui:
- `availability_status`: `available` | `unavailable` | `not_answered`
- Snapshots de `display_name` e `avatar_url` no momento do evento — use-os para exibir histórico; nunca busque o nome atual do usuário para dados passados

### Recorrência (`OrganizationEventSchedule`)
Regra de repetição que gera eventos automaticamente. Não é um evento — é uma configuração.
- Tipos: `daily`, `weekly`, `monthly_cycle`, `unique`
- Eventos gerados herdam os parâmetros da recorrência (modo de escalação, bloqueio de disponibilidade etc.)

---

## Diretrizes de Comportamento no Código

- Ao referenciar quem realizou uma ação, use sempre o **membro** (`OrganizationMember`), nunca o usuário diretamente
- Ao exibir histórico de participação, use os snapshots de nome e avatar — nunca busque o nome atual
- Ao remover um membro da UI, reflita o status `inactive` — nunca remova o registro do histórico visual
- Permissões são calculadas via bitmask — nunca use strings para comparar permissões na camada de apresentação
- Eventos gerados por recorrências herdam os parâmetros da recorrência — reflita isso nos labels e no estado da UI
