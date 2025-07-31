import 'package:flutter/material.dart';
import '../models/sales_model.dart';
import '../models/customer_model.dart';
import '../models/vehicle_model.dart';
import '../../core/services/api_service.dart';
import '../../core/constants/app_constants.dart';

class SalesProvider extends ChangeNotifier {
  final ApiService _apiService;
  
  List<SalesInvoice> _salesInvoices = [];
  SalesInvoice? _selectedInvoice;
  bool _isLoading = false;
  String? _error;
  PaginationInfo? _pagination;
  
  SalesProvider(this._apiService);
  
  // Getters
  List<SalesInvoice> get salesInvoices => _salesInvoices;
  SalesInvoice? get selectedInvoice => _selectedInvoice;
  bool get isLoading => _isLoading;
  String? get error => _error;
  PaginationInfo? get pagination => _pagination;
  
  // Load sales invoices with optional filtering by customer
  Future<void> loadSalesInvoices({
    int page = 1,
    int limit = AppConstants.defaultPageSize,
    int? customerId,
    bool refresh = false,
  }) async {
    if (refresh || page == 1) {
      _salesInvoices.clear();
    }
    
    _setLoading(true);
    _clearError();
    
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };
      
      if (customerId != null) {
        queryParams['customer_id'] = customerId;
      }
      
      final response = await _apiService.get<List<dynamic>>(
        '/sales',
        queryParams: queryParams,
      );
      
      if (response.isSuccess && response.rawData != null) {
        final data = response.rawData!['data'] as List<dynamic>;
        final newInvoices = data
            .map((invoice) => SalesInvoice.fromJson(invoice as Map<String, dynamic>))
            .toList();
        
        if (page == 1) {
          _salesInvoices = newInvoices;
        } else {
          _salesInvoices.addAll(newInvoices);
        }
        
        // Update pagination info
        if (response.rawData!.containsKey('pagination')) {
          _pagination = PaginationInfo.fromJson(
            response.rawData!['pagination'] as Map<String, dynamic>
          );
        }
      } else {
        final errorMessage = response.error ?? 'Failed to load sales invoices';
        print('Sales API Error: $errorMessage');
        
        // If it's a network connectivity issue, don't show a harsh error
        if (errorMessage.toLowerCase().contains('network') || 
            errorMessage.toLowerCase().contains('connect') ||
            errorMessage.toLowerCase().contains('timeout')) {
          _setError('Unable to connect to server. Please check your connection and try again.');
        } else {
          _setError(errorMessage);
        }
      }
    } catch (e) {
      print('Sales Provider Error: $e');
      _setError('Unable to load sales data. Please try again later.');
    }
    
    _setLoading(false);
  }
  
  // Get specific sales invoice
  Future<SalesInvoice?> getSalesInvoice(int id) async {
    _setLoading(true);
    _clearError();
    
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        '/sales/$id',
      );
      
      if (response.isSuccess && response.rawData != null) {
        final invoiceData = response.rawData!['data'] as Map<String, dynamic>;
        final invoice = SalesInvoice.fromJson(invoiceData);
        _selectedInvoice = invoice;
        
        // Update invoice in list if exists
        final index = _salesInvoices.indexWhere((inv) => inv.id == id);
        if (index != -1) {
          _salesInvoices[index] = invoice;
        }
        
        _setLoading(false);
        return invoice;
      } else {
        _setError(response.error ?? 'Failed to load sales invoice');
        _setLoading(false);
        return null;
      }
    } catch (e) {
      _setError('Error loading sales invoice: $e');
      _setLoading(false);
      return null;
    }
  }
  
  // Create new sales invoice
  Future<bool> createSalesInvoice(CreateSalesRequest request) async {
    _setLoading(true);
    _clearError();
    
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        '/sales',
        body: request.toJson(),
      );
      
      if (response.isSuccess && response.rawData != null) {
        final invoiceData = response.rawData!['data'] as Map<String, dynamic>;
        final invoice = SalesInvoice.fromJson(invoiceData);
        _salesInvoices.insert(0, invoice);
        _selectedInvoice = invoice;
        _setLoading(false);
        return true;
      } else {
        _setError(response.error ?? 'Failed to create sales invoice');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Error creating sales invoice: $e');
      _setLoading(false);
      return false;
    }
  }
  
  // Upload transfer proof for invoice
  Future<bool> uploadTransferProof(int invoiceId, String filePath) async {
    _setLoading(true);
    _clearError();
    
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        '/sales/$invoiceId/transfer-proof',
        body: {'file_path': filePath},
      );
      
      if (response.isSuccess) {
        // Reload the invoice to get updated data
        await getSalesInvoice(invoiceId);
        _setLoading(false);
        return true;
      } else {
        _setError(response.error ?? 'Failed to upload transfer proof');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Error uploading transfer proof: $e');
      _setLoading(false);
      return false;
    }
  }
  
  // Generate PDF invoice
  Future<String?> generateInvoicePDF(int invoiceId) async {
    _setLoading(true);
    _clearError();
    
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        '/pdf/sales/$invoiceId',
      );
      
      if (response.isSuccess && response.rawData != null) {
        final pdfUrl = response.rawData!['pdf_url'] as String?;
        _setLoading(false);
        return pdfUrl;
      } else {
        _setError(response.error ?? 'Failed to generate PDF');
        _setLoading(false);
        return null;
      }
    } catch (e) {
      _setError('Error generating PDF: $e');
      _setLoading(false);
      return null;
    }
  }
  
  // Calculate sales statistics
  Map<String, dynamic> getSalesStatistics() {
    if (_salesInvoices.isEmpty) {
      return {
        'total_invoices': 0,
        'total_revenue': 0.0,
        'average_sale': 0.0,
        'cash_sales': 0,
        'transfer_sales': 0,
      };
    }
    
    final totalRevenue = _salesInvoices.fold<double>(
      0.0, 
      (sum, invoice) => sum + invoice.sellingPrice,
    );
    
    final cashSales = _salesInvoices.where((inv) => inv.paymentMethod == 'cash').length;
    final transferSales = _salesInvoices.where((inv) => inv.paymentMethod == 'transfer').length;
    
    return {
      'total_invoices': _salesInvoices.length,
      'total_revenue': totalRevenue,
      'average_sale': totalRevenue / _salesInvoices.length,
      'cash_sales': cashSales,
      'transfer_sales': transferSales,
    };
  }
  
  void selectInvoice(SalesInvoice? invoice) {
    _selectedInvoice = invoice;
    notifyListeners();
  }
  
  void clearSelection() {
    _selectedInvoice = null;
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