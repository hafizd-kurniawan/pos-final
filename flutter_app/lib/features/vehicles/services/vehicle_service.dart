import 'dart:io';
import '../../core/services/api_service.dart';
import '../../core/constants/api_constants.dart';
import '../../shared/models/app_models.dart';

class VehicleService {
  final ApiService _apiService = ApiService();

  Future<ApiResponse<List<Vehicle>>> getVehicles({
    String? search,
    VehicleStatus? status,
    String? brand,
    int page = 1,
    int limit = 20,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };

    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }
    if (status != null) {
      queryParams['status'] = status.value;
    }
    if (brand != null && brand.isNotEmpty) {
      queryParams['brand'] = brand;
    }

    final response = await _apiService.get<List<Vehicle>>(
      ApiConstants.vehicles,
      queryParams: queryParams,
      fromJson: (json) {
        final List<dynamic> vehicleList = json['data'] ?? json;
        return vehicleList.map((v) => Vehicle.fromJson(v)).toList();
      },
    );

    return response;
  }

  Future<ApiResponse<Vehicle>> getVehicleById(int id) async {
    return await _apiService.get<Vehicle>(
      ApiConstants.vehicleById(id),
      fromJson: (json) => Vehicle.fromJson(json['data'] ?? json),
    );
  }

  Future<ApiResponse<Vehicle>> createVehicle({
    required String brand,
    required String model,
    required int year,
    required String color,
    required String engineNumber,
    required String chassisNumber,
    required double purchasePrice,
    int? customerId,
  }) async {
    return await _apiService.post<Vehicle>(
      ApiConstants.vehicles,
      body: {
        'brand': brand,
        'model': model,
        'year': year,
        'color': color,
        'engine_number': engineNumber,
        'chassis_number': chassisNumber,
        'purchase_price': purchasePrice,
        'customer_id': customerId,
      },
      fromJson: (json) => Vehicle.fromJson(json['data'] ?? json),
    );
  }

  Future<ApiResponse<Vehicle>> updateVehicle({
    required int id,
    String? brand,
    String? model,
    int? year,
    String? color,
    String? engineNumber,
    String? chassisNumber,
    double? purchasePrice,
    VehicleStatus? status,
    int? customerId,
  }) async {
    final body = <String, dynamic>{};
    
    if (brand != null) body['brand'] = brand;
    if (model != null) body['model'] = model;
    if (year != null) body['year'] = year;
    if (color != null) body['color'] = color;
    if (engineNumber != null) body['engine_number'] = engineNumber;
    if (chassisNumber != null) body['chassis_number'] = chassisNumber;
    if (purchasePrice != null) body['purchase_price'] = purchasePrice;
    if (status != null) body['status'] = status.value;
    if (customerId != null) body['customer_id'] = customerId;

    return await _apiService.put<Vehicle>(
      ApiConstants.vehicleById(id),
      body: body,
      fromJson: (json) => Vehicle.fromJson(json['data'] ?? json),
    );
  }

  Future<ApiResponse<void>> deleteVehicle(int id) async {
    return await _apiService.delete(ApiConstants.vehicleById(id));
  }

  Future<ApiResponse<String>> uploadVehiclePhoto(int vehicleId, File photoFile) async {
    return await _apiService.uploadFile<String>(
      ApiConstants.vehiclePhoto(vehicleId),
      photoFile,
      fieldName: 'photo',
      fromJson: (json) => json['photo_url'] ?? json['url'] ?? '',
    );
  }

  // Get available brands for filtering
  Future<ApiResponse<List<String>>> getVehicleBrands() async {
    final response = await _apiService.get<List<String>>(
      '${ApiConstants.vehicles}/brands',
      fromJson: (json) {
        final List<dynamic> brands = json['brands'] ?? json;
        return brands.map((b) => b.toString()).toList();
      },
    );

    return response;
  }

  // Get vehicles by status with count
  Future<ApiResponse<Map<String, int>>> getVehicleStatusCounts() async {
    return await _apiService.get<Map<String, int>>(
      '${ApiConstants.vehicles}/status-counts',
      fromJson: (json) {
        final Map<String, dynamic> counts = json['counts'] ?? json;
        return counts.map((key, value) => MapEntry(key, value as int));
      },
    );
  }
}