---
description: >
  Carregue estas instruções sempre que a tarefa envolver: criar providers, modificar providers
  existentes, revisar código com Riverpod, consumir estado em widgets, ou qualquer operação
  de gerenciamento de estado no projeto Flutter.
applyTo: "**/*.dart"
---

# Riverpod — Instruções para IA

Leia este documento **integralmente** antes de gerar ou modificar qualquer provider.  
Estas regras são **obrigatórias e não negociáveis**.

---

## 1. Stack obrigatória

| Obrigatório | Proibido |
|---|---|
| `riverpod_generator` com `@riverpod` | `flutter_hooks` |
| `ConsumerWidget` / `ConsumerStatefulWidget` | `HookWidget`, `HookConsumerWidget` |
| Providers **top-level** | Providers dentro de classes ou funções |
| `ProviderScope` na raiz do app | `ProviderContainer` direto em Flutter |

> **Hooks são estritamente proibidos neste projeto.**  
> Nunca use: `useState`, `useEffect`, `useAnimationController`, `HookBuilder`, `HookWidget` ou qualquer API do pacote `flutter_hooks`.

---

## 2. Setup obrigatório

### ProviderScope na raiz
```dart
void main() {
  runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
}
```

### Importações corretas
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'my_file.g.dart'; // sempre necessário com code generation
```

---

## 3. Como criar providers

### ✅ Provider funcional (read-only / sem mutação externa)
Use quando o provider apenas lê, computa ou busca dados.

```dart
@riverpod
Future<User> user(Ref ref, String id) async {
  final response = await http.get('https://api.example.com/users/$id');
  return User.fromJson(response.body);
}

@riverpod
String greeting(Ref ref) => 'Hello world';

@riverpod
Stream<int> ticker(Ref ref) async* {
  yield* Stream.periodic(Duration(seconds: 1), (i) => i);
}
```

### ✅ Provider de classe (Notifier — com mutação externa)
Use quando a UI precisa chamar métodos que alteram o estado.

```dart
@riverpod
class Counter extends _$Counter {
  @override
  int build() => 0;

  void increment() => state++;
  void decrement() => state--;
  void reset() => state = 0;
}

@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  Future<User?> build() async {
    return null;
  }

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _authService.login(email, password));
  }

  void logout() => state = const AsyncData(null);
}
```

### ✅ keepAlive — quando o provider nunca deve ser destruído
```dart
@Riverpod(keepAlive: true)
ApiClient apiClient(Ref ref) => ApiClient();
```

---

## 4. Regras de criação

### Providers DEVEM ser top-level
```dart
// ✅ Correto
@riverpod
String example(Ref ref) => 'hello';

// ❌ Errado — dentro de classe
class MyClass {
  final provider = Provider<String>((ref) => 'hello'); // NUNCA
}
```

### NUNCA criar providers sem code generation
```dart
// ❌ Proibido
final myProvider = Provider<String>((ref) => 'hello');
final myFuture = FutureProvider<User>((ref) async => fetchUser());
final myNotifier = NotifierProvider<MyNotifier, int>(MyNotifier.new);

// ✅ Obrigatório
@riverpod
String my(Ref ref) => 'hello';

@riverpod
Future<User> myFuture(Ref ref) async => fetchUser();

@riverpod
class MyNotifier extends _$MyNotifier {
  @override
  int build() => 0;
}
```

---

## 5. Families — providers com parâmetros

```dart
// ✅ Funcional com parâmetro
@riverpod
Future<User> user(Ref ref, String id) async {
  return api.fetchUser(id);
}

// ✅ Notifier com parâmetro
@riverpod
class UserNotifier extends _$UserNotifier {
  @override
  Future<User> build(String id) async {
    return api.fetchUser(id);
  }

  Future<void> update(String name) async { ... }
}

// Uso
final user = ref.watch(userProvider('123'));
final user2 = ref.watch(userProvider('456')); // independente
```

> Parâmetros **devem** ter `==` e `hashCode` consistentes.  
> Nunca passe `List`, `Map` ou objetos mutáveis sem `Equatable`/`==` implementado.

---

## 6. Consumindo providers em widgets

### ConsumerWidget (padrão — equivalente a StatelessWidget)
```dart
class UserCard extends ConsumerWidget {
  const UserCard({super.key, required this.userId});
  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider(userId));

    return user.when(
      data: (u) => Text(u.name),
      loading: () => const CircularProgressIndicator(),
      error: (e, _) => Text('Erro: $e'),
    );
  }
}
```

### ConsumerStatefulWidget (quando precisa de lifecycle do Flutter)
```dart
class MyScreen extends ConsumerStatefulWidget {
  const MyScreen({super.key});

  @override
  ConsumerState<MyScreen> createState() => _MyScreenState();
}

class _MyScreenState extends ConsumerState<MyScreen> {
  @override
  Widget build(BuildContext context) {
    final counter = ref.watch(counterProvider);
    return Text('$counter');
  }
}
```

### Consumer inline (quando não quer subclassificar)
```dart
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final value = ref.watch(myProvider);
        return Text('$value');
      },
    );
  }
}
```

---

## 7. Usando Ref corretamente

### `ref.watch` — para dependências (provoca rebuild)
```dart
// Dentro de providers
@riverpod
bool isEven(Ref ref) {
  final count = ref.watch(counterProvider); // recomputa quando counter muda
  return count % 2 == 0;
}

// Dentro de widgets
final user = ref.watch(userProvider('123'));
```

### `ref.read` — para ações pontuais (NÃO provoca rebuild)
```dart
// ✅ Uso correto — dentro de callbacks
ElevatedButton(
  onPressed: () => ref.read(counterProvider.notifier).increment(),
  child: const Text('Incrementar'),
)

// ❌ Uso errado — para "otimizar" e evitar rebuild
// Nunca substitua ref.watch por ref.read para evitar reconstruções
```

### `ref.listen` — para side-effects (navegação, snackbars, logs)
```dart
@override
Widget build(BuildContext context, WidgetRef ref) {
  ref.listen(authProvider, (previous, next) {
    if (next.value == null) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  });

  return const HomeView();
}
```

### `select` — para ouvir apenas parte do estado
```dart
// Só reconstrói quando o nome muda, ignorando outras propriedades
final name = ref.watch(userProvider.select((u) => u.name));
```

---

## 8. O que NUNCA fazer

### ❌ Side-effects na inicialização do provider
```dart
// ❌ ERRADO — providers são "read", não "write"
@riverpod
Future<void> submitForm(Ref ref) async {
  final form = ref.watch(formProvider);
  await http.post('https://api.com/submit', body: form.toJson());
}

// ✅ CORRETO — side-effects ficam em métodos do Notifier
@riverpod
class FormNotifier extends _$FormNotifier {
  @override
  FormState build() => FormState.initial();

  Future<void> submit() async {
    state = state.copyWith(isLoading: true);
    await http.post('https://api.com/submit', body: state.toJson());
    state = state.copyWith(isLoading: false);
  }
}
```

### ❌ Inicializar providers dentro de widgets
```dart
// ❌ ERRADO
class MyWidget extends ConsumerStatefulWidget { ... }
class _MyWidgetState extends ConsumerState<MyWidget> {
  @override
  void initState() {
    super.initState();
    ref.read(myProvider).init(); // NUNCA
  }
}

// ✅ CORRETO — inicialização em ação do usuário
ElevatedButton(
  onPressed: () {
    ref.read(myProvider.notifier).load();
    Navigator.of(context).push(...);
  },
  child: const Text('Abrir'),
)
```

### ❌ Providers para estado efêmero de UI
```dart
// ❌ ERRADO — estado local pertence ao widget
@riverpod
class SelectedTab extends _$SelectedTab {
  @override
  int build() => 0; // índice de aba selecionada — use setState
}

// ✅ CORRETO — use StatefulWidget ou ConsumerStatefulWidget
class _MyState extends ConsumerState<MyWidget> {
  int _selectedTab = 0;
  ...
}
```

---

## 9. Lifecycle e dispose

```dart
@riverpod
Stream<int> ticker(Ref ref) {
  final controller = StreamController<int>();

  // Registre o dispose — Riverpod chama automaticamente ao destruir
  ref.onDispose(controller.close);

  // onCancel: último listener removido
  ref.onCancel(() => print('sem listeners'));

  // onResume: novo listener após cancelamento
  ref.onResume(() => print('listener voltou'));

  return controller.stream;
}
```

---

## 10. Invalidar e resetar providers

```dart
// Reseta o estado (será recomputado na próxima leitura)
ref.invalidate(counterProvider);

// Reseta e retorna o novo valor imediatamente
final newValue = ref.refresh(counterProvider);

// Invalidar family inteira ou combinação específica
ref.invalidate(userProvider);           // todas as combinações
ref.invalidate(userProvider('123'));    // apenas id='123'
```

---

## 11. Provider Overrides (testes e mocks)

```dart
// Em testes de widget
await tester.pumpWidget(
  ProviderScope(
    overrides: [
      apiClientProvider.overrideWith((ref) => MockApiClient()),
      userProvider('123').overrideWith((ref) => fakeUser),
    ],
    child: const MyApp(),
  ),
);

// Em testes unitários
final container = ProviderContainer.test(
  overrides: [
    apiClientProvider.overrideWith((ref) => MockApiClient()),
  ],
);
addTearDown(container.dispose);
```

---

## 12. Retry automático

Por padrão, providers com falha são reexecutados automaticamente (até 10x, backoff exponencial 200ms → 6.4s).

```dart
// Customizar por provider
Duration? myRetry(int retryCount, Object error) {
  if (retryCount >= 3) return null;
  return Duration(milliseconds: 200 * (1 << retryCount));
}

@Riverpod(retry: myRetry)
Future<Data> myProvider(Ref ref) async => api.fetchData();

// Desabilitar globalmente
ProviderScope(
  retry: (_, __) => null,
  child: MyApp(),
)
```

---

## 13. ProviderObserver (debug / analytics)

```dart
class AppLogger extends ProviderObserver {
  @override
  void didUpdateProvider(
    ProviderObserverContext context,
    Object? previousValue,
    Object? newValue,
  ) {
    print('[Riverpod] ${context.provider} → $newValue');
  }
}

// Registrar no ProviderScope
ProviderScope(
  observers: [AppLogger()],
  child: MyApp(),
)
```

---

## Resumo rápido

| Situação | O que usar |
|---|---|
| Buscar / computar dados | Provider funcional `@riverpod` |
| Mutação / ações externas | Notifier de classe `@riverpod class X extends _$X` |
| Parâmetros no provider | Adicionar params na função/`build()` |
| Escutar mudanças no widget | `ref.watch` |
| Executar ação no botão | `ref.read(x.notifier).metodo()` |
| Side-effect (navegar, dialog) | `ref.listen` |
| Estado local de UI | `setState` no `ConsumerStatefulWidget` |
| Destruir provider | `ref.invalidate` / `ref.refresh` |
| Provider nunca destruído | `@Riverpod(keepAlive: true)` |
| Widget sem lifecycle | `ConsumerWidget` |
| Widget com lifecycle | `ConsumerStatefulWidget` |