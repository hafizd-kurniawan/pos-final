class ApiConstants {
  // Base URL for development - adjust for production
  static const String baseUrl = 'http://localhost:8080/api/v1';
  
  // Authentication endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String profile = '/auth/profile';
  static const String refreshToken = '/auth/refresh';
  static const String changePassword = '/auth/change-password';
  
  // Dashboard endpoints
  static const String adminDashboard = '/admin/dashboard';
  static const String kasirDashboard = '/kasir/dashboard';
  static const String mekanikDashboard = '/mekanik/dashboard';
  
  // Vehicle endpoints
  static const String vehicles = '/vehicles';
  static String vehicleById(int id) => '/vehicles/$id';
  static String vehiclePhoto(int id) => '/files/vehicles/$id/photo';
  
  // Customer endpoints
  static const String customers = '/customers';
  static String customerById(int id) => '/customers/$id';
  
  // Sales endpoints
  static const String sales = '/sales';
  static String saleById(int id) => '/sales/$id';
  static String saleTransferProof(int id) => '/files/sales/$id/transfer-proof';
  static String salePdf(int id) => '/pdf/sales/$id';
  
  // Purchase endpoints
  static const String purchases = '/purchases';
  static String purchaseById(int id) => '/purchases/$id';
  static String purchaseTransferProof(int id) => '/files/purchases/$id/transfer-proof';
  static String purchasePdf(int id) => '/pdf/purchases/$id';
  
  // Work Order endpoints
  static const String workOrders = '/work-orders';
  static String workOrderById(int id) => '/work-orders/$id';
  static String workOrderStart(int id) => '/work-orders/$id/start';
  static String workOrderComplete(int id) => '/work-orders/$id/complete';
  static String workOrderUsePart(int id) => '/work-orders/$id/use-part';
  
  // Spare Parts endpoints
  static const String spareParts = '/spare-parts';
  static String sparePartById(int id) => '/spare-parts/$id';
  
  // Reports endpoints
  static const String salesReport = '/reports/sales';
  static const String purchaseReport = '/reports/purchases';
  static const String inventoryReport = '/reports/inventory';
  static const String profitLossReport = '/reports/profit-loss';
  
  // Notification endpoints
  static const String notifications = '/notifications';
  static const String notificationCount = '/notifications/unread/count';
  static String markNotificationRead(int id) => '/notifications/$id/read';
  
  // User management (Admin only)
  static const String users = '/admin/users';
  static String userById(int id) => '/admin/users/$id';
}

enum VehicleStatus {
  available('available', 'Available'),
  inRepair('in_repair', 'In Repair'),
  sold('sold', 'Sold'),
  reserved('reserved', 'Reserved');

  const VehicleStatus(this.value, this.displayName);
  
  final String value;
  final String displayName;
  
  static VehicleStatus fromString(String value) {
    return VehicleStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => VehicleStatus.available,
    );
  }
}

enum UserRole {
  admin('admin', 'Administrator'),
  kasir('kasir', 'Kasir'),
  mekanik('mekanik', 'Mekanik');

  const UserRole(this.value, this.displayName);
  
  final String value;
  final String displayName;
  
  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (role) => role.value == value,
      orElse: () => UserRole.kasir,
    );
  }
}

enum WorkOrderStatus {
  pending('pending', 'Pending'),
  inProgress('in_progress', 'In Progress'),
  completed('completed', 'Completed');

  const WorkOrderStatus(this.value, this.displayName);
  
  final String value;
  final String displayName;
  
  static WorkOrderStatus fromString(String value) {
    return WorkOrderStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => WorkOrderStatus.pending,
    );
  }
}