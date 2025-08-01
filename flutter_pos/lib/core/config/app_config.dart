class AppConfig {
  // API Configuration
  static const String baseUrl = 'http://localhost:8080/api/v1';
  
  // Endpoints
  static const String loginEndpoint = '/auth/login';
  static const String profileEndpoint = '/auth/profile';
  static const String refreshEndpoint = '/auth/refresh';
  static const String changePasswordEndpoint = '/auth/change-password';
  
  // Admin Endpoints
  static const String adminDashboardEndpoint = '/admin/dashboard';
  static const String adminUsersEndpoint = '/admin/users';
  
  // Kasir Endpoints
  static const String kasirDashboardEndpoint = '/kasir/dashboard';
  
  // Mechanic Endpoints
  static const String mechanicDashboardEndpoint = '/mechanic/dashboard';
  static const String myWorkOrdersEndpoint = '/work-orders/my';
  
  // Vehicle Endpoints
  static const String vehiclesEndpoint = '/vehicles';
  static const String vehiclePhotosEndpoint = '/files/vehicles';
  
  // Customer Endpoints
  static const String customersEndpoint = '/customers';
  
  // Sales Endpoints
  static const String salesEndpoint = '/sales';
  static const String salesPdfEndpoint = '/pdf/sales';
  static const String salesTransferProofEndpoint = '/files/sales';
  
  // Purchase Endpoints
  static const String purchasesEndpoint = '/purchases';
  static const String purchasePdfEndpoint = '/pdf/purchases';
  static const String purchaseTransferProofEndpoint = '/files/purchases';
  
  // Work Order Endpoints
  static const String workOrdersEndpoint = '/work-orders';
  static const String workOrderPdfEndpoint = '/pdf/work-orders';
  
  // Spare Parts Endpoints
  static const String sparePartsEndpoint = '/spare-parts';
  static const String lowStockEndpoint = '/spare-parts/low-stock';
  static const String barcodeEndpoint = '/spare-parts/barcode';
  static const String stockAdjustmentEndpoint = '/spare-parts';
  
  // Notification Endpoints
  static const String notificationsEndpoint = '/notifications';
  static const String unreadCountEndpoint = '/notifications/unread/count';
  
  // Report Endpoints
  static const String reportsEndpoint = '/reports';
  static const String reportsPdfEndpoint = '/pdf/reports';
  
  // App Configuration
  static const String appName = 'POS Flutter';
  static const String appVersion = '1.0.0';
  
  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userKey = 'user_data';
  
  // UI Configuration
  static const int gridColumns = 4; // For tablet view
  static const double cardElevation = 2.0;
  static const double borderRadius = 8.0;
  
  // File Upload Configuration
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png'];
  static const List<String> allowedDocTypes = ['pdf', 'doc', 'docx'];
}