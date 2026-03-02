import 'package:flutter/foundation.dart';

class AppConstants {
  AppConstants._();

  // --- API ---
  static const String baseUrl = 'http://127.0.0.1:8080/api';

  // --- Timeouts ---
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 20);

  // --- Retry ---
  static const int maxRetries = kDebugMode ? 0 : 3;

  // --- Storage keys ---
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
}

