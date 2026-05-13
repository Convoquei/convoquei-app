# Convoquei — Flutter App

## O que é o Convoquei

Aplicativo mobile para gerenciamento de **organizações**, **equipes** e **eventos**. Centraliza comunicação, disponibilidade e escalas (manuais ou automáticas) em um único ambiente digital.

**Motivação real:** Dor identificada na ICM (Igreja Cristã Maranata), onde semanalmente alguém envia enquetes manualmente, coleta respostas e monta escalas sem histórico — gerando injustiça e sobrecarga.

**Público-alvo:** Líderes de ministérios, coordenadores de equipes voluntárias, organizadores de eventos e membros em geral. Foco inicial em igrejas, escalável para qualquer grupo.

**Palavras-chave da marca:** Organização · Justiça · Transparência · Comunidade · Agilidade · Confiança · Previsibilidade

---

## Stack

| Categoria | Tecnologia |
|---|---|
| Framework | Flutter (stable, 3.x+) |
| Linguagem | Dart |
| Gerenciamento de estado | Riverpod 3.x com `riverpod_generator` + `@riverpod` |
| Navegação | GoRouter 14.x com `ShellRoute` |
| HTTP | Dio 5.x com `dio_smart_retry` |
| Storage | `flutter_secure_storage` (tokens), `shared_preferences` (cache) |
| Backend | API REST Java (repositório separado) |

---

## Instruções Detalhadas

| Arquivo | Quando usar |
|---|---|
| `.claude/rules/design-system.md` | Catálogo do DS: tokens, foundations, components, regras de import e proibições |
| `.claude/rules/ui-patterns.md` | Padrões de UI: AppBar translúcido, inset grouped, bottom sheets, skeletons, paginação |
| `.claude/rules/microcopy.md` | Tom de voz em pt-BR para textos da UI |
| `.claude/rules/brand.md` | Identidade visual: logotipo, cores de marca, tipografia |
| `.claude/riverpod-reference.md` | Providers, Families e lifecycle — leia sob demanda ao criar/modificar providers |

---

## Estrutura de Pastas

```
lib/
├── main.dart                    # Entry point — ProviderScope + locale pt_BR
├── app/
│   ├── app.dart                 # MaterialApp.router raiz
│   ├── router.dart              # GoRouter com ShellRoute + redirect de auth
│   └── routes.dart              # Constantes de rotas (AppRoutes, AppPaths)
├── core/
│   ├── constants/               # app_constants.dart (baseUrl, timeouts), breakpoints
│   ├── models/                  # Modelos base: paginação, StateListPaged
│   ├── network/                 # ApiClient (Dio), BaseRepository, interceptors, exceptions
│   ├── providers/               # Providers globais: tokenStorage, apiClient, navigatorKey
│   ├── services/                # ToastFeedbackService, UserFeedbackService
│   ├── storage/                 # TokenStorage (seguro), UserCacheStorage
│   ├── theme/                   # app_theme.dart — única fonte de verdade visual
│   ├── utils/                   # date_locale_pt.dart
│   └── widgets/                 # 30+ widgets reutilizáveis (ver lista em .claude/componentization.md)
└── features/
    ├── auth/                    # Login, registro, AuthNotifier, TokenStorage
    ├── home/                    # Dashboard: organizações, convites, semana do usuário
    └── organizations/
        ├── organization_shell.dart   # Layout com tabs (mobile) / side rail (desktop)
        ├── shared/              # OrganizationModel, providers compartilhados, org avatar
        ├── events/              # Lista de eventos, criação (wizard 3 etapas), detalhes, disponibilidade
        ├── members/             # Membros, grupos, funções — gestão completa
        ├── scales/              # Escalas (em desenvolvimento)
        ├── settings/            # Configurações, papéis (RBAC), funções de evento
        └── home/                # Tela inicial da organização
```

---

## Navegação (GoRouter)

```
/login                           → LoginPage
/home                            → HomePage (requer auth)
/orgs/:orgId/                    → ShellRoute (OrganizationShell — tabs/side rail persistente)
  home                           → OrgHomePage
  events                         → OrgEventsPage
  events/new                     → OrgCreateEventPage
  events/:eventId                → OrgEventDetailPage
  scales                         → OrgScalesPage
  team                           → OrgMembersPage
  settings                       → OrgSettingsPage
  settings/roles                 → ManageRolesPage
  settings/functions             → ManageFunctionsPage
```

- Auth redirect automático via `authProvider` → `_AuthStateListenable`
- Responsive: bottom tabs (mobile) / NavigationRail (desktop)
- `context.goNamed(...)` para substituir rota; `context.pushNamed(...)` para empilhar

---

## Estado (Riverpod)

### Regra geral
- **Sempre** use `@riverpod` + code generation. Nunca declare providers manualmente.
- Após criar/modificar provider, execute: `dart run build_runner build --delete-conflicting-outputs`
- Hooks (`flutter_hooks`) são **estritamente proibidos**.

### Tipos de provider
| Tipo | Quando usar | Exemplo |
|---|---|---|
| `@riverpod Future<T>` | Queries sem mutação | `findEventDetailsById`, `userOrganizations` |
| `Notifier<T>` | Estado síncrono com mutações | filtros, paginação, listas paginadas |
| `AsyncNotifier<T>` | Operações assíncronas únicas | criar, atualizar, deletar, login |

### Consumo em widgets
- `ConsumerWidget` para widgets sem estado local
- `ConsumerStatefulWidget` para lifecycle (`initState`, `dispose`, animações)
- `ref.watch` no `build` (reativo); `ref.read` em callbacks; `ref.listen` para side-effects

---

## Padrões de Código

### Nomenclatura
- Arquivos: `snake_case.dart`
- Classes: `PascalCase`
- Variáveis/funções: `camelCase`
- Constantes: `kNomeConstante`
- Providers (queries): `find_all_*_provider.dart`, `get_*_provider.dart`
- Providers (mutations): `create_*_provider.dart`, `update_*_provider.dart`, `delete_*_provider.dart`

### Widgets e Páginas
- Páginas: ~100 linhas máximo — orquestram, não implementam
- `StatelessWidget` / `ConsumerWidget` sempre que não houver estado local
- Widgets reutilizáveis → `lib/core/widgets/`
- Widgets acoplados à feature → `lib/features/[feature]/widgets/`

### Tema e Cores
- ✅ `context.colors.primary`, `context.colors.surface`, `context.textStyles.titleLarge`
- ❌ `Color(0xFF1D4ED8)` hardcoded, `TextStyle(fontSize: 16)` cru
- Todos os tokens estão em `.claude/rules/design-system.md` — consultar antes de implementar qualquer UI
- Inputs (`TextField`/`TextFormField`/`DropdownButtonFormField`) herdam `inputDecorationTheme` do `DSTheme` automaticamente; **não criar wrappers customizados** de input

### Domínio
- Referencie sempre o **membro** (`OrganizationMember`), nunca o usuário diretamente
- Permissões via bitmask — nunca strings literais na camada de apresentação
- Para histórico de participação, use os snapshots (`display_name`, `avatar_url`) — nunca o nome atual do usuário

---

## O que nunca fazer

- Commitar arquivos `.env` ou chaves de API
- Hardcodar URLs de API (use `app_constants.dart`)
- Hardcodar cores fora do `AppTheme`
- Colocar lógica de negócio em widgets
- Ignorar estados de loading e erro nas telas
- Usar `flutter_hooks` (`useState`, `useEffect`, `HookWidget`, etc.)
- Criar providers sem `@riverpod` (sem code generation)
- Declarar providers dentro de classes ou funções — sempre top-level
- Executar side-effects na inicialização de providers — use métodos do Notifier
