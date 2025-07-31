import 'dart:convert';
import 'dart:io';
import 'dart:async';
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
      // Extremely detailed debug logging for browser environment
      print('==== ULTRA-DETAILED API GET REQUEST DEBUG ====');
      print('⚡ REQUEST INITIATION:');
      print('  🌐 Base URL: "$baseUrl"');
      print('  📍 Endpoint: "$endpoint"');
      print('  📋 Query Params: $queryParams');
      print('  🔑 Auth Token Present: ${_authToken != null ? "YES" : "NO"}');
      if (_authToken != null) {
        print('  🔐 Token Preview: ${_authToken!.substring(0, 20)}...');
      }
      
      // URL Construction Analysis
      var uri = Uri.parse('$baseUrl$endpoint');
      print('📏 URL CONSTRUCTION ANALYSIS:');
      print('  🔗 Base + Endpoint URI: ${uri.toString()}');
      print('  🔍 URI Scheme: ${uri.scheme}');
      print('  🏠 URI Host: ${uri.host}');
      print('  🔌 URI Port: ${uri.port}');
      print('  📂 URI Path: ${uri.path}');
      
      if (queryParams != null && queryParams.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParams.map(
          (key, value) => MapEntry(key, value.toString()),
        ));
        print('  ➕ With Query Params: ${uri.toString()}');
        print('  🔍 Query String: ${uri.query}');
      }
      
      print('🎯 FINAL REQUEST URI: ${uri.toString()}');
      print('📤 REQUEST HEADERS:');
      _headers.forEach((key, value) {
        if (key.toLowerCase().contains('authorization')) {
          print('  $key: ${value.substring(0, 20)}...');
        } else {
          print('  $key: $value');
        }
      });
      
      // Browser Environment Detection
      print('🌍 BROWSER ENVIRONMENT DETECTION:');
      print('  Platform: Web Browser');
      print('  User Agent Available: ${_headers.containsKey('User-Agent')}');
      
      // Enhanced Connectivity Test
      print('🔬 ENHANCED CONNECTIVITY DIAGNOSTICS:');
      try {
        final healthUri = Uri.parse('$baseUrl').replace(path: '/health');
        print('  🩺 Health Check URL: ${healthUri.toString()}');
        print('  ⏱️  Attempting health check with 5s timeout...');
        
        final healthStartTime = DateTime.now();
        final healthResponse = await http.get(healthUri).timeout(
          const Duration(seconds: 5),
          onTimeout: () {
            throw TimeoutException('Health check timeout', const Duration(seconds: 5));
          },
        );
        final healthDuration = DateTime.now().difference(healthStartTime);
        
        print('  ✅ Health Check SUCCESS:');
        print('    📊 Status: ${healthResponse.statusCode}');
        print('    ⏰ Response Time: ${healthDuration.inMilliseconds}ms');
        print('    📦 Response Size: ${healthResponse.body.length} bytes');
        print('    📋 Response Headers: ${healthResponse.headers}');
        print('    💬 Response Body: ${healthResponse.body}');
        print('  🟢 Server is reachable and responding');
      } catch (healthError) {
        print('  ❌ HEALTH CHECK FAILED:');
        print('    🚨 Error: $healthError');
        print('    🔍 Error Type: ${healthError.runtimeType}');
        print('  🔴 This suggests potential connectivity issues');
      }
      
      print('🚀 PROCEEDING WITH MAIN API REQUEST...');
      print('⏱️  Request timeout: 15 seconds');
      
      final requestStartTime = DateTime.now();
      print('  ⏰ Request initiated at: ${requestStartTime.toIso8601String()}');
      
      final response = await http.get(uri, headers: _headers).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          final timeoutTime = DateTime.now();
          print('  ⏰ Timeout occurred at: ${timeoutTime.toIso8601String()}');
          throw TimeoutException('Request timeout', const Duration(seconds: 15));
        },
      );
      
      final responseTime = DateTime.now();
      final requestDuration = responseTime.difference(requestStartTime);
      
      // Ultra-detailed response analysis
      print('📨 RESPONSE RECEIVED:');
      print('  ⏰ Response received at: ${responseTime.toIso8601String()}');
      print('  ⚡ Total request duration: ${requestDuration.inMilliseconds}ms');
      print('  📊 HTTP Status: ${response.statusCode}');
      print('  📦 Response Content Length: ${response.contentLength ?? "unknown"} bytes');
      print('  🗜️ Actual Body Length: ${response.body.length} bytes');
      
      print('📋 RESPONSE HEADERS ANALYSIS:');
      response.headers.forEach((key, value) {
        print('    $key: $value');
      });
      
      print('📄 RESPONSE BODY PREVIEW:');
      if (response.body.length > 2000) {
        print('    ${response.body.substring(0, 2000)}...[TRUNCATED - ${response.body.length} total chars]');
      } else {
        print('    ${response.body}');
      }
      
      print('✅ REQUEST COMPLETED SUCCESSFULLY');
      print('==== END ULTRA-DETAILED DEBUG ====');
      
      return _handleResponse<T>(response, fromJson);
    } on SocketException catch (e) {
      print('🚨 === SOCKET EXCEPTION ULTRA-DEBUG ===');
      print('💥 SocketException caught - Network layer failure');
      print('📊 Exception Details:');
      print('  📝 Message: ${e.message}');
      print('  🌐 Address: ${e.address}');
      print('  🔌 Port: ${e.port}');
      print('  💻 OS Error: ${e.osError}');
      print('  🏷️  Exception Type: ${e.runtimeType}');
      
      print('🔍 NETWORK TROUBLESHOOTING ANALYSIS:');
      print('  🎯 Target: $baseUrl');
      print('  📍 Endpoint: "$endpoint"');
      print('  🚨 This typically indicates:');
      print('    1. 🔴 Server is not running or not accessible');
      print('    2. 🛡️  Firewall blocking the connection');
      print('    3. 🌐 Network connectivity issues');
      print('    4. 🔌 Wrong host/port configuration');
      print('    5. 🏗️  Server crashed or overloaded');
      
      print('🔧 IMMEDIATE ACTIONS TO TRY:');
      print('  1. ✅ Verify server is running: curl $baseUrl/health');
      print('  2. 🔍 Check network: ping ${Uri.parse(baseUrl).host}');
      print('  3. 🔌 Verify port: telnet ${Uri.parse(baseUrl).host} ${Uri.parse(baseUrl).port}');
      print('  4. 🛡️  Check firewall settings');
      print('=== END SOCKET EXCEPTION DEBUG ===');
      
      return ApiResponse.error('🚨 Network Connection Failed: Cannot connect to $baseUrl. Server may be down or unreachable. Please verify the server is running and network connectivity.');
    } on TimeoutException catch (e) {
      print('⏰ === TIMEOUT EXCEPTION ULTRA-DEBUG ===');
      print('🐌 Request timed out - Server too slow or unresponsive');
      print('📊 Timeout Details:');
      print('  ⏱️  Duration: ${e.duration}');
      print('  📝 Message: ${e.message}');
      print('  🎯 Target: $baseUrl');
      print('  📍 Endpoint: "$endpoint"');
      
      print('🔍 TIMEOUT ANALYSIS:');
      print('  🚨 Possible causes:');
      print('    1. 🐌 Server is overloaded or slow');
      print('    2. 🌐 Network latency issues');
      print('    3. 🔄 Server stuck processing request');
      print('    4. 🛑 Large data transfer taking too long');
      print('    5. 💾 Database query performance issues');
      
      print('🔧 RECOMMENDED ACTIONS:');
      print('  1. 🔄 Retry the request');
      print('  2. 📊 Check server performance');
      print('  3. 🌐 Test network speed');
      print('  4. 📈 Monitor server logs');
      print('=== END TIMEOUT EXCEPTION DEBUG ===');
      
      return ApiResponse.error('⏰ Request Timeout: Server at $baseUrl took longer than ${e.duration} to respond. This may indicate server performance issues.');
    } on HttpException catch (e) {
      print('📡 === HTTP EXCEPTION ULTRA-DEBUG ===');
      print('💥 HTTP protocol level exception');
      print('📊 HTTP Exception Details:');
      print('  📝 Message: ${e.message}');
      print('  🔗 URI: ${e.uri}');
      print('  🎯 Target: $baseUrl');
      print('  📍 Endpoint: "$endpoint"');
      
      print('🔍 HTTP ERROR ANALYSIS:');
      print('  🚨 This indicates HTTP protocol issues:');
      print('    1. 🏗️  Server configuration problems');
      print('    2. 📡 Protocol mismatch (HTTP vs HTTPS)');
      print('    3. 🔧 Invalid HTTP headers or method');
      print('    4. 🛡️  Proxy or gateway issues');
      
      print('=== END HTTP EXCEPTION DEBUG ===');
      return ApiResponse.error('📡 HTTP Protocol Error: ${e.message}');
    } on FormatException catch (e) {
      print('📝 === FORMAT EXCEPTION ULTRA-DEBUG ===');
      print('💥 URL or data format exception');
      print('📊 Format Exception Details:');
      print('  📝 Message: ${e.message}');
      print('  📄 Source: ${e.source}');
      print('  📍 Offset: ${e.offset}');
      print('  🎯 Base URL: "$baseUrl"');
      print('  📍 Endpoint: "$endpoint"');
      
      print('🔍 FORMAT ERROR ANALYSIS:');
      print('  🚨 This indicates URL construction issues:');
      print('    1. ❌ Invalid URL format');
      print('    2. 🔤 Special characters not encoded');
      print('    3. 📐 Malformed query parameters');
      print('    4. 🔗 Invalid base URL structure');
      
      print('🔧 URL VALIDATION:');
      try {
        final testUri = Uri.parse('$baseUrl$endpoint');
        print('  ✅ Base URL parsing: OK');
        print('  🔗 Parsed URI: $testUri');
      } catch (uriError) {
        print('  ❌ Base URL parsing failed: $uriError');
      }
      
      print('=== END FORMAT EXCEPTION DEBUG ===');
      return ApiResponse.error('📝 Invalid URL Format: ${e.message}. Check URL construction.');
    } catch (e, stackTrace) {
      print('💥 === UNEXPECTED EXCEPTION ULTRA-DEBUG ===');
      print('🚨 Caught unexpected exception type: ${e.runtimeType}');
      print('📊 Exception Details:');
      print('  📝 Error: $e');
      print('  🏷️  Type: ${e.runtimeType}');
      
      print('📍 Request Context:');
      print('  🎯 Base URL: "$baseUrl"');
      print('  📍 Endpoint: "$endpoint"');
      print('  🔗 Full URI: ${Uri.parse('$baseUrl$endpoint')}');
      print('  🔑 Has Auth: ${_authToken != null}');
      
      // Browser-specific error analysis
      print('🌍 BROWSER-SPECIFIC ERROR ANALYSIS:');
      if (e.toString().contains('ClientException')) {
        print('  🚨 DETECTED: ClientException - Browser security restriction');
        print('  💡 Common causes in browser environment:');
        print('    1. 🛡️  CORS (Cross-Origin Resource Sharing) blocked');
        print('    2. 🔒 Mixed content (HTTPS page calling HTTP API)');
        print('    3. 🚫 Browser security policy violation');
        print('    4. 🌐 Network connectivity lost');
        print('    5. 🔧 Invalid request configuration');
        
        print('  🔧 BROWSER-SPECIFIC TROUBLESHOOTING:');
        print('    1. 🔍 Check browser DevTools Console for CORS errors');
        print('    2. 🔍 Check browser DevTools Network tab');
        print('    3. 🛡️  Verify server CORS configuration');
        print('    4. 🔒 Ensure HTTPS/HTTP protocol match');
        print('    5. 🚫 Check for browser extensions blocking requests');
      }
      
      if (e.toString().contains('Failed to fetch')) {
        print('  🚨 DETECTED: "Failed to fetch" - Classic browser network error');
        print('  💡 Typical reasons:');
        print('    1. 🌐 Network disconnected or unstable');
        print('    2. 🛡️  CORS preflight request failed');
        print('    3. 🔒 SSL/TLS certificate issues');
        print('    4. 🚫 Request blocked by browser/extension');
        print('    5. 🏗️  Server not responding to OPTIONS request');
      }
      
      print('📚 COMPLETE STACK TRACE:');
      final stackLines = stackTrace.toString().split('\n');
      for (int i = 0; i < stackLines.length && i < 20; i++) {
        print('  ${i.toString().padLeft(2)}: ${stackLines[i]}');
      }
      if (stackLines.length > 20) {
        print('  ... [${stackLines.length - 20} more lines]');
      }
      
      print('=== END UNEXPECTED EXCEPTION DEBUG ===');
      return ApiResponse.error('💥 Unexpected Browser Error: $e');
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