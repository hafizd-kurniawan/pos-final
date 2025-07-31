import '../../core/services/api_service.dart';
import '../../core/constants/api_constants.dart';
import '../../shared/models/app_models.dart';

class DashboardService {
  final ApiService _apiService = ApiService();

  Future<ApiResponse<DashboardStats>> getAdminDashboard() async {
    return await _apiService.get<DashboardStats>(
      ApiConstants.adminDashboard,
      fromJson: (json) => DashboardStats.fromJson(json['data'] ?? json),
    );
  }

  Future<ApiResponse<DashboardStats>> getKasirDashboard() async {
    return await _apiService.get<DashboardStats>(
      ApiConstants.kasirDashboard,
      fromJson: (json) => DashboardStats.fromJson(json['data'] ?? json),
    );
  }

  Future<ApiResponse<DashboardStats>> getMekanikDashboard() async {
    return await _apiService.get<DashboardStats>(
      ApiConstants.mekanikDashboard,
      fromJson: (json) => DashboardStats.fromJson(json['data'] ?? json),
    );
  }

  Future<ApiResponse<DashboardStats>> getDashboardByRole(UserRole role) async {
    switch (role) {
      case UserRole.admin:
        return getAdminDashboard();
      case UserRole.kasir:
        return getKasirDashboard();
      case UserRole.mekanik:
        return getMekanikDashboard();
    }
  }

  Future<ApiResponse<int>> getNotificationCount() async {
    return await _apiService.get<int>(
      ApiConstants.notificationCount,
      fromJson: (json) => json['count'] ?? json['unread_count'] ?? 0,
    );
  }
}