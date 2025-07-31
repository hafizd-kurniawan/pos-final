import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../../core/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  
  User? _currentUser;
  bool _isLoading = false;
  String? _error;
  
  AuthProvider(this._authService) {
    _initializeAuth();
  }
  
  // Getters
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;
  String? get currentUserRole => _currentUser?.role;
  
  // Role check helpers
  bool get isAdmin => _currentUser?.isAdmin ?? false;
  bool get isKasir => _currentUser?.isKasir ?? false;
  bool get isMekanik => _currentUser?.isMekanik ?? false;
  bool get isAdminOrKasir => _currentUser?.isAdminOrKasir ?? false;
  
  Future<void> _initializeAuth() async {
    _setLoading(true);
    
    try {
      await _authService.initializeAuth();
      if (_authService.isAuthenticated) {
        _currentUser = await _authService.getProfile();
      }
    } catch (e) {
      _setError('Failed to initialize authentication: $e');
    }
    
    _setLoading(false);
  }
  
  Future<bool> login(String username, String password) async {
    _setLoading(true);
    _clearError();
    
    try {
      final result = await _authService.login(username, password);
      
      if (result.isSuccess) {
        _currentUser = result.user;
        _setLoading(false);
        notifyListeners();
        return true;
      } else {
        _setError(result.error ?? 'Login failed');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Login error: $e');
      _setLoading(false);
      return false;
    }
  }
  
  Future<bool> register({
    required String username,
    required String email,
    required String password,
    required String fullName,
    String? phone,
    required String role,
  }) async {
    _setLoading(true);
    _clearError();
    
    try {
      final result = await _authService.register(
        username: username,
        email: email,
        password: password,
        fullName: fullName,
        phone: phone,
        role: role,
      );
      
      if (result.isSuccess) {
        _currentUser = result.user;
        _setLoading(false);
        notifyListeners();
        return true;
      } else {
        _setError(result.error ?? 'Registration failed');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Registration error: $e');
      _setLoading(false);
      return false;
    }
  }
  
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    _setLoading(true);
    _clearError();
    
    try {
      final success = await _authService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      
      if (!success) {
        _setError('Failed to change password');
      }
      
      _setLoading(false);
      return success;
    } catch (e) {
      _setError('Change password error: $e');
      _setLoading(false);
      return false;
    }
  }
  
  Future<void> refreshProfile() async {
    try {
      final user = await _authService.getProfile();
      if (user != null) {
        _currentUser = user;
        notifyListeners();
      }
    } catch (e) {
      // Silent failure for profile refresh
      debugPrint('Profile refresh error: $e');
    }
  }
  
  Future<void> logout() async {
    _setLoading(true);
    
    try {
      await _authService.logout();
      _currentUser = null;
      _clearError();
    } catch (e) {
      _setError('Logout error: $e');
    }
    
    _setLoading(false);
    notifyListeners();
  }
  
  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }
  
  void _setError(String? error) {
    if (_error != error) {
      _error = error;
      notifyListeners();
    }
  }
  
  void _clearError() {
    _setError(null);
  }
  
  void clearError() {
    _clearError();
  }
}