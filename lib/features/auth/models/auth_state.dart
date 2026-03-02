enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState {
  final AuthStatus status;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.unknown,
    this.errorMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    String? errorMessage,
  }) => AuthState(
    status: status ?? this.status,
    errorMessage: errorMessage,
  );
}
