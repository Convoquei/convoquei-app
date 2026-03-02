import '../../../core/network/api_client.dart';
import '../../../core/storage/user_cache_storage.dart';
import '../models/user_model.dart';

class UserRepository {
  final ApiClient _apiClient;
  final UserCacheStorage _cache;

  const UserRepository({
    required ApiClient apiClient,
    required UserCacheStorage cache,
  })  : _apiClient = apiClient,
        _cache = cache;

  /// Returns the cached profile immediately (if available) while fetching a
  /// fresh copy from the server in the background (stale-while-revalidate).
  ///
  /// If there is no cache and the request fails, the exception propagates.
  Future<UserModel> getProfile() async {
    final cached = await _cache.load();

    if (cached != null) {
      // Refresh in background — ignore errors silently.
      _fetchAndCache().ignore();
      return cached;
    }

    // No cache: fetch, persist, and return.
    return _fetchAndCache();
  }

  Future<UserModel> _fetchAndCache() async {
    final data = await _apiClient.get<Map<String, dynamic>>(
      '/v1/users/me/profile',
    );
    final user = UserModel.fromJson(data);
    await _cache.save(user);
    return user;
  }

  /// Clears the persisted profile cache (call on logout).
  Future<void> clearCache() => _cache.clear();
}
