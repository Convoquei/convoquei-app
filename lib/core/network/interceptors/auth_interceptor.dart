import 'dart:async';
import 'package:convoquei_app/features/auth/providers/auth_providers.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../storage/token_storage.dart';

/// Handles Bearer token injection and automatic token refresh.
///
/// Uses a [Completer] lock so that concurrent 401 responses only trigger
/// a single refresh cycle — other requests wait and reuse the new token.
class AuthInterceptor extends Interceptor {
  final Dio _dio;
  final TokenStorage _tokenStorage;
  final Ref _ref;

  bool _isRefreshing = false;
  Completer<bool>? _refreshCompleter;

  AuthInterceptor(this._dio, this._tokenStorage, this._ref);

  // -------------------------------------------------------------------------
  // Request — inject Access Token
  // -------------------------------------------------------------------------

  @override
  Future<void> onRequest(
      RequestOptions options,
      RequestInterceptorHandler handler,
      ) async {
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


    await _ref.read(authProvider.notifier).logout();

    handler.next(err);
  }

  // -------------------------------------------------------------------------
  // Private helpers
  // -------------------------------------------------------------------------

  bool _shouldSkip(RequestOptions options) =>
      options.extra['skipAuthInterceptor'] == true;

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
        '/v1/auth/refresh',
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
    } catch (error) {
      _complete(false);

      debugPrint('Error refreshing token: $error');
      return false;
    }
  }

  void _complete(bool result) {
    _refreshCompleter?.complete(result);
    _isRefreshing = false;
    _refreshCompleter = null;
  }
}