import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:flutter/foundation.dart';

import '../constants/app_constants.dart';
import 'exceptions/api_exception.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/logging_interceptor.dart';
import 'models/problem_details.dart';
import '../storage/token_storage.dart';

class ApiClient {
  final Dio _dio;

  ApiClient._(this._dio);

  factory ApiClient({required TokenStorage tokenStorage, String? baseUrl}) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl ?? AppConstants.baseUrl,
        connectTimeout: AppConstants.connectTimeout,
        receiveTimeout: AppConstants.receiveTimeout,
        sendTimeout: AppConstants.sendTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    final authInterceptor = AuthInterceptor(dio, tokenStorage);
    dio.interceptors.add(authInterceptor);

    dio.interceptors.add(
      RetryInterceptor(
        dio: dio,
        logPrint: debugPrint,
        retries: AppConstants.maxRetries,
        retryDelays: const [
          Duration(seconds: 1),
          Duration(seconds: 2),
          Duration(seconds: 4),
        ],
        // Only retry on network-level failures and 5xx — NOT on 4xx.
        retryEvaluator: (error, attempt) =>
        error.type == DioExceptionType.connectionTimeout ||
            error.type == DioExceptionType.receiveTimeout ||
            error.type == DioExceptionType.sendTimeout ||
            error.type == DioExceptionType.connectionError ||
            (error.response?.statusCode != null &&
                error.response!.statusCode! >= 500),
      ),
    );

    if (kDebugMode) {
      dio.interceptors.add(LoggingInterceptor());
    }

    return ApiClient._(dio);
  }

  Future<T> get<T>(String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    final response = await _dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
    );
    return _handleResponse<T>(response);
  }

  Future<T> post<T>(String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    final response = await _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
    return _handleResponse<T>(response);
  }

  Future<T> put<T>(String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    final response = await _dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
    return _handleResponse<T>(response);
  }

  Future<T> patch<T>(String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    final response = await _dio.patch<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
    return _handleResponse<T>(response);
  }

  Future<void> delete(String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    final response = await _dio.delete<void>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
    _handleResponse<void>(response);
  }

  T _handleResponse<T>(Response<T> response) {
    final statusCode = response.statusCode ?? 0;

    if (statusCode >= 200 && statusCode < 300) {
      return response.data as T;
    }

    ProblemDetails? problem;
    final body = response.data;
    if (body is Map<String, dynamic>) {
      try {
        problem = ProblemDetails.fromJson(body);
      } catch (_) {
        // If parsing fails, proceed without ProblemDetails.
      }
    }

    final fallbackMessage =
        problem?.firstError ?? 'Erro desconhecido (HTTP $statusCode)';

    throw switch (statusCode) {
      400 => BadRequestException(message: fallbackMessage, problem: problem),
      401 => UnauthorizedException(problem: problem),
      403 => ForbiddenException(problem: problem),
      404 => NotFoundException(problem: problem),
      409 => ConflictException(message: fallbackMessage, problem: problem),
      422 => UnprocessableException(message: fallbackMessage, problem: problem),
      _ when statusCode >= 500 =>
          ServerException(
            statusCode: statusCode,
            problem: problem,
          ),
      _ =>
          UnknownApiException(
            message: fallbackMessage,
            statusCode: statusCode,
            problem: problem,
          ),
    };
  }
}
