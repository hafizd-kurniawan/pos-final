/// API Endpoints Configuration
/// Maps to the Go backend API endpoints
class ApiEndpoints {
  static const String baseUrl = 'http://localhost:8080';
  static const String apiVersion = '/api/v1';
  static const String apiBase = '$baseUrl$apiVersion';
  
  // Authentication Endpoints
  static const String login = '$apiBase/auth/login';
  static const String register = '$apiBase/auth/register';
  static const String profile = '$apiBase/auth/profile';
  static const String refreshToken = '$apiBase/auth/refresh';
  static const String changePassword = '$apiBase/auth/change-password';
  
  // Dashboard Endpoints (Role-based)
  static const String adminDashboard = '$apiBase/admin/dashboard';
  static const String kasirDashboard = '$apiBase/kasir/dashboard';
  static const String mechanicDashboard = '$apiBase/mechanic/dashboard';
  
  // Customer Management
  static const String customers = '$apiBase/customers';
  static String customerById(String id) => '$customers/$id';
  
  // Vehicle Management (with mandatory photos)
  static const String vehicles = '$apiBase/vehicles';
  static String vehicleById(String id) => '$vehicles/$id';
  static String vehiclePhoto(String vehicleId) => '$apiBase/files/vehicles/$vehicleId/photo';
  
  // Purchase Management
  static const String purchases = '$apiBase/purchases';
  static String purchaseById(String id) => '$purchases/$id';
  static String purchaseTransferProof(String purchaseId) => '$apiBase/files/purchases/$purchaseId/transfer-proof';
  static const String dailyPurchases = '$apiBase/purchases/daily';
  
  // Sales Management
  static const String sales = '$apiBase/sales';
  static String salesById(String id) => '$sales/$id';
  static String salesTransferProof(String salesId) => '$apiBase/files/sales/$salesId/transfer-proof';
  static const String dailySales = '$apiBase/sales/daily';
  
  // Work Order Management
  static const String workOrders = '$apiBase/work-orders';
  static String workOrderById(String id) => '$workOrders/$id';
  static String workOrderStart(String id) => '$workOrders/$id/start';
  static String workOrderComplete(String id) => '$workOrders/$id/complete';
  static String workOrderUsePart(String id) => '$workOrders/$id/use-part';
  static const String dailyWorkOrders = '$apiBase/work-orders/daily';
  
  // Spare Parts Management
  static const String spareParts = '$apiBase/spare-parts';
  static String sparePartById(String id) => '$spareParts/$id';
  
  // Admin User Management
  static const String adminUsers = '$apiBase/admin/users';
  static String adminUserById(String id) => '$adminUsers/$id';
  static String adminUserActivate(String id) => '$adminUsers/$id/activate';
  static String adminUserDeactivate(String id) => '$adminUsers/$id/deactivate';
  
  // PDF Generation
  static String salesPdf(String salesId) => '$apiBase/pdf/sales/$salesId';
  static String purchasePdf(String purchaseId) => '$apiBase/pdf/purchases/$purchaseId';
  static String workOrderPdf(String workOrderId) => '$apiBase/pdf/work-orders/$workOrderId';
  static const String reportsPdf = '$apiBase/pdf/reports';
  
  // Notifications
  static const String notifications = '$apiBase/notifications';
  static const String unreadNotifications = '$notifications/unread';
  static const String unreadCount = '$notifications/unread/count';
  static String markNotificationRead(String id) => '$notifications/$id/read';
  static const String markAllRead = '$notifications/read-all';
  
  // Advanced Reports & Analytics
  static const String reportsSales = '$apiBase/reports/sales';
  static const String reportsPurchases = '$apiBase/reports/purchases';
  static const String reportsInventory = '$apiBase/reports/inventory';
  static const String reportsProfitLoss = '$apiBase/reports/profit-loss';
  static const String reportsVehicles = '$apiBase/reports/vehicles';
  static const String reportsWorkOrders = '$apiBase/reports/work-orders';
  static const String reportsCustomers = '$apiBase/reports/customers';
  static const String reportsOverview = '$apiBase/reports/overview';
}

/// Role-based access control
enum UserRole {
  admin,
  kasir,
  mekanik,
}

extension UserRoleExtension on UserRole {
  String get value {
    switch (this) {
      case UserRole.admin:
        return 'admin';
      case UserRole.kasir:
        return 'kasir';
      case UserRole.mekanik:
        return 'mekanik';
    }
  }
  
  String get displayName {
    switch (this) {
      case UserRole.admin:
        return 'Administrator';
      case UserRole.kasir:
        return 'Kasir';
      case UserRole.mekanik:
        return 'Mekanik';
    }
  }
}

/// Vehicle Status Enum
enum VehicleStatus {
  available,
  inRepair,
  sold,
  reserved,
}

extension VehicleStatusExtension on VehicleStatus {
  String get value {
    switch (this) {
      case VehicleStatus.available:
        return 'available';
      case VehicleStatus.inRepair:
        return 'in_repair';
      case VehicleStatus.sold:
        return 'sold';
      case VehicleStatus.reserved:
        return 'reserved';
    }
  }
  
  String get displayName {
    switch (this) {
      case VehicleStatus.available:
        return 'Available';
      case VehicleStatus.inRepair:
        return 'In Repair';
      case VehicleStatus.sold:
        return 'Sold';
      case VehicleStatus.reserved:
        return 'Reserved';
    }
  }
}

/// Work Order Status Enum
enum WorkOrderStatus {
  pending,
  inProgress,
  completed,
}

extension WorkOrderStatusExtension on WorkOrderStatus {
  String get value {
    switch (this) {
      case WorkOrderStatus.pending:
        return 'pending';
      case WorkOrderStatus.inProgress:
        return 'in_progress';
      case WorkOrderStatus.completed:
        return 'completed';
    }
  }
  
  String get displayName {
    switch (this) {
      case WorkOrderStatus.pending:
        return 'Pending';
      case WorkOrderStatus.inProgress:
        return 'In Progress';
      case WorkOrderStatus.completed:
        return 'Completed';
    }
  }
}

/// Payment Method Enum
enum PaymentMethod {
  cash,
  transfer,
}

extension PaymentMethodExtension on PaymentMethod {
  String get value {
    switch (this) {
      case PaymentMethod.cash:
        return 'cash';
      case PaymentMethod.transfer:
        return 'transfer';
    }
  }
  
  String get displayName {
    switch (this) {
      case PaymentMethod.cash:
        return 'Cash';
      case PaymentMethod.transfer:
        return 'Bank Transfer';
    }
  }
}

/// Notification Type Enum
enum NotificationType {
  workOrderAssigned,
  lowStock,
  workOrderUpdate,
  systemAlert,
}

extension NotificationTypeExtension on NotificationType {
  String get value {
    switch (this) {
      case NotificationType.workOrderAssigned:
        return 'work_order_assigned';
      case NotificationType.lowStock:
        return 'low_stock';
      case NotificationType.workOrderUpdate:
        return 'work_order_update';
      case NotificationType.systemAlert:
        return 'system_alert';
    }
  }
  
  String get displayName {
    switch (this) {
      case NotificationType.workOrderAssigned:
        return 'Work Order Assigned';
      case NotificationType.lowStock:
        return 'Low Stock Alert';
      case NotificationType.workOrderUpdate:
        return 'Work Order Update';
      case NotificationType.systemAlert:
        return 'System Alert';
    }
  }
}

/// App Configuration Constants
class AppConfig {
  static const String appName = 'POS Vehicle Management';
  static const String appVersion = '1.0.0';
  
  // File upload limits (matching backend)
  static const int maxImageSizeMB = 5;
  static const int maxDocumentSizeMB = 10;
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png', 'gif', 'webp'];
  static const List<String> allowedDocumentTypes = ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'];
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // Grid layout
  static const int gridColumns = 4;
  static const double gridAspectRatio = 1.2;
  
  // Cache duration
  static const Duration cacheTimeout = Duration(minutes: 5);
  static const Duration tokenRefreshThreshold = Duration(minutes: 5);
}

/// Error Messages
class ErrorMessages {
  static const String networkError = 'Network connection error';
  static const String serverError = 'Server error occurred';
  static const String unauthorized = 'Authentication required';
  static const String forbidden = 'Access denied';
  static const String notFound = 'Resource not found';
  static const String validationError = 'Validation error';
  static const String uploadError = 'File upload failed';
  static const String unknown = 'An unknown error occurred';
}

/// Success Messages
class SuccessMessages {
  static const String loginSuccess = 'Login successful';
  static const String logoutSuccess = 'Logout successful';
  static const String saveSuccess = 'Data saved successfully';
  static const String deleteSuccess = 'Data deleted successfully';
  static const String uploadSuccess = 'File uploaded successfully';
  static const String updateSuccess = 'Data updated successfully';
}