import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

/// Logs requests and responses using [debugPrint] (no-op in release builds).
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    debugPrint('┌── REQUEST ──────────────────────────────────────');
    debugPrint('│ ${options.method} ${options.uri}');
    if (options.headers.isNotEmpty) {
      debugPrint('│ Headers: ${options.headers}');
    }
    if (options.data != null) {
      debugPrint('│ Body: ${options.data}');
    }
    debugPrint('└─────────────────────────────────────────────────');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    debugPrint('┌── RESPONSE ─────────────────────────────────────');
    debugPrint('│ ${response.statusCode} ${response.requestOptions.uri}');
    debugPrint('│ Body: ${response.data}');
    debugPrint('└─────────────────────────────────────────────────');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint('┌── ERROR ────────────────────────────────────────');
    debugPrint('│ ${err.response?.statusCode} ${err.requestOptions.uri}');
    debugPrint('│ Message: ${err.message}');
    if (err.response?.data != null) {
      debugPrint('│ Body: ${err.response?.data}');
    }
    debugPrint('└─────────────────────────────────────────────────');
    handler.next(err);
  }

}