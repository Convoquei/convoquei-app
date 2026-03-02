import 'user_model.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState {
  final AuthStatus status;
  final String? errorMessage;
  final UserModel? user;

  const AuthState({
    this.status = AuthStatus.unknown,
    this.errorMessage,
    this.user,
  });

  AuthState copyWith({
    AuthStatus? status,
    String? errorMessage,
    UserModel? user,
  }) => AuthState(
    status: status ?? this.status,
    errorMessage: errorMessage,
    user: user ?? this.user,
  );
}
