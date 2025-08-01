import 'package:flutter/foundation.dart';
import '../../core/services/api_service.dart';
import '../../core/config/app_config.dart';
import '../models/vehicle_model.dart';

class VehicleProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<Vehicle> _vehicles = [];
  List<VehicleCategory> _categories = [];
  Vehicle? _selectedVehicle;
  bool _isLoading = false;
  String? _error;
  
  // Pagination
  int _currentPage = 1;
  int _totalPages = 1;
  bool _hasMore = true;
  
  // Filters
  String _searchQuery = '';
  String? _statusFilter;
  String? _brandFilter;
  String? _categoryFilter;

  // Getters
  List<Vehicle> get vehicles => _vehicles;
  List<VehicleCategory> get categories => _categories;
  Vehicle? get selectedVehicle => _selectedVehicle;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMore => _hasMore;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  String get searchQuery => _searchQuery;
  String? get statusFilter => _statusFilter;
  String? get brandFilter => _brandFilter;
  String? get categoryFilter => _categoryFilter;

  // Load vehicles with pagination and filters
  Future<void> loadVehicles({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _vehicles.clear();
      _hasMore = true;
    }

    if (_isLoading || !_hasMore) return;

    _setLoading(true);
    _clearError();

    try {
      final queryParams = <String, String>{
        'page': _currentPage.toString(),
        'limit': '20',
      };

      if (_searchQuery.isNotEmpty) {
        queryParams['search'] = _searchQuery;
      }
      if (_statusFilter != null) {
        queryParams['status'] = _statusFilter!;
      }
      if (_brandFilter != null) {
        queryParams['brand'] = _brandFilter!;
      }
      if (_categoryFilter != null) {
        queryParams['category_id'] = _categoryFilter!;
      }

      final response = await _apiService.get(
        AppConfig.vehiclesEndpoint,
        queryParams: queryParams,
      );

      final data = response['data'] as Map<String, dynamic>;
      final vehicleList = data['vehicles'] as List<dynamic>;
      final pagination = data['pagination'] as Map<String, dynamic>;

      final newVehicles = vehicleList
          .map((json) => Vehicle.fromJson(json as Map<String, dynamic>))
          .toList();

      if (refresh) {
        _vehicles = newVehicles;
      } else {
        _vehicles.addAll(newVehicles);
      }

      _currentPage = (pagination['page'] as num).toInt();
      _totalPages = (pagination['total_pages'] as num).toInt();
      _hasMore = _currentPage < _totalPages;

      notifyListeners();
    } catch (e) {
      _setError('Failed to load vehicles: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Load next page
  Future<void> loadMore() async {
    if (_hasMore && !_isLoading) {
      _currentPage++;
      await loadVehicles();
    }
  }

  // Get vehicle by ID
  Future<Vehicle?> getVehicle(String id) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _apiService.get('${AppConfig.vehiclesEndpoint}/$id');
      final vehicleData = response['data'] as Map<String, dynamic>;
      final vehicle = Vehicle.fromJson(vehicleData);
      
      _selectedVehicle = vehicle;
      notifyListeners();
      return vehicle;
    } catch (e) {
      _setError('Failed to load vehicle: ${e.toString()}');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Create vehicle
  Future<Vehicle?> createVehicle(Map<String, dynamic> vehicleData) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _apiService.post(
        AppConfig.vehiclesEndpoint,
        vehicleData,
      );

      final newVehicleData = response['data'] as Map<String, dynamic>;
      final newVehicle = Vehicle.fromJson(newVehicleData);
      
      _vehicles.insert(0, newVehicle);
      notifyListeners();
      return newVehicle;
    } catch (e) {
      _setError('Failed to create vehicle: ${e.toString()}');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Update vehicle
  Future<Vehicle?> updateVehicle(String id, Map<String, dynamic> vehicleData) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _apiService.put(
        '${AppConfig.vehiclesEndpoint}/$id',
        vehicleData,
      );

      final updatedVehicleData = response['data'] as Map<String, dynamic>;
      final updatedVehicle = Vehicle.fromJson(updatedVehicleData);
      
      final index = _vehicles.indexWhere((v) => v.id == id);
      if (index != -1) {
        _vehicles[index] = updatedVehicle;
      }
      
      if (_selectedVehicle?.id == id) {
        _selectedVehicle = updatedVehicle;
      }
      
      notifyListeners();
      return updatedVehicle;
    } catch (e) {
      _setError('Failed to update vehicle: ${e.toString()}');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Upload vehicle photo
  Future<bool> uploadVehiclePhoto(String vehicleId, String photoPath) async {
    _setLoading(true);
    _clearError();

    try {
      await _apiService.uploadFile(
        '${AppConfig.vehiclePhotosEndpoint}/$vehicleId/photo',
        photoPath,
        'photo',
      );

      // Reload vehicle to get updated photos
      await getVehicle(vehicleId);
      return true;
    } catch (e) {
      _setError('Failed to upload photo: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Load categories
  Future<void> loadCategories() async {
    try {
      final response = await _apiService.get('/vehicle-categories');
      final categoriesList = response['data'] as List<dynamic>;
      
      _categories = categoriesList
          .map((json) => VehicleCategory.fromJson(json as Map<String, dynamic>))
          .toList();
      
      notifyListeners();
    } catch (e) {
      _setError('Failed to load categories: ${e.toString()}');
    }
  }

  // Search and filter methods
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setStatusFilter(String? status) {
    _statusFilter = status;
    notifyListeners();
  }

  void setBrandFilter(String? brand) {
    _brandFilter = brand;
    notifyListeners();
  }

  void setCategoryFilter(String? categoryId) {
    _categoryFilter = categoryId;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _statusFilter = null;
    _brandFilter = null;
    _categoryFilter = null;
    notifyListeners();
  }

  // Apply filters and search
  Future<void> applyFilters() async {
    await loadVehicles(refresh: true);
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  void clearSelectedVehicle() {
    _selectedVehicle = null;
    notifyListeners();
  }

  // Get available vehicles for sales
  List<Vehicle> get availableVehicles {
    return _vehicles.where((v) => v.isAvailable).toList();
  }

  // Get distinct brands
  List<String> get distinctBrands {
    return _vehicles.map((v) => v.brand).toSet().toList()..sort();
  }
}