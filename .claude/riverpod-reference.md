# Riverpod — Referência Completa

Leia este documento **integralmente** antes de gerar ou modificar qualquer provider.
Estas regras são **obrigatórias e não negociáveis**.

---

## Stack obrigatória

| Obrigatório | Proibido |
|---|---|
| `riverpod_generator` com `@riverpod` | `flutter_hooks`, `HookWidget`, `HookConsumerWidget` |
| `ConsumerWidget` / `ConsumerStatefulWidget` | `useState`, `useEffect`, `useAnimationController` |
| Providers **top-level** | Providers dentro de classes ou funções |
| `ProviderScope` na raiz do app | `ProviderContainer` direto em Flutter |

---

## Importações obrigatórias

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'my_file.g.dart'; // sempre necessário com code generation
```

Após criar ou modificar um provider:
```
dart run build_runner build --delete-conflicting-outputs
```

---

## Como criar providers

### Provider funcional (read-only / sem mutação externa)

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

### Provider de classe (Notifier — com mutação externa)

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
  Future<User?> build() async => null;

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _authService.login(email, password));
  }

  void logout() => state = const AsyncData(null);
}
```

### keepAlive — provider que nunca deve ser destruído

```dart
@Riverpod(keepAlive: true)
ApiClient apiClient(Ref ref) => ApiClient();
```

---

## Families — providers com parâmetros

```dart
@riverpod
Future<User> user(Ref ref, String id) async => api.fetchUser(id);

@riverpod
class UserNotifier extends _$UserNotifier {
  @override
  Future<User> build(String id) async => api.fetchUser(id);

  Future<void> update(String name) async { ... }
}

// Uso
final user = ref.watch(userProvider('123'));
final user2 = ref.watch(userProvider('456')); // independente
```

> Parâmetros **devem** ter `==` e `hashCode` consistentes.
> Nunca passe `List`, `Map` ou objetos mutáveis sem `Equatable`/`==` implementado.

---

## Consumindo providers em widgets

### ConsumerWidget

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

### ConsumerStatefulWidget (lifecycle: initState, dispose, animações)

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

### Consumer inline

```dart
Consumer(
  builder: (context, ref, _) {
    final value = ref.watch(myProvider);
    return Text('$value');
  },
)
```

---

## Usando Ref corretamente

### `ref.watch` — dependências reativas (provoca rebuild)

```dart
// Em providers
@riverpod
bool isEven(Ref ref) {
  final count = ref.watch(counterProvider);
  return count % 2 == 0;
}

// Em widgets — dentro do build()
final user = ref.watch(userProvider('123'));
```

### `ref.read` — ações pontuais (não provoca rebuild)

```dart
// ✅ Correto — dentro de callbacks
ElevatedButton(
  onPressed: () => ref.read(counterProvider.notifier).increment(),
  child: const Text('Incrementar'),
)

// ❌ Nunca substitua ref.watch por ref.read para "otimizar"
```

### `ref.listen` — side-effects (navegação, snackbars)

```dart
ref.listen(authProvider, (previous, next) {
  if (next.value == null) {
    Navigator.of(context).pushReplacementNamed('/login');
  }
});
```

### `select` — ouvir apenas parte do estado

```dart
final name = ref.watch(userProvider.select((u) => u.name));
```

---

## O que NUNCA fazer

### Side-effects na inicialização do provider

```dart
// ❌ ERRADO
@riverpod
Future<void> submitForm(Ref ref) async {
  final form = ref.watch(formProvider);
  await http.post('/submit', body: form.toJson());
}

// ✅ CORRETO — side-effects ficam em métodos do Notifier
@riverpod
class FormNotifier extends _$FormNotifier {
  @override
  FormState build() => FormState.initial();

  Future<void> submit() async {
    state = state.copyWith(isLoading: true);
    await http.post('/submit', body: state.toJson());
    state = state.copyWith(isLoading: false);
  }
}
```

### Chamar métodos no initState

```dart
// ❌ ERRADO
void initState() {
  super.initState();
  ref.read(myProvider).init(); // NUNCA
}

// ✅ CORRETO — inicialização em ação do usuário
ElevatedButton(
  onPressed: () => ref.read(myProvider.notifier).load(),
  child: const Text('Abrir'),
)
```

### Providers para estado efêmero de UI

```dart
// ❌ ERRADO — estado local pertence ao widget
@riverpod
class SelectedTab extends _$SelectedTab {
  @override
  int build() => 0; // use setState
}

// ✅ CORRETO
class _MyState extends ConsumerState<MyWidget> {
  int _selectedTab = 0;
}
```

---

## Lifecycle e dispose

```dart
@riverpod
Stream<int> ticker(Ref ref) {
  final controller = StreamController<int>();
  ref.onDispose(controller.close);
  ref.onCancel(() => print('sem listeners'));
  ref.onResume(() => print('listener voltou'));
  return controller.stream;
}
```

---

## Invalidar e resetar providers

```dart
ref.invalidate(counterProvider);           // reseta (recomputado na próxima leitura)
final newValue = ref.refresh(counterProvider); // reseta e retorna novo valor

ref.invalidate(userProvider);           // invalida toda a family
ref.invalidate(userProvider('123'));    // invalida apenas id='123'
```

---

## Provider Overrides (testes e mocks)

```dart
await tester.pumpWidget(
  ProviderScope(
    overrides: [
      apiClientProvider.overrideWith((ref) => MockApiClient()),
      userProvider('123').overrideWith((ref) => fakeUser),
    ],
    child: const MyApp(),
  ),
);

// Testes unitários
final container = ProviderContainer.test(
  overrides: [apiClientProvider.overrideWith((ref) => MockApiClient())],
);
addTearDown(container.dispose);
```

---

## Retry automático

Por padrão, providers com falha são reexecutados (até 10x, backoff exponencial 200ms → 6.4s).

```dart
Duration? myRetry(int retryCount, Object error) {
  if (retryCount >= 3) return null;
  return Duration(milliseconds: 200 * (1 << retryCount));
}

@Riverpod(retry: myRetry)
Future<Data> myProvider(Ref ref) async => api.fetchData();

// Desabilitar globalmente
ProviderScope(retry: (_, __) => null, child: MyApp())
```

---

## ProviderObserver (debug / analytics)

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

ProviderScope(observers: [AppLogger()], child: MyApp())
```
