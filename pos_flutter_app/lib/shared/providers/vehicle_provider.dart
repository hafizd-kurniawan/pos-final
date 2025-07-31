import 'package:flutter/material.dart';
import '../models/vehicle_model.dart';
import '../../core/services/api_service.dart';
import '../../core/constants/app_constants.dart';

class VehicleProvider extends ChangeNotifier {
  final ApiService _apiService;
  
  List<Vehicle> _vehicles = [];
  Vehicle? _selectedVehicle;
  bool _isLoading = false;
  String? _error;
  PaginationInfo? _pagination;
  
  VehicleProvider(this._apiService);
  
  // Getters
  List<Vehicle> get vehicles => _vehicles;
  Vehicle? get selectedVehicle => _selectedVehicle;
  bool get isLoading => _isLoading;
  String? get error => _error;
  PaginationInfo? get pagination => _pagination;
  
  // Available vehicles only
  List<Vehicle> get availableVehicles => 
      _vehicles.where((v) => v.isAvailable).toList();
  
  // Vehicles in repair
  List<Vehicle> get vehiclesInRepair => 
      _vehicles.where((v) => v.isInRepair).toList();
  
  // Sold vehicles
  List<Vehicle> get soldVehicles => 
      _vehicles.where((v) => v.isSold).toList();
  
  Future<void> loadVehicles({
    int page = 1,
    int limit = AppConstants.defaultPageSize,
    String? status,
    String? search,
    String? brand,
    bool refresh = false,
  }) async {
    if (refresh || page == 1) {
      _vehicles.clear();
    }
    
    _setLoading(true);
    _clearError();
    
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };
      
      if (status != null) queryParams['status'] = status;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (brand != null && brand.isNotEmpty) queryParams['brand'] = brand;
      
      final response = await _apiService.get<List<dynamic>>(
        '/vehicles',
        queryParams: queryParams,
      );
      
      if (response.isSuccess && response.rawData != null) {
        final data = response.rawData!['data'] as List<dynamic>;
        final newVehicles = data
            .map((v) => Vehicle.fromJson(v as Map<String, dynamic>))
            .toList();
        
        if (page == 1) {
          _vehicles = newVehicles;
        } else {
          _vehicles.addAll(newVehicles);
        }
        
        // Update pagination info
        if (response.rawData!.containsKey('pagination')) {
          _pagination = PaginationInfo.fromJson(
            response.rawData!['pagination'] as Map<String, dynamic>
          );
        }
      } else {
        _setError(response.error ?? 'Failed to load vehicles');
      }
    } catch (e) {
      _setError('Error loading vehicles: $e');
    }
    
    _setLoading(false);
  }
  
  Future<Vehicle?> getVehicle(int id) async {
    _setLoading(true);
    _clearError();
    
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        '/vehicles/$id',
      );
      
      if (response.isSuccess && response.rawData != null) {
        final vehicleData = response.rawData!['data'] as Map<String, dynamic>;
        final vehicle = Vehicle.fromJson(vehicleData);
        _selectedVehicle = vehicle;
        
        // Update vehicle in list if exists
        final index = _vehicles.indexWhere((v) => v.id == id);
        if (index != -1) {
          _vehicles[index] = vehicle;
        }
        
        _setLoading(false);
        return vehicle;
      } else {
        _setError(response.error ?? 'Failed to load vehicle');
        _setLoading(false);
        return null;
      }
    } catch (e) {
      _setError('Error loading vehicle: $e');
      _setLoading(false);
      return null;
    }
  }
  
  Future<bool> createVehicle(CreateVehicleRequest request) async {
    _setLoading(true);
    _clearError();
    
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        '/vehicles',
        body: request.toJson(),
      );
      
      if (response.isSuccess && response.rawData != null) {
        final vehicleData = response.rawData!['data'] as Map<String, dynamic>;
        final vehicle = Vehicle.fromJson(vehicleData);
        _vehicles.insert(0, vehicle);
        _setLoading(false);
        return true;
      } else {
        _setError(response.error ?? 'Failed to create vehicle');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Error creating vehicle: $e');
      _setLoading(false);
      return false;
    }
  }
  
  Future<bool> updateVehicle(int id, Map<String, dynamic> updates) async {
    _setLoading(true);
    _clearError();
    
    try {
      final response = await _apiService.put<Map<String, dynamic>>(
        '/vehicles/$id',
        body: updates,
      );
      
      if (response.isSuccess && response.rawData != null) {
        final vehicleData = response.rawData!['data'] as Map<String, dynamic>;
        final vehicle = Vehicle.fromJson(vehicleData);
        
        // Update vehicle in list
        final index = _vehicles.indexWhere((v) => v.id == id);
        if (index != -1) {
          _vehicles[index] = vehicle;
        }
        
        if (_selectedVehicle?.id == id) {
          _selectedVehicle = vehicle;
        }
        
        _setLoading(false);
        return true;
      } else {
        _setError(response.error ?? 'Failed to update vehicle');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Error updating vehicle: $e');
      _setLoading(false);
      return false;
    }
  }
  
  Future<bool> deleteVehicle(int id) async {
    _setLoading(true);
    _clearError();
    
    try {
      final response = await _apiService.delete('/vehicles/$id');
      
      if (response.isSuccess) {
        _vehicles.removeWhere((v) => v.id == id);
        if (_selectedVehicle?.id == id) {
          _selectedVehicle = null;
        }
        _setLoading(false);
        return true;
      } else {
        _setError(response.error ?? 'Failed to delete vehicle');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Error deleting vehicle: $e');
      _setLoading(false);
      return false;
    }
  }
  
  void selectVehicle(Vehicle? vehicle) {
    _selectedVehicle = vehicle;
    notifyListeners();
  }
  
  void clearSelection() {
    _selectedVehicle = null;
    notifyListeners();
  }
  
  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }
  
  void _setError(String? error) {
    if (_error != error) {
      _error = error;
      notifyListeners();
    }
  }
  
  void _clearError() {
    _setError(null);
  }
  
  void clearError() {
    _clearError();
  }
}