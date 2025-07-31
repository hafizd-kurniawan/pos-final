import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';

class ApiService {
  final String baseUrl;
  String? _authToken;
  
  ApiService({required this.baseUrl});
  
  void setAuthToken(String token) {
    _authToken = token;
  }
  
  void clearAuthToken() {
    _authToken = null;
  }
  
  Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    
    return headers;
  }
  
  Map<String, String> get _multipartHeaders {
    final headers = <String, String>{
      'Accept': 'application/json',
    };
    
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    
    return headers;
  }
  
  // GET request
  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, dynamic>? queryParams,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      // Enhanced debug logging to identify URL construction issues
      print('=== API GET Request Debug ===');
      print('Base URL: "$baseUrl"');
      print('Endpoint: "$endpoint"');
      print('Query Params: $queryParams');
      
      var uri = Uri.parse('$baseUrl$endpoint');
      print('Initial URI: ${uri.toString()}');
      
      if (queryParams != null && queryParams.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParams.map(
          (key, value) => MapEntry(key, value.toString()),
        ));
        print('URI with query params: ${uri.toString()}');
      }
      
      print('Final Request URI: ${uri.toString()}');
      print('Request Headers: $_headers');
      
      final response = await http.get(uri, headers: _headers);
      
      // Debug logging
      print('API Response Status: ${response.statusCode}');
      print('API Response Body: ${response.body.length > 500 ? '${response.body.substring(0, 500)}...' : response.body}');
      print('=== End API Debug ===');
      
      return _handleResponse<T>(response, fromJson);
    } catch (e, stackTrace) {
      print('=== API GET Error Debug ===');
      print('Error Type: ${e.runtimeType}');
      print('Error: $e');
      print('Stack Trace: $stackTrace');
      print('Endpoint: "$endpoint"');
      print('Base URL: "$baseUrl"');
      print('=== End Error Debug ===');
      return ApiResponse.error('Network error: $e');
    }
  }
  
  // POST request
  Future<ApiResponse<T>> post<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      print('=== API POST Request Debug ===');
      print('Base URL: "$baseUrl"');
      print('Endpoint: "$endpoint"');
      
      final uri = Uri.parse('$baseUrl$endpoint');
      print('Request URI: ${uri.toString()}');
      print('Request Body: ${body != null ? json.encode(body) : 'null'}');
      
      final response = await http.post(
        uri,
        headers: _headers,
        body: body != null ? json.encode(body) : null,
      );
      
      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body.length > 500 ? '${response.body.substring(0, 500)}...' : response.body}');
      print('=== End POST Debug ===');
      
      return _handleResponse<T>(response, fromJson);
    } catch (e, stackTrace) {
      print('=== API POST Error Debug ===');
      print('Error: $e');
      print('Stack Trace: $stackTrace');
      print('=== End POST Error Debug ===');
      return ApiResponse.error('Network error: $e');
    }
  }
  
  // PUT request
  Future<ApiResponse<T>> put<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final response = await http.put(
        uri,
        headers: _headers,
        body: body != null ? json.encode(body) : null,
      );
      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return ApiResponse.error('Network error: $e');
    }
  }
  
  // DELETE request
  Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final response = await http.delete(uri, headers: _headers);
      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return ApiResponse.error('Network error: $e');
    }
  }
  
  // Upload file
  Future<ApiResponse<T>> uploadFile<T>(
    String endpoint,
    File file, {
    String fieldName = 'file',
    Map<String, String>? additionalFields,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final request = http.MultipartRequest('POST', uri);
      
      // Add headers
      request.headers.addAll(_multipartHeaders);
      
      // Add file
      request.files.add(await http.MultipartFile.fromPath(fieldName, file.path));
      
      // Add additional fields
      if (additionalFields != null) {
        request.fields.addAll(additionalFields);
      }
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return ApiResponse.error('Upload error: $e');
    }
  }
  
  // Handle API response
  ApiResponse<T> _handleResponse<T>(
    http.Response response,
    T Function(Map<String, dynamic>)? fromJson,
  ) {
    try {
      final data = json.decode(response.body) as Map<String, dynamic>;
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (fromJson != null && data['data'] != null) {
          final result = fromJson(data['data'] as Map<String, dynamic>);
          return ApiResponse.success(result, data);
        }
        return ApiResponse.success(null, data);
      } else {
        final message = data['message'] ?? data['error'] ?? 'Unknown error';
        return ApiResponse.error(message);
      }
    } catch (e) {
      return ApiResponse.error('Failed to parse response: $e');
    }
  }
}

class ApiResponse<T> {
  final bool isSuccess;
  final T? data;
  final Map<String, dynamic>? rawData;
  final String? error;
  
  ApiResponse._({
    required this.isSuccess,
    this.data,
    this.rawData,
    this.error,
  });
  
  factory ApiResponse.success(T? data, Map<String, dynamic>? rawData) {
    return ApiResponse._(
      isSuccess: true,
      data: data,
      rawData: rawData,
    );
  }
  
  factory ApiResponse.error(String error) {
    return ApiResponse._(
      isSuccess: false,
      error: error,
    );
  }
}

// Pagination helper
class PaginationInfo {
  final int page;
  final int limit;
  final int total;
  final int totalPages;
  final bool hasNext;
  final bool hasPrev;
  
  PaginationInfo({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
    required this.hasNext,
    required this.hasPrev,
  });
  
  factory PaginationInfo.fromJson(Map<String, dynamic> json) {
    return PaginationInfo(
      page: json['page'] ?? 1,
      limit: json['limit'] ?? AppConstants.defaultPageSize,
      total: json['total'] ?? 0,
      totalPages: json['total_pages'] ?? 1,
      hasNext: json['has_next'] ?? false,
      hasPrev: json['has_prev'] ?? false,
    );
  }
}