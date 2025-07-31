import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/app_widgets.dart';
import '../../../shared/models/models.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  List<SalesInvoice> _sales = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadSales();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales Management'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: _showCreateSale,
            icon: const Icon(Icons.add),
            tooltip: 'Create Sale',
          ),
        ],
      ),
      body: Column(
        children: [
          AppSearchBar(
            hintText: 'Search sales...',
            onChanged: (query) {
              setState(() {
                _searchQuery = query;
              });
            },
            showFilter: false,
          ),
          Expanded(
            child: _isLoading
                ? const AppLoading(message: 'Loading sales...')
                : _buildSalesList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateSale,
        child: const Icon(Icons.point_of_sale),
      ),
    );
  }

  Widget _buildSalesList() {
    final filteredSales = _sales.where((sale) {
      return sale.invoiceNumber.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (sale.customer?.name.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
          (sale.vehicle?.name.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
    }).toList();

    if (filteredSales.isEmpty) {
      return AppEmptyState(
        message: _searchQuery.isNotEmpty
            ? 'No sales found matching your search'
            : 'No sales recorded yet',
        icon: Icons.receipt_long_outlined,
        actionLabel: 'Create Sale',
        onActionTap: _showCreateSale,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: filteredSales.length,
      itemBuilder: (context, index) {
        final sale = filteredSales[index];
        return _buildSaleCard(sale);
      },
    );
  }

  Widget _buildSaleCard(SalesInvoice sale) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      onTap: () => _showSaleDetail(sale),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sale.invoiceNumber,
                      style: AppTextStyles.h4,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Customer: ${sale.customer?.name ?? 'Unknown'}',
                      style: AppTextStyles.bodyMedium,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Rp ${_formatCurrency(sale.sellingPrice)}',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: AppRadius.small,
                    ),
                    child: Text(
                      'Profit: Rp ${_formatCurrency(sale.profit)}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Icon(
                Icons.directions_car,
                size: AppIconSizes.sm,
                color: AppColors.secondary,
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  sale.vehicle?.name ?? 'Vehicle not found',
                  style: AppTextStyles.bodyMedium,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: _getPaymentMethodColor(sale.paymentMethod).withOpacity(0.1),
                  borderRadius: AppRadius.small,
                ),
                child: Text(
                  sale.paymentMethod.toUpperCase(),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: _getPaymentMethodColor(sale.paymentMethod),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: AppIconSizes.sm,
                color: AppColors.secondary,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                _formatDate(sale.createdAt),
                style: AppTextStyles.bodySmall,
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () => _generatePDF(sale),
                icon: const Icon(Icons.picture_as_pdf, size: AppIconSizes.sm),
                label: const Text('PDF'),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showSaleDetail(SalesInvoice sale) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
          child: Column(
            children: [
              AppBar(
                title: Text('Sale ${sale.invoiceNumber}'),
                automaticallyImplyLeading: false,
                actions: [
                  IconButton(
                    onPressed: () => _generatePDF(sale),
                    icon: const Icon(Icons.picture_as_pdf),
                    tooltip: 'Generate PDF',
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailSection('Sale Information', [
                        _buildDetailRow('Invoice Number', sale.invoiceNumber),
                        _buildDetailRow('Date', _formatDate(sale.createdAt)),
                        _buildDetailRow('Payment Method', sale.paymentMethod.toUpperCase()),
                      ]),
                      
                      const SizedBox(height: AppSpacing.lg),
                      
                      _buildDetailSection('Customer Information', [
                        _buildDetailRow('Name', sale.customer?.name ?? 'Unknown'),
                        _buildDetailRow('Phone', sale.customer?.phone ?? '-'),
                        _buildDetailRow('Email', sale.customer?.email ?? '-'),
                        _buildDetailRow('Address', sale.customer?.address ?? '-'),
                      ]),
                      
                      const SizedBox(height: AppSpacing.lg),
                      
                      _buildDetailSection('Vehicle Information', [
                        _buildDetailRow('Name', sale.vehicle?.name ?? 'Unknown'),
                        _buildDetailRow('Brand', sale.vehicle?.brand ?? '-'),
                        _buildDetailRow('Year', sale.vehicle?.year.toString() ?? '-'),
                        _buildDetailRow('License Plate', sale.vehicle?.licensePlate ?? '-'),
                      ]),
                      
                      const SizedBox(height: AppSpacing.lg),
                      
                      _buildDetailSection('Financial Information', [
                        _buildDetailRow('Selling Price', 'Rp ${_formatCurrency(sale.sellingPrice)}'),
                        _buildDetailRow('Vehicle HPP', 'Rp ${_formatCurrency(sale.vehicle?.hpp ?? 0)}'),
                        _buildDetailRow('Profit', 'Rp ${_formatCurrency(sale.profit)}'),
                      ]),
                      
                      if (sale.notes != null) ...[
                        const SizedBox(height: AppSpacing.lg),
                        _buildDetailSection('Notes', [
                          Text(
                            sale.notes!,
                            style: AppTextStyles.bodyMedium,
                          ),
                        ]),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.h4,
        ),
        const SizedBox(height: AppSpacing.sm),
        AppCard(
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: AppTextStyles.labelMedium,
            ),
          ),
          const Text(': '),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Color _getPaymentMethodColor(String method) {
    switch (method.toLowerCase()) {
      case 'cash':
        return AppColors.success;
      case 'transfer':
        return AppColors.primary;
      default:
        return AppColors.secondary;
    }
  }

  String _formatCurrency(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _loadSales() async {
    await Future.delayed(const Duration(seconds: 1));
    
    setState(() {
      _sales = [
        SalesInvoice(
          id: '1',
          invoiceNumber: 'SAL-20240731-001',
          customerId: '1',
          vehicleId: '1',
          sellingPrice: 200000000,
          profit: 15000000,
          paymentMethod: 'transfer',
          customer: Customer(
            id: '1',
            customerCode: 'C001',
            name: 'John Doe',
            phone: '081234567890',
            email: 'john@example.com',
            address: 'Jakarta',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          vehicle: Vehicle(
            id: '1',
            vehicleCategoryId: '1',
            name: 'Toyota Avanza G',
            brand: 'Toyota',
            model: 'Avanza',
            year: 2023,
            color: 'Silver',
            licensePlate: 'B 1234 ABC',
            engineNumber: 'ENG123456',
            chassisNumber: 'CHS789012',
            purchasePrice: 180000000,
            repairCost: 5000000,
            sellingPrice: 200000000,
            hpp: 185000000,
            status: 'sold',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];
      _isLoading = false;
    });
  }

  void _showCreateSale() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Create Sale feature will include customer selection, vehicle selection, and PDF generation'),
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _generatePDF(SalesInvoice sale) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Generating PDF for ${sale.invoiceNumber}...'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}