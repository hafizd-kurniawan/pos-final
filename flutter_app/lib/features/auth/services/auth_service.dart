import '../../core/services/api_service.dart';
import '../../core/constants/api_constants.dart';
import '../../shared/models/app_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final ApiService _apiService = ApiService();

  Future<ApiResponse<AuthResponse>> login({
    required String username,
    required String password,
  }) async {
    final response = await _apiService.post<AuthResponse>(
      ApiConstants.login,
      body: {
        'username': username,
        'password': password,
      },
      fromJson: (json) => AuthResponse.fromJson(json),
    );

    // Store token if login successful
    if (response.isSuccess && response.data != null) {
      await _apiService.setToken(response.data!.token);
    }

    return response;
  }

  Future<ApiResponse<User>> getProfile() async {
    return await _apiService.get<User>(
      ApiConstants.profile,
      fromJson: (json) => User.fromJson(json),
    );
  }

  Future<ApiResponse<void>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    return await _apiService.post<void>(
      ApiConstants.changePassword,
      body: {
        'current_password': currentPassword,
        'new_password': newPassword,
      },
    );
  }

  Future<void> logout() async {
    await _apiService.clearToken();
  }

  Future<bool> isLoggedIn() async {
    await _apiService.init();
    // Check if token exists in storage
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token') != null;
  }
}