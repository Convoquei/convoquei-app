import 'user_model.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState {
  final AuthStatus status;
  final String? errorMessage;
  final UserModel? user;
  final bool isLoggingIn;
  final bool isRegistering;

  const AuthState({
    this.status = AuthStatus.unknown,
    this.errorMessage,
    this.user,
    this.isLoggingIn = false,
    this.isRegistering = false,
  });

  AuthState copyWith({
    AuthStatus? status,
    String? errorMessage,
    UserModel? user,
    bool? isLoggingIn,
    bool? isRegistering,
  }) => AuthState(
    status: status ?? this.status,
    errorMessage: errorMessage,
    user: user ?? this.user,
    isLoggingIn: isLoggingIn ?? this.isLoggingIn,
    isRegistering: isRegistering ?? this.isRegistering,
  );
}
