import 'dart:async';
import 'package:dio/dio.dart';
import '../../storage/token_storage.dart';

/// Handles Bearer token injection and automatic token refresh.
///
/// Uses a [Completer] lock so that concurrent 401 responses only trigger
/// a single refresh cycle — other requests wait and reuse the new token.
class AuthInterceptor extends Interceptor {
  final Dio _dio;
  final TokenStorage _tokenStorage;

  bool _isRefreshing = false;
  Completer<bool>? _refreshCompleter;

  AuthInterceptor(this._dio, this._tokenStorage);

  // -------------------------------------------------------------------------
  // Request — inject Access Token
  // -------------------------------------------------------------------------

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip auth header when explicitly opted-out or for the refresh endpoint.
    if (_shouldSkip(options)) {
      handler.next(options);
      return;
    }

    final token = await _tokenStorage.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    handler.next(options);
  }

  // -------------------------------------------------------------------------
  // Error — intercept 401 and attempt refresh
  // -------------------------------------------------------------------------

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode != 401 || _shouldSkip(err.requestOptions)) {
      handler.next(err);
      return;
    }

    final refreshed = await _refresh();

    if (refreshed) {
      // Re-issue the original request with the new token.
      try {
        final newToken = await _tokenStorage.getAccessToken();
        err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
        final response = await _dio.fetch(err.requestOptions);
        handler.resolve(response);
      } catch (e) {
        handler.next(err);
      }
      return;
    }

    // Refresh failed — clear tokens so the UI can redirect to login.
    await _tokenStorage.clear();
    handler.next(err);
  }

  // -------------------------------------------------------------------------
  // Private helpers
  // -------------------------------------------------------------------------

  bool _shouldSkip(RequestOptions options) =>
      options.extra['skipAuthInterceptor'] == true ||
      options.path.contains('/auth/refresh');

  /// Ensures only one refresh request runs at a time.
  /// Concurrent callers await the same [Completer].
  Future<bool> _refresh() async {
    if (_isRefreshing) {
      return _refreshCompleter!.future;
    }

    _isRefreshing = true;
    _refreshCompleter = Completer<bool>();

    try {
      final refreshToken = await _tokenStorage.getRefreshToken();
      if (refreshToken == null) {
        _complete(false);
        return false;
      }

      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
        options: Options(extra: {'skipAuthInterceptor': true}),
      );

      final data = response.data;
      if (data == null) {
        _complete(false);
        return false;
      }

      await _tokenStorage.saveTokens(
        data['accessToken'] as String,
        data['refreshToken'] as String,
      );

      _complete(true);
      return true;
    } catch (_) {
      _complete(false);
      return false;
    }
  }

  void _complete(bool result) {
    _refreshCompleter?.complete(result);
    _isRefreshing = false;
    _refreshCompleter = null;
  }
}