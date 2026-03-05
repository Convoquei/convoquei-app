import 'package:convoquei_app/core/network/api_client.dart';

abstract class BaseRepository {
  final ApiClient _apiClient;

  const BaseRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  ApiClient get apiClient => _apiClient;
}