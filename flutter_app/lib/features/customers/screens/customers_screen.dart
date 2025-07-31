import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/app_widgets.dart';
import '../../../shared/models/models.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  List<Customer> _customers = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Management'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: _showAddCustomer,
            icon: const Icon(Icons.add),
            tooltip: 'Add Customer',
          ),
        ],
      ),
      body: Column(
        children: [
          AppSearchBar(
            hintText: 'Search customers...',
            onChanged: (query) {
              setState(() {
                _searchQuery = query;
              });
            },
            showFilter: false,
          ),
          Expanded(
            child: _isLoading
                ? const AppLoading(message: 'Loading customers...')
                : _buildCustomersList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCustomer,
        child: const Icon(Icons.person_add),
      ),
    );
  }

  Widget _buildCustomersList() {
    final filteredCustomers = _customers.where((customer) {
      return customer.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          customer.customerCode.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (customer.phone?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
          (customer.email?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
    }).toList();

    if (filteredCustomers.isEmpty) {
      return AppEmptyState(
        message: _searchQuery.isNotEmpty
            ? 'No customers found matching your search'
            : 'No customers registered yet',
        icon: Icons.people_outlined,
        actionLabel: 'Add Customer',
        onActionTap: _showAddCustomer,
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth > AppBreakpoints.tablet;
        
        if (isTablet) {
          // Grid layout for tablet
          return GridView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: AppSpacing.gridSpacing,
              mainAxisSpacing: AppSpacing.gridSpacing,
              childAspectRatio: 1.0,
            ),
            itemCount: filteredCustomers.length,
            itemBuilder: (context, index) {
              final customer = filteredCustomers[index];
              return _buildCustomerGridCard(customer);
            },
          );
        } else {
          // List layout for mobile
          return ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: filteredCustomers.length,
            itemBuilder: (context, index) {
              final customer = filteredCustomers[index];
              return _buildCustomerListCard(customer);
            },
          );
        }
      },
    );
  }

  Widget _buildCustomerGridCard(Customer customer) {
    return AppCard(
      onTap: () => _showCustomerDetail(customer),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.primary,
                child: Text(
                  customer.name.substring(0, 1).toUpperCase(),
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.onPrimary,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xs,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: AppRadius.small,
                ),
                child: Text(
                  customer.customerCode,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            customer.name,
            style: AppTextStyles.labelLarge,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.xs),
          if (customer.phone != null)
            Row(
              children: [
                Icon(
                  Icons.phone,
                  size: AppIconSizes.xs,
                  color: AppColors.secondary,
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    customer.phone!,
                    style: AppTextStyles.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          if (customer.email != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                Icon(
                  Icons.email,
                  size: AppIconSizes.xs,
                  color: AppColors.secondary,
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    customer.email!,
                    style: AppTextStyles.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCustomerListCard(Customer customer) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      onTap: () => _showCustomerDetail(customer),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: AppColors.primary,
            child: Text(
              customer.name.substring(0, 1).toUpperCase(),
              style: AppTextStyles.h4.copyWith(
                color: AppColors.onPrimary,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        customer.name,
                        style: AppTextStyles.h4,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: AppRadius.small,
                      ),
                      child: Text(
                        customer.customerCode,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                if (customer.phone != null)
                  Row(
                    children: [
                      Icon(
                        Icons.phone,
                        size: AppIconSizes.sm,
                        color: AppColors.secondary,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        customer.phone!,
                        style: AppTextStyles.bodyMedium,
                      ),
                    ],
                  ),
                if (customer.email != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      Icon(
                        Icons.email,
                        size: AppIconSizes.sm,
                        color: AppColors.secondary,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Text(
                          customer.email!,
                          style: AppTextStyles.bodyMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
                if (customer.address != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: AppIconSizes.sm,
                        color: AppColors.secondary,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Text(
                          customer.address!,
                          style: AppTextStyles.bodySmall,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showCustomerDetail(Customer customer) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
          child: Column(
            children: [
              AppBar(
                title: Text(customer.name),
                automaticallyImplyLeading: false,
                actions: [
                  IconButton(
                    onPressed: () => _editCustomer(customer),
                    icon: const Icon(Icons.edit),
                    tooltip: 'Edit Customer',
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
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: AppColors.primary,
                        child: Text(
                          customer.name.substring(0, 1).toUpperCase(),
                          style: AppTextStyles.h1.copyWith(
                            color: AppColors.onPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      AppCard(
                        child: Column(
                          children: [
                            _buildDetailRow('Customer Code', customer.customerCode),
                            _buildDetailRow('Full Name', customer.name),
                            _buildDetailRow('Phone', customer.phone ?? '-'),
                            _buildDetailRow('Email', customer.email ?? '-'),
                            _buildDetailRow('ID Number', customer.idNumber ?? '-'),
                            _buildDetailRow('Address', customer.address ?? '-'),
                            _buildDetailRow('Registered', _formatDate(customer.createdAt)),
                            _buildDetailRow('Last Updated', _formatDate(customer.updatedAt)),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _viewTransactionHistory(customer),
                              icon: const Icon(Icons.history),
                              label: const Text('Transaction History'),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _createSaleForCustomer(customer),
                              icon: const Icon(Icons.point_of_sale),
                              label: const Text('New Sale'),
                            ),
                          ),
                        ],
                      ),
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _loadCustomers() async {
    await Future.delayed(const Duration(seconds: 1));
    
    setState(() {
      _customers = [
        Customer(
          id: '1',
          customerCode: 'C001',
          name: 'John Doe',
          phone: '081234567890',
          email: 'john.doe@example.com',
          address: 'Jl. Sudirman No. 123, Jakarta Pusat',
          idNumber: '3171234567890001',
          createdAt: DateTime.now().subtract(const Duration(days: 30)),
          updatedAt: DateTime.now().subtract(const Duration(days: 5)),
        ),
        Customer(
          id: '2',
          customerCode: 'C002',
          name: 'Jane Smith',
          phone: '082345678901',
          email: 'jane.smith@example.com',
          address: 'Jl. Thamrin No. 456, Jakarta Pusat',
          idNumber: '3171234567890002',
          createdAt: DateTime.now().subtract(const Duration(days: 25)),
          updatedAt: DateTime.now().subtract(const Duration(days: 3)),
        ),
        Customer(
          id: '3',
          customerCode: 'C003',
          name: 'Bob Johnson',
          phone: '083456789012',
          email: 'bob.johnson@example.com',
          address: 'Jl. Kuningan No. 789, Jakarta Selatan',
          createdAt: DateTime.now().subtract(const Duration(days: 20)),
          updatedAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
        Customer(
          id: '4',
          customerCode: 'C004',
          name: 'Alice Brown',
          phone: '084567890123',
          address: 'Jl. Kemang No. 321, Jakarta Selatan',
          createdAt: DateTime.now().subtract(const Duration(days: 15)),
          updatedAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
      ];
      _isLoading = false;
    });
  }

  void _showAddCustomer() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Add Customer feature will include form validation and auto-generated customer code'),
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _editCustomer(Customer customer) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Edit ${customer.name} feature coming soon'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _viewTransactionHistory(Customer customer) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Transaction history for ${customer.name} coming soon'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _createSaleForCustomer(Customer customer) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Creating sale for ${customer.name}...'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}