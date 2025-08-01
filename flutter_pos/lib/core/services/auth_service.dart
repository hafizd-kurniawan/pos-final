import 'dart:convert';
import '../config/app_config.dart';
import 'api_service.dart';
import 'storage_service.dart';
import '../../shared/models/user_model.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final ApiService _apiService = ApiService();

  // Login
  Future<AuthResult> login(String username, String password) async {
    try {
      final response = await _apiService.post(
        AppConfig.loginEndpoint,
        {
          'username': username,
          'password': password,
        },
        includeAuth: false,
      );

      // Extract token and user data from response
      final token = response['data']['token'] as String?;
      final refreshToken = response['data']['refresh_token'] as String?;
      final userData = response['data']['user'] as Map<String, dynamic>?;

      if (token == null || userData == null) {
        throw Exception('Invalid response format');
      }

      // Save authentication data
      await StorageService.saveToken(token);
      if (refreshToken != null) {
        await StorageService.saveRefreshToken(refreshToken);
      }
      await StorageService.saveUser(userData);

      final user = User.fromJson(userData);
      return AuthResult.success(user, token);
    } on ApiException catch (e) {
      return AuthResult.failure(e.message);
    } catch (e) {
      return AuthResult.failure('Login failed: ${e.toString()}');
    }
  }

  // Register
  Future<AuthResult> register(Map<String, dynamic> userData) async {
    try {
      final response = await _apiService.post(
        '/auth/register',
        userData,
        includeAuth: false,
      );

      final token = response['data']['token'] as String?;
      final refreshToken = response['data']['refresh_token'] as String?;
      final userInfo = response['data']['user'] as Map<String, dynamic>?;

      if (token == null || userInfo == null) {
        throw Exception('Invalid response format');
      }

      await StorageService.saveToken(token);
      if (refreshToken != null) {
        await StorageService.saveRefreshToken(refreshToken);
      }
      await StorageService.saveUser(userInfo);

      final user = User.fromJson(userInfo);
      return AuthResult.success(user, token);
    } on ApiException catch (e) {
      return AuthResult.failure(e.message);
    } catch (e) {
      return AuthResult.failure('Registration failed: ${e.toString()}');
    }
  }

  // Get profile
  Future<User?> getProfile() async {
    try {
      final response = await _apiService.get(AppConfig.profileEndpoint);
      final userData = response['data'] as Map<String, dynamic>?;
      
      if (userData != null) {
        await StorageService.saveUser(userData);
        return User.fromJson(userData);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Refresh token
  Future<bool> refreshToken() async {
    try {
      final refreshToken = await StorageService.getRefreshToken();
      if (refreshToken == null) return false;

      final response = await _apiService.post(
        AppConfig.refreshEndpoint,
        {'refresh_token': refreshToken},
        includeAuth: false,
      );

      final newToken = response['data']['token'] as String?;
      final newRefreshToken = response['data']['refresh_token'] as String?;

      if (newToken != null) {
        await StorageService.saveToken(newToken);
        if (newRefreshToken != null) {
          await StorageService.saveRefreshToken(newRefreshToken);
        }
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Change password
  Future<bool> changePassword(String oldPassword, String newPassword) async {
    try {
      await _apiService.post(
        AppConfig.changePasswordEndpoint,
        {
          'old_password': oldPassword,
          'new_password': newPassword,
        },
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      // Call logout endpoint if available
      await _apiService.post('/auth/logout', {});
    } catch (e) {
      // Ignore errors during logout
    } finally {
      // Clear local data
      await StorageService.clearAuthData();
    }
  }

  // Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final token = await StorageService.getToken();
    return token != null;
  }

  // Get current user
  Future<User?> getCurrentUser() async {
    final userData = await StorageService.getUser();
    if (userData != null) {
      return User.fromJson(userData);
    }
    return null;
  }

  // Check if token is expired and needs refresh
  Future<bool> isTokenExpired() async {
    // This is a simple implementation
    // In a real app, you'd decode the JWT and check the exp claim
    try {
      await _apiService.get(AppConfig.profileEndpoint);
      return false; // Token is valid
    } on ApiException catch (e) {
      if (e.isUnauthorized) {
        return true; // Token is expired
      }
      return false; // Other error, assume token is valid
    } catch (e) {
      return false; // Network error, assume token is valid
    }
  }
}

// Authentication result wrapper
class AuthResult {
  final bool success;
  final User? user;
  final String? token;
  final String? error;

  AuthResult._({
    required this.success,
    this.user,
    this.token,
    this.error,
  });

  factory AuthResult.success(User user, String token) {
    return AuthResult._(
      success: true,
      user: user,
      token: token,
    );
  }

  factory AuthResult.failure(String error) {
    return AuthResult._(
      success: false,
      error: error,
    );
  }
}