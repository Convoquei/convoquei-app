import 'dart:io';
import 'package:flutter/foundation.dart';

class AppConstants {
  AppConstants._();

  static const bool _isProduction = bool.fromEnvironment('dart.vm.product');

  static String get baseUrl {
    if (_isProduction) {
      return 'https://api.convoquei.com.br';
    }

    if (kIsWeb) {
      return 'http://localhost:8080/api';
    }

    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8080/api';
    }

    return 'http://127.0.0.1:8080/api';
  }

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