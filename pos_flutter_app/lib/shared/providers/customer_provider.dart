import 'package:flutter/material.dart';
import '../../core/services/api_service.dart';
import '../../core/constants/app_constants.dart';
import '../models/customer_model.dart';

class CustomerProvider extends ChangeNotifier {
  final ApiService _apiService;
  
  List<Customer> _customers = [];
  Customer? _selectedCustomer;
  bool _isLoading = false;
  String? _error;
  PaginationInfo? _pagination;
  
  CustomerProvider(this._apiService);
  
  // Getters
  List<Customer> get customers => _customers;
  Customer? get selectedCustomer => _selectedCustomer;
  bool get isLoading => _isLoading;
  String? get error => _error;
  PaginationInfo? get pagination => _pagination;
  
  Future<void> loadCustomers({
    int page = 1,
    int limit = AppConstants.defaultPageSize,
    String? search,
    bool refresh = false,
  }) async {
    if (refresh || page == 1) {
      _customers.clear();
    }
    
    _setLoading(true);
    _clearError();
    
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };
      
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      
      final response = await _apiService.get<List<dynamic>>(
        '/customers',
        queryParams: queryParams,
      );
      
      if (response.isSuccess && response.rawData != null) {
        final data = response.rawData!['data'] as List<dynamic>;
        final newCustomers = data
            .map((c) => Customer.fromJson(c as Map<String, dynamic>))
            .toList();
        
        if (page == 1) {
          _customers = newCustomers;
        } else {
          _customers.addAll(newCustomers);
        }
        
        // Update pagination info
        if (response.rawData!.containsKey('pagination')) {
          _pagination = PaginationInfo.fromJson(
            response.rawData!['pagination'] as Map<String, dynamic>
          );
        }
      } else {
        _setError(response.error ?? 'Failed to load customers');
      }
    } catch (e) {
      _setError('Error loading customers: $e');
    }
    
    _setLoading(false);
  }
  
  Future<Customer?> getCustomer(int id) async {
    _setLoading(true);
    _clearError();
    
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        '/customers/$id',
      );
      
      if (response.isSuccess && response.rawData != null) {
        final customerData = response.rawData!['data'] as Map<String, dynamic>;
        final customer = Customer.fromJson(customerData);
        _selectedCustomer = customer;
        
        // Update customer in list if exists
        final index = _customers.indexWhere((c) => c.id == id);
        if (index != -1) {
          _customers[index] = customer;
        }
        
        _setLoading(false);
        return customer;
      } else {
        _setError(response.error ?? 'Failed to load customer');
        _setLoading(false);
        return null;
      }
    } catch (e) {
      _setError('Error loading customer: $e');
      _setLoading(false);
      return null;
    }
  }
  
  Future<bool> createCustomer(CreateCustomerRequest request) async {
    _setLoading(true);
    _clearError();
    
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        '/customers',
        body: request.toJson(),
      );
      
      if (response.isSuccess && response.rawData != null) {
        final customerData = response.rawData!['data'] as Map<String, dynamic>;
        final customer = Customer.fromJson(customerData);
        _customers.insert(0, customer);
        _setLoading(false);
        return true;
      } else {
        _setError(response.error ?? 'Failed to create customer');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Error creating customer: $e');
      _setLoading(false);
      return false;
    }
  }
  
  Future<bool> updateCustomer(int id, Map<String, dynamic> updates) async {
    _setLoading(true);
    _clearError();
    
    try {
      final response = await _apiService.put<Map<String, dynamic>>(
        '/customers/$id',
        body: updates,
      );
      
      if (response.isSuccess && response.rawData != null) {
        final customerData = response.rawData!['data'] as Map<String, dynamic>;
        final customer = Customer.fromJson(customerData);
        
        // Update customer in list
        final index = _customers.indexWhere((c) => c.id == id);
        if (index != -1) {
          _customers[index] = customer;
        }
        
        if (_selectedCustomer?.id == id) {
          _selectedCustomer = customer;
        }
        
        _setLoading(false);
        return true;
      } else {
        _setError(response.error ?? 'Failed to update customer');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Error updating customer: $e');
      _setLoading(false);
      return false;
    }
  }
  
  Future<bool> deleteCustomer(int id) async {
    _setLoading(true);
    _clearError();
    
    try {
      final response = await _apiService.delete('/customers/$id');
      
      if (response.isSuccess) {
        _customers.removeWhere((c) => c.id == id);
        if (_selectedCustomer?.id == id) {
          _selectedCustomer = null;
        }
        _setLoading(false);
        return true;
      } else {
        _setError(response.error ?? 'Failed to delete customer');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Error deleting customer: $e');
      _setLoading(false);
      return false;
    }
  }
  
  void selectCustomer(Customer? customer) {
    _selectedCustomer = customer;
    notifyListeners();
  }
  
  void clearSelection() {
    _selectedCustomer = null;
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