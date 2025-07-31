// Environment-specific configurations
class AppEnvironment {
  static const String environment = String.fromEnvironment('ENVIRONMENT', defaultValue: 'development');
  
  // API Base URLs for different environments
  static const Map<String, String> apiBaseUrls = {
    'development': 'http://localhost:8080/api/v1',
    'staging': 'https://staging-api.yourdomain.com/api/v1',
    'production': 'https://api.yourdomain.com/api/v1',
  };
  
  // Get current API base URL
  static String get apiBaseUrl {
    final url = apiBaseUrls[environment] ?? apiBaseUrls['development']!;
    print('AppEnvironment: Using API base URL: $url for environment: $environment');
    return url;
  }
  
  // Development flags
  static bool get isDevelopment => environment == 'development';
  static bool get isStaging => environment == 'staging';
  static bool get isProduction => environment == 'production';
  
  // Debug settings
  static bool get enableDebugLogs => isDevelopment || isStaging;
  static bool get enableNetworkLogs => isDevelopment;
}