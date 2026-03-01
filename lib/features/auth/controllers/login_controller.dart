import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../models/dto/requests/login_request_dto.dart';
import '../models/dto/requests/register_request_dto.dart';
import '../repository/auth_repository.dart';

// ── State ─────────────────────────────────────────────────────────────────────

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState {
  final AuthStatus status;
  final String? errorMessage;

  const AuthState({this.status = AuthStatus.unknown, this.errorMessage});

  AuthState copyWith({AuthStatus? status, String? errorMessage}) => AuthState(
        status: status ?? this.status,
        errorMessage: errorMessage,
      );
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class AuthController extends AsyncNotifier<AuthState> {
  AuthRepository get _repo => ref.read(authRepositoryProvider);

  @override
  Future<AuthState> build() async {
    final hasSession = await _repo.hasValidSession();
    return AuthState(
      status:
          hasSession ? AuthStatus.authenticated : AuthStatus.unauthenticated,
    );
  }

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repo.login(LoginRequestDto(email: email, password: password));
      debugPrint('✅ Logou com sucesso');
      return const AuthState(status: AuthStatus.authenticated);
    }).then(
      (result) => result.hasError
          ? AsyncData(AuthState(
              status: AuthStatus.unauthenticated,
              errorMessage: result.error.toString(),
            ))
          : result,
    );
  }

  Future<void> register(String name, String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repo.register(
        RegisterRequestDto(name: name, email: email, password: password),
      );
      // After registering, log in immediately.
      await _repo.login(LoginRequestDto(email: email, password: password));
      debugPrint('✅ Registrou e logou com sucesso');
      return const AuthState(status: AuthStatus.authenticated);
    }).then(
      (result) => result.hasError
          ? AsyncData(AuthState(
              status: AuthStatus.unauthenticated,
              errorMessage: result.error.toString(),
            ))
          : result,
    );
  }

  Future<void> logout() async {
    await _repo.logout();
    state = const AsyncData(AuthState(status: AuthStatus.unauthenticated));
  }

  /// Called by the AuthInterceptor redirect — tokens were cleared externally.
  void onSessionExpired() {
    state = const AsyncData(AuthState(status: AuthStatus.unauthenticated));
  }
}

// ── Provider ──────────────────────────────────────────────────────────────────

final authControllerProvider =
    AsyncNotifierProvider<AuthController, AuthState>(AuthController.new);

