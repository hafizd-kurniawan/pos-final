import 'dart:convert';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../constants/app_constants.dart';
import 'api_service.dart';
import 'storage_service.dart';
import '../../shared/models/user_model.dart';

class AuthService {
  final ApiService _apiService;
  final StorageService _storageService;
  
  AuthService(this._apiService, this._storageService);
  
  // Check if user is authenticated
  bool get isAuthenticated {
    final token = _storageService.getToken();
    if (token == null || token.isEmpty) return false;
    
    try {
      return !JwtDecoder.isExpired(token);
    } catch (e) {
      return false;
    }
  }
  
  // Get current user
  User? get currentUser {
    final userData = _storageService.getUser();
    return userData != null ? User.fromJson(userData) : null;
  }
  
  // Get current user role
  String? get currentUserRole {
    return _storageService.getUserRole();
  }
  
  // Check if current user has specific role
  bool hasRole(String role) {
    return currentUserRole == role;
  }
  
  // Check if current user is admin
  bool get isAdmin => hasRole(AppConstants.roleAdmin);
  
  // Check if current user is kasir
  bool get isKasir => hasRole(AppConstants.roleKasir);
  
  // Check if current user is mekanik
  bool get isMekanik => hasRole(AppConstants.roleMekanik);
  
  // Check if current user is admin or kasir
  bool get isAdminOrKasir => isAdmin || isKasir;
  
  // Login
  Future<AuthResult> login(String username, String password) async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        '/auth/login',
        body: {
          'username': username,
          'password': password,
        },
      );
      
      if (response.isSuccess && response.rawData != null) {
        final data = response.rawData!['data'] as Map<String, dynamic>;
        final token = data['token'] as String;
        final refreshToken = data['refresh_token'] as String?;
        final userData = data['user'] as Map<String, dynamic>;
        
        // Store tokens and user data
        await _storageService.saveToken(token);
        if (refreshToken != null) {
          await _storageService.saveRefreshToken(refreshToken);
        }
        await _storageService.saveUser(userData);
        await _storageService.saveUserRole(userData['role'] as String);
        
        // Set token in API service
        _apiService.setAuthToken(token);
        
        return AuthResult.success(User.fromJson(userData));
      } else {
        return AuthResult.error(response.error ?? 'Login failed');
      }
    } catch (e) {
      return AuthResult.error('Login error: $e');
    }
  }
  
  // Register
  Future<AuthResult> register({
    required String username,
    required String email,
    required String password,
    required String fullName,
    String? phone,
    required String role,
  }) async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        '/auth/register',
        body: {
          'username': username,
          'email': email,
          'password': password,
          'full_name': fullName,
          if (phone != null) 'phone': phone,
          'role': role,
        },
      );
      
      if (response.isSuccess && response.rawData != null) {
        final data = response.rawData!['data'] as Map<String, dynamic>;
        final token = data['token'] as String;
        final refreshToken = data['refresh_token'] as String?;
        final userData = data['user'] as Map<String, dynamic>;
        
        // Store tokens and user data
        await _storageService.saveToken(token);
        if (refreshToken != null) {
          await _storageService.saveRefreshToken(refreshToken);
        }
        await _storageService.saveUser(userData);
        await _storageService.saveUserRole(userData['role'] as String);
        
        // Set token in API service
        _apiService.setAuthToken(token);
        
        return AuthResult.success(User.fromJson(userData));
      } else {
        return AuthResult.error(response.error ?? 'Registration failed');
      }
    } catch (e) {
      return AuthResult.error('Registration error: $e');
    }
  }
  
  // Refresh token
  Future<bool> refreshToken() async {
    try {
      final refreshToken = _storageService.getRefreshToken();
      if (refreshToken == null) return false;
      
      final response = await _apiService.post<Map<String, dynamic>>(
        '/auth/refresh',
        body: {'refresh_token': refreshToken},
      );
      
      if (response.isSuccess && response.rawData != null) {
        final data = response.rawData!['data'] as Map<String, dynamic>;
        final newToken = data['token'] as String;
        final newRefreshToken = data['refresh_token'] as String?;
        
        // Update stored tokens
        await _storageService.saveToken(newToken);
        if (newRefreshToken != null) {
          await _storageService.saveRefreshToken(newRefreshToken);
        }
        
        // Update token in API service
        _apiService.setAuthToken(newToken);
        
        return true;
      }
      
      return false;
    } catch (e) {
      return false;
    }
  }
  
  // Get user profile
  Future<User?> getProfile() async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        '/auth/profile',
      );
      
      if (response.isSuccess && response.rawData != null) {
        final userData = response.rawData!['data'] as Map<String, dynamic>;
        final user = User.fromJson(userData);
        
        // Update stored user data
        await _storageService.saveUser(userData);
        await _storageService.saveUserRole(userData['role'] as String);
        
        return user;
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }
  
  // Change password
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        '/auth/change-password',
        body: {
          'current_password': currentPassword,
          'new_password': newPassword,
        },
      );
      
      return response.isSuccess;
    } catch (e) {
      return false;
    }
  }
  
  // Logout
  Future<void> logout() async {
    try {
      // Clear stored data
      await _storageService.clearAll();
      
      // Clear token from API service
      _apiService.clearAuthToken();
    } catch (e) {
      // Still clear local data even if API call fails
      await _storageService.clearAll();
      _apiService.clearAuthToken();
    }
  }
  
  // Initialize auth state (call on app start)
  Future<void> initializeAuth() async {
    final token = _storageService.getToken();
    if (token != null && !JwtDecoder.isExpired(token)) {
      _apiService.setAuthToken(token);
      
      // Check if token needs refresh
      if (JwtDecoder.getRemainingTime(token).inMinutes < 
          AppConstants.tokenRefreshBuffer.inMinutes) {
        await refreshToken();
      }
    } else {
      // Token is expired or doesn't exist
      await _storageService.clearAll();
    }
  }
}

class AuthResult {
  final bool isSuccess;
  final User? user;
  final String? error;
  
  AuthResult._({
    required this.isSuccess,
    this.user,
    this.error,
  });
  
  factory AuthResult.success(User user) {
    return AuthResult._(
      isSuccess: true,
      user: user,
    );
  }
  
  factory AuthResult.error(String error) {
    return AuthResult._(
      isSuccess: false,
      error: error,
    );
  }
}