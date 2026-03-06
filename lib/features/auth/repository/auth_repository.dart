import '../../../core/network/api_client.dart';
import '../../../core/storage/token_storage.dart';
import '../models/dto/requests/login_request_dto.dart';
import '../models/dto/responses/login_response_dto.dart';
import '../models/dto/requests/register_request_dto.dart';
import '../models/dto/responses/register_response_dto.dart';

class AuthRepository {
  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  const AuthRepository({
    required ApiClient apiClient,
    required TokenStorage tokenStorage,
  }) : _apiClient = apiClient,
       _tokenStorage = tokenStorage;

  Future<LoginResponseDto> login(LoginRequestDto request) async {
    final data = await _apiClient.post<Map<String, dynamic>>(
      '/v1/auth/login',
      data: request.toJson(),
    );
    final dto = LoginResponseDto.fromJson(data);
    await _tokenStorage.saveTokens(dto.accessToken, dto.refreshToken);
    return dto;
  }

  Future<RegisterResponseDto> register(RegisterRequestDto request) async {
    final data = await _apiClient.post<Map<String, dynamic>>(
      '/v1/auth/register',
      data: request.toJson(),
    );
    return RegisterResponseDto.fromJson(data);
  }

  Future<void> logout() async {
    await _tokenStorage.clear();
  }

  Future<bool> hasValidSession() async {
    _tokenStorage.clear();

    final token = await _tokenStorage.getAccessToken();

    _tokenStorage.debugPrintTokens();

    return token != null && token.isNotEmpty;
  }
}

