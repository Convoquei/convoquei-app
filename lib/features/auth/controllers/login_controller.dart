import '../../../core/app_services.dart';
import '../../../core/loading_controller.dart';
import '../models/auth_state.dart';
import '../models/dto/requests/login_request_dto.dart';
import '../models/dto/requests/register_request_dto.dart';
import '../repository/auth_repository.dart';

class AuthController extends LoadingController {
  final AuthRepository _repo;

  AuthController() : _repo = AppServices.instance.authRepository {
    _init();
  }

  AuthState _state = const AuthState();
  bool isInitializing = false;
  bool isLoggingIn = false;
  bool isRegistering = false;

  AuthState get state => _state;

  void _setState(AuthState next) {
    _state = next;
    notifyListeners();
  }

  Future<void> _init() async {
    await run(
      () async {
        final hasSession = await _repo.hasValidSession();
        _setState(
          AuthState(
            status: hasSession
                ? AuthStatus.authenticated
                : AuthStatus.unauthenticated,
          ),
        );
      },
      loading: (v) => isInitializing = v,
    );
    if (error != null) {
      _setState(const AuthState(status: AuthStatus.unauthenticated));
    }
  }

  Future<void> login(String email, String password) async {
    _setState(_state.copyWith(errorMessage: null));
    await run(
      () async {
        await _repo.login(LoginRequestDto(email: email, password: password));

        _setState(const AuthState(status: AuthStatus.authenticated));
      },
      loading: (v) => isLoggingIn = v,
    );
    if (error != null) {
      _setState(
        AuthState(
          status: AuthStatus.unauthenticated,
          errorMessage: buildErrorFetchAPI(error),
        ),
      );
    }
  }

  Future<void> register(String name, String email, String password) async {
    _setState(_state.copyWith(errorMessage: null));
    await run(
      () async {
        await _repo.register(
          RegisterRequestDto(name: name, email: email, password: password),
        );

        await _repo.login(LoginRequestDto(email: email, password: password));

        _setState(const AuthState(status: AuthStatus.authenticated));
      },
      loading: (v) => isRegistering = v,
    );
    if (error != null) {
      _setState(
        AuthState(
          status: AuthStatus.unauthenticated,
          errorMessage: buildErrorFetchAPI(error),
        ),
      );
    }
  }

  Future<void> logout() async {
    await _repo.logout();
    await AppServices.instance.userRepository.clearCache();
    _setState(const AuthState(status: AuthStatus.unauthenticated));
  }
}
