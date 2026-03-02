import '../../../core/app_services.dart';
import '../../../core/loading_controller.dart';
import '../models/auth_state.dart';
import '../models/dto/requests/login_request_dto.dart';
import '../models/dto/requests/register_request_dto.dart';
import '../models/user_model.dart';
import '../repository/auth_repository.dart';
import '../repository/user_repository.dart';

class AuthController extends LoadingController {
  final AuthRepository _repo;
  final UserRepository _userRepo;

  AuthController()
      : _repo = AppServices.instance.authRepository,
        _userRepo = AppServices.instance.userRepository {
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

  /// Fetches the profile and returns it, or null if the request fails.
  Future<UserModel?> _fetchProfile() async {
    try {
      return await _userRepo.getProfile();
    } catch (_) {
      return null;
    }
  }

  Future<void> _init() async {
    await run(
      () async {
        final hasSession = await _repo.hasValidSession();
        if (!hasSession) {
          _setState(const AuthState(status: AuthStatus.unauthenticated));
          return;
        }

        final user = await _fetchProfile();
        if (user == null) {
          // Session exists but profile fetch failed — treat as unauthenticated.
          await _repo.logout();
          _setState(const AuthState(status: AuthStatus.unauthenticated));
          return;
        }

        _setState(AuthState(status: AuthStatus.authenticated, user: user));
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

        final user = await _fetchProfile();
        if (user == null) {
          await _repo.logout();
          _setState(
            const AuthState(
              status: AuthStatus.unauthenticated,
              errorMessage: 'Não foi possível carregar o perfil. Tente novamente.',
            ),
          );
          return;
        }

        _setState(AuthState(status: AuthStatus.authenticated, user: user));
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

        final user = await _fetchProfile();
        if (user == null) {
          await _repo.logout();
          _setState(
            const AuthState(
              status: AuthStatus.unauthenticated,
              errorMessage: 'Não foi possível carregar o perfil. Tente novamente.',
            ),
          );
          return;
        }

        _setState(AuthState(status: AuthStatus.authenticated, user: user));
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
    _setState(const AuthState(status: AuthStatus.unauthenticated));
  }
}
