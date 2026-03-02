import '../../../core/network/api_client.dart';
import '../models/user_model.dart';

class UserRepository {
  final ApiClient _apiClient;

  const UserRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<UserModel> getProfile() async {
    final data = await _apiClient.get<Map<String, dynamic>>(
      '/v1/users/me/profile',
    );
    return UserModel.fromJson(data);
  }
}
