import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String? _token;
  
  // Initialize token from storage
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
  }
  
  // Store token
  Future<void> setToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }
  
  // Clear token
  Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }
  
  // Get headers with authorization
  Map<String, String> get _headers {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    
    return headers;
  }
  
  // Generic GET request
  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, String>? queryParams,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
      final uriWithParams = queryParams != null 
          ? uri.replace(queryParameters: queryParams)
          : uri;
          
      final response = await http.get(uriWithParams, headers: _headers);
      
      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return ApiResponse.error('Network error: $e');
    }
  }
  
  // Generic POST request
  Future<ApiResponse<T>> post<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
      final response = await http.post(
        uri,
        headers: _headers,
        body: body != null ? jsonEncode(body) : null,
      );
      
      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return ApiResponse.error('Network error: $e');
    }
  }
  
  // Generic PUT request
  Future<ApiResponse<T>> put<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
      final response = await http.put(
        uri,
        headers: _headers,
        body: body != null ? jsonEncode(body) : null,
      );
      
      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return ApiResponse.error('Network error: $e');
    }
  }
  
  // Generic DELETE request
  Future<ApiResponse<void>> delete(String endpoint) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
      final response = await http.delete(uri, headers: _headers);
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiResponse.success(null);
      } else {
        final errorBody = jsonDecode(response.body);
        return ApiResponse.error(errorBody['message'] ?? 'Unknown error');
      }
    } catch (e) {
      return ApiResponse.error('Network error: $e');
    }
  }
  
  // File upload
  Future<ApiResponse<T>> uploadFile<T>(
    String endpoint,
    File file, {
    String fieldName = 'file',
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
      final request = http.MultipartRequest('POST', uri);
      
      // Add headers
      if (_token != null) {
        request.headers['Authorization'] = 'Bearer $_token';
      }
      
      // Add file
      request.files.add(await http.MultipartFile.fromPath(
        fieldName,
        file.path,
      ));
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return ApiResponse.error('Upload error: $e');
    }
  }
  
  // Handle HTTP response
  ApiResponse<T> _handleResponse<T>(
    http.Response response,
    T Function(Map<String, dynamic>)? fromJson,
  ) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return ApiResponse.success(null);
      }
      
      final data = jsonDecode(response.body);
      
      if (fromJson != null && data is Map<String, dynamic>) {
        return ApiResponse.success(fromJson(data));
      } else {
        return ApiResponse.success(data);
      }
    } else {
      try {
        final errorBody = jsonDecode(response.body);
        return ApiResponse.error(errorBody['message'] ?? 'Unknown error');
      } catch (e) {
        return ApiResponse.error('HTTP ${response.statusCode}: ${response.reasonPhrase}');
      }
    }
  }
}

class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? error;
  
  ApiResponse._({
    required this.success,
    this.data,
    this.error,
  });
  
  factory ApiResponse.success(T? data) {
    return ApiResponse._(success: true, data: data);
  }
  
  factory ApiResponse.error(String error) {
    return ApiResponse._(success: false, error: error);
  }
  
  bool get isSuccess => success;
  bool get isError => !success;
}