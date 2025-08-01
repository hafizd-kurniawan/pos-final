import 'package:flutter/foundation.dart';
import '../../core/services/api_service.dart';
import '../../core/config/app_config.dart';
import '../models/customer_model.dart';

class CustomerProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<Customer> _customers = [];
  Customer? _selectedCustomer;
  bool _isLoading = false;
  String? _error;
  
  // Pagination
  int _currentPage = 1;
  int _totalPages = 1;
  bool _hasMore = true;
  
  // Search
  String _searchQuery = '';

  // Getters
  List<Customer> get customers => _customers;
  Customer? get selectedCustomer => _selectedCustomer;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMore => _hasMore;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  String get searchQuery => _searchQuery;

  // Load customers with pagination and search
  Future<void> loadCustomers({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _customers.clear();
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

      final response = await _apiService.get(
        AppConfig.customersEndpoint,
        queryParams: queryParams,
      );

      final data = response['data'] as Map<String, dynamic>;
      final customerList = data['customers'] as List<dynamic>;
      final pagination = data['pagination'] as Map<String, dynamic>;

      final newCustomers = customerList
          .map((json) => Customer.fromJson(json as Map<String, dynamic>))
          .toList();

      if (refresh) {
        _customers = newCustomers;
      } else {
        _customers.addAll(newCustomers);
      }

      _currentPage = (pagination['page'] as num).toInt();
      _totalPages = (pagination['total_pages'] as num).toInt();
      _hasMore = _currentPage < _totalPages;

      notifyListeners();
    } catch (e) {
      _setError('Failed to load customers: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Load next page
  Future<void> loadMore() async {
    if (_hasMore && !_isLoading) {
      _currentPage++;
      await loadCustomers();
    }
  }

  // Get customer by ID
  Future<Customer?> getCustomer(String id) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _apiService.get('${AppConfig.customersEndpoint}/$id');
      final customerData = response['data'] as Map<String, dynamic>;
      final customer = Customer.fromJson(customerData);
      
      _selectedCustomer = customer;
      notifyListeners();
      return customer;
    } catch (e) {
      _setError('Failed to load customer: ${e.toString()}');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Create customer
  Future<Customer?> createCustomer(Map<String, dynamic> customerData) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _apiService.post(
        AppConfig.customersEndpoint,
        customerData,
      );

      final newCustomerData = response['data'] as Map<String, dynamic>;
      final newCustomer = Customer.fromJson(newCustomerData);
      
      _customers.insert(0, newCustomer);
      notifyListeners();
      return newCustomer;
    } catch (e) {
      _setError('Failed to create customer: ${e.toString()}');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Update customer
  Future<Customer?> updateCustomer(String id, Map<String, dynamic> customerData) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _apiService.put(
        '${AppConfig.customersEndpoint}/$id',
        customerData,
      );

      final updatedCustomerData = response['data'] as Map<String, dynamic>;
      final updatedCustomer = Customer.fromJson(updatedCustomerData);
      
      final index = _customers.indexWhere((c) => c.id == id);
      if (index != -1) {
        _customers[index] = updatedCustomer;
      }
      
      if (_selectedCustomer?.id == id) {
        _selectedCustomer = updatedCustomer;
      }
      
      notifyListeners();
      return updatedCustomer;
    } catch (e) {
      _setError('Failed to update customer: ${e.toString()}');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Delete customer
  Future<bool> deleteCustomer(String id) async {
    _setLoading(true);
    _clearError();

    try {
      await _apiService.delete('${AppConfig.customersEndpoint}/$id');
      
      _customers.removeWhere((c) => c.id == id);
      
      if (_selectedCustomer?.id == id) {
        _selectedCustomer = null;
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to delete customer: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Search customers
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // Apply search
  Future<void> search() async {
    await loadCustomers(refresh: true);
  }

  // Clear search
  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
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

  void clearSelectedCustomer() {
    _selectedCustomer = null;
    notifyListeners();
  }

  // Find customer by name or phone
  Customer? findCustomer(String query) {
    final lowerQuery = query.toLowerCase();
    return _customers.firstWhere(
      (c) => 
        c.name.toLowerCase().contains(lowerQuery) ||
        (c.phone?.toLowerCase().contains(lowerQuery) ?? false) ||
        (c.email?.toLowerCase().contains(lowerQuery) ?? false),
      orElse: () => Customer(
        id: '',
        name: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
  }

  // Get customers for dropdown/selection
  List<Customer> get customersForSelection {
    return _customers.where((c) => c.name.isNotEmpty).toList();
  }
}