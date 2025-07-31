// API Configuration
class AppConstants {
  // API Base URL - Update this to match your Go API server
  static const String apiBaseUrl = 'http://localhost:8080/api/v1';
  
  // File upload endpoints
  static const String uploadVehiclePhoto = '/files/vehicles';
  static const String uploadTransferProof = '/files/sales';
  static const String uploadPurchaseProof = '/files/purchases';
  
  // PDF endpoints
  static const String pdfSales = '/pdf/sales';
  static const String pdfPurchases = '/pdf/purchases';
  static const String pdfWorkOrders = '/pdf/work-orders';
  
  // App Info
  static const String appName = 'POS System';
  static const String appVersion = '1.0.0';
  
  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userKey = 'user_data';
  static const String userRoleKey = 'user_role';
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // File Upload
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png'];
  static const List<String> allowedDocumentTypes = ['pdf', 'doc', 'docx'];
  
  // Cache Duration
  static const Duration cacheExpiry = Duration(hours: 24);
  static const Duration tokenRefreshBuffer = Duration(minutes: 5);
  
  // UI Constants
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const double borderRadius = 8.0;
  static const double cardElevation = 2.0;
  
  // Grid Layout
  static const int gridColumnCount = 4;
  static const double gridSpacing = 16.0;
  static const double cardAspectRatio = 1.2;
  
  // Vehicle Status
  static const String statusAvailable = 'available';
  static const String statusInRepair = 'in_repair';
  static const String statusSold = 'sold';
  static const String statusReserved = 'reserved';
  
  // User Roles
  static const String roleAdmin = 'admin';
  static const String roleKasir = 'kasir';
  static const String roleMekanik = 'mekanik';
  
  // Photo Types
  static const List<String> vehiclePhotoTypes = [
    'depan',
    'belakang',
    'interior',
    'mesin',
    'samping_kiri',
    'samping_kanan',
    'dashboard',
    'bagasi'
  ];
}