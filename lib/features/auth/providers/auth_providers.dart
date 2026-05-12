import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/exceptions/api_exception.dart';
import '../../../core/providers/providers.dart';
import '../models/auth_state.dart';
import '../models/dto/requests/login_request_dto.dart';
import '../models/dto/requests/register_request_dto.dart';
import '../models/user_model.dart';
import '../repository/auth_repository.dart';
import '../repository/user_repository.dart';

// ── Repository providers ────────────────────────────────────────────────────

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(
    apiClient: ref.watch(apiClientProvider),
    tokenStorage: ref.watch(tokenStorageProvider),
  ),
);

final userRepositoryProvider = Provider<UserRepository>(
  (ref) => UserRepository(
    apiClient: ref.watch(apiClientProvider),
  ),
);

// ── Auth state ──────────────────────────────────────────────────────────────

final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    _init();
    return const AuthState(); // status == unknown
  }

  AuthRepository get _repo => ref.read(authRepositoryProvider);
  UserRepository get _userRepo => ref.read(userRepositoryProvider);

  Future<UserModel?> _fetchProfile() async {
    try {
      return await _userRepo.getProfile();
    } catch (_) {
      return null;
    }
  }

  Future<void> _init() async {
    final hasSession = await _repo.hasValidSession();
    if (!hasSession) {


      state = const AuthState(status: AuthStatus.unauthenticated);
      return;
    }

    final user = await _fetchProfile();
    if (user == null) {
      await _repo.logout();
      state = const AuthState(status: AuthStatus.unauthenticated);
      return;
    }

    state = AuthState(status: AuthStatus.authenticated, user: user);
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(errorMessage: null, isLoggingIn: true);

    try {
      await _repo.login(LoginRequestDto(email: email, password: password));

      final user = await _fetchProfile();
      if (user == null) {
        await _repo.logout();
        state = const AuthState(
          status: AuthStatus.unauthenticated,
          errorMessage: 'Não foi possível carregar o perfil. Tente novamente.',
        );
        return;
      }

      state = AuthState(status: AuthStatus.authenticated, user: user);
    } catch (e) {
      state = AuthState(
        status: AuthStatus.unauthenticated,
        errorMessage: _buildErrorMessage(e),
      );
    }
  }

  Future<void> register(String name, String email, String password) async {
    state = state.copyWith(errorMessage: null, isRegistering: true);

    try {
      await _repo.register(
        RegisterRequestDto(name: name, email: email, password: password),
      );
      await _repo.login(LoginRequestDto(email: email, password: password));

      final user = await _fetchProfile();
      if (user == null) {
        await _repo.logout();
        state = const AuthState(
          status: AuthStatus.unauthenticated,
          errorMessage: 'Não foi possível carregar o perfil. Tente novamente.',
        );
        return;
      }

      state = AuthState(status: AuthStatus.authenticated, user: user);
    } catch (e) {
      state = AuthState(
        status: AuthStatus.unauthenticated,
        errorMessage: _buildErrorMessage(e),
      );
    }
  }

  Future<void> logout() async {
    await _repo.logout();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  Future<void> refreshProfile() async {
    final user = await _fetchProfile();
    if (user != null) {
      state = state.copyWith(user: user);
    }
  }

  String _buildErrorMessage(Object e) =>
      e is ApiException
          ? e.userMessage
          : 'Ocorreu um erro inesperado. Tente novamente mais tarde.';
}




