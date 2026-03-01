import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'network/api_client.dart';
import 'storage/token_storage.dart';
import '../features/auth/repository/auth_repository.dart';
import '../features/auth/repository/user_repository.dart';

// ── Storage ──────────────────────────────────────────────────────────────────

/// Singleton [TokenStorage] backed by flutter_secure_storage.
final tokenStorageProvider = Provider<TokenStorage>((_) => TokenStorage());

// ── Network ───────────────────────────────────────────────────────────────────

/// Singleton [ApiClient] wired with [TokenStorage].
final apiClientProvider = Provider<ApiClient>(
  (ref) => ApiClient(
    tokenStorage: ref.watch(tokenStorageProvider),
    baseUrl: 'http://localhost:8080',
  ),
);

// ── Auth ──────────────────────────────────────────────────────────────────────

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(
    apiClient: ref.watch(apiClientProvider),
    tokenStorage: ref.watch(tokenStorageProvider),
  ),
);

// ── User ──────────────────────────────────────────────────────────────────────

final userRepositoryProvider = Provider<UserRepository>(
  (ref) => UserRepository(apiClient: ref.watch(apiClientProvider)),
);
