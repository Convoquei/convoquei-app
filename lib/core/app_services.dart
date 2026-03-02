import 'constants/app_constants.dart';
import 'network/api_client.dart';
import 'storage/token_storage.dart';
import 'storage/user_cache_storage.dart';
import '../features/auth/repository/auth_repository.dart';
import '../features/auth/repository/user_repository.dart';

class AppServices {
  AppServices._();

  static final AppServices instance = AppServices._();

  late final TokenStorage tokenStorage = TokenStorage();

  late final UserCacheStorage userCacheStorage = UserCacheStorage();

  late final ApiClient apiClient = ApiClient(
    tokenStorage: tokenStorage,
    baseUrl: AppConstants.baseUrl,
  );

  late final AuthRepository authRepository = AuthRepository(
    apiClient: apiClient,
    tokenStorage: tokenStorage,
  );

  late final UserRepository userRepository = UserRepository(
    apiClient: apiClient,
    cache: userCacheStorage,
  );
}

