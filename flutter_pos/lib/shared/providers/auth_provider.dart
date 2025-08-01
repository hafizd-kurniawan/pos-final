import 'package:flutter/foundation.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/storage_service.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  User? _user;
  String? _token;
  bool _isLoading = false;
  String? _error;

  // Getters
  User? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null && _token != null;

  // Initialize auth state from storage
  Future<void> init() async {
    _setLoading(true);
    
    try {
      _token = await StorageService.getToken();
      final userData = await StorageService.getUser();
      
      if (_token != null && userData != null) {
        _user = User.fromJson(userData);
        
        // Verify token is still valid
        final profile = await _authService.getProfile();
        if (profile != null) {
          _user = profile;
        } else {
          // Token is invalid, clear auth data
          await _authService.logout();
          _user = null;
          _token = null;
        }
      }
    } catch (e) {
      _setError('Failed to initialize authentication');
    } finally {
      _setLoading(false);
    }
  }

  // Login
  Future<bool> login(String username, String password) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _authService.login(username, password);
      
      if (result.success) {
        _user = result.user;
        _token = result.token;
        notifyListeners();
        return true;
      } else {
        _setError(result.error ?? 'Login failed');
        return false;
      }
    } catch (e) {
      _setError('Login failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Register
  Future<bool> register(Map<String, dynamic> userData) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _authService.register(userData);
      
      if (result.success) {
        _user = result.user;
        _token = result.token;
        notifyListeners();
        return true;
      } else {
        _setError(result.error ?? 'Registration failed');
        return false;
      }
    } catch (e) {
      _setError('Registration failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Logout
  Future<void> logout() async {
    _setLoading(true);
    
    try {
      await _authService.logout();
    } catch (e) {
      // Ignore logout errors
    } finally {
      _user = null;
      _token = null;
      _clearError();
      _setLoading(false);
    }
  }

  // Refresh profile
  Future<void> refreshProfile() async {
    if (!isAuthenticated) return;

    try {
      final profile = await _authService.getProfile();
      if (profile != null) {
        _user = profile;
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to refresh profile');
    }
  }

  // Change password
  Future<bool> changePassword(String oldPassword, String newPassword) async {
    _setLoading(true);
    _clearError();

    try {
      final success = await _authService.changePassword(oldPassword, newPassword);
      if (!success) {
        _setError('Failed to change password');
      }
      return success;
    } catch (e) {
      _setError('Failed to change password: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Check and refresh token if needed
  Future<bool> ensureValidToken() async {
    if (!isAuthenticated) return false;

    try {
      final isExpired = await _authService.isTokenExpired();
      if (isExpired) {
        final refreshed = await _authService.refreshToken();
        if (refreshed) {
          _token = await StorageService.getToken();
          notifyListeners();
          return true;
        } else {
          // Refresh failed, logout
          await logout();
          return false;
        }
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  // Get user role
  String? get userRole => _user?.role;
  bool get isAdmin => _user?.isAdmin ?? false;
  bool get isKasir => _user?.isKasir ?? false;
  bool get isMekanik => _user?.isMekanik ?? false;

  // Get dashboard route based on role
  String? get dashboardRoute {
    switch (userRole) {
      case 'admin':
        return '/admin-dashboard';
      case 'kasir':
        return '/kasir-dashboard';
      case 'mekanik':
        return '/mechanic-dashboard';
      default:
        return null;
    }
  }
}