import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_theme.dart';
import '../../../shared/providers/customer_provider.dart';
import '../../../shared/models/customer_model.dart';
import '../widgets/customer_card.dart';
import '../widgets/add_customer_sheet.dart';

class CustomerGridScreen extends StatefulWidget {
  const CustomerGridScreen({super.key});

  @override
  State<CustomerGridScreen> createState() => _CustomerGridScreenState();
}

class _CustomerGridScreenState extends State<CustomerGridScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCustomers();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      final customerProvider = context.read<CustomerProvider>();
      customerProvider.loadMore();
    }
  }

  Future<void> _loadCustomers() async {
    final customerProvider = context.read<CustomerProvider>();
    await customerProvider.loadCustomers(refresh: true);
  }

  void _onSearchChanged(String query) {
    final customerProvider = context.read<CustomerProvider>();
    customerProvider.setSearchQuery(query);
  }

  Future<void> _applySearch() async {
    final customerProvider = context.read<CustomerProvider>();
    await customerProvider.search();
  }

  void _showAddCustomerSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddCustomerSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search and Add Bar
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border(
              bottom: BorderSide(
                color: AppColors.border,
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              // Search Field
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search customers by name, phone, or email...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _onSearchChanged('');
                              _applySearch();
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onChanged: _onSearchChanged,
                  onSubmitted: (_) => _applySearch(),
                ),
              ),
              
              const SizedBox(width: 8),
              
              // Add Customer Button
              ElevatedButton.icon(
                onPressed: _showAddCustomerSheet,
                icon: const Icon(Icons.add),
                label: const Text('Add Customer'),
              ),
            ],
          ),
        ),

        // Customer Grid
        Expanded(
          child: Consumer<CustomerProvider>(
            builder: (context, customerProvider, _) {
              if (customerProvider.isLoading && customerProvider.customers.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (customerProvider.error != null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: AppColors.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading customers',
                        style: AppTextStyles.cardTitle,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        customerProvider.error!,
                        style: AppTextStyles.cardSubtitle,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadCustomers,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              if (customerProvider.customers.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 48,
                        color: AppColors.textTertiary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No customers found',
                        style: AppTextStyles.cardTitle,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add your first customer to get started',
                        style: AppTextStyles.cardSubtitle,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _showAddCustomerSheet,
                        icon: const Icon(Icons.add),
                        label: const Text('Add Customer'),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: _loadCustomers,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // Responsive grid columns
                    int crossAxisCount;
                    if (constraints.maxWidth > 1200) {
                      crossAxisCount = 4; // Desktop/Tablet landscape
                    } else if (constraints.maxWidth > 800) {
                      crossAxisCount = 3; // Tablet portrait
                    } else if (constraints.maxWidth > 600) {
                      crossAxisCount = 2; // Large phone landscape
                    } else {
                      crossAxisCount = 1; // Phone portrait
                    }

                    return GridView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1.2, // Adjust for card height
                      ),
                      itemCount: customerProvider.customers.length + 
                          (customerProvider.hasMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == customerProvider.customers.length) {
                          // Loading indicator for pagination
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        final customer = customerProvider.customers[index];
                        return CustomerCard(
                          customer: customer,
                          onTap: () => _showCustomerDetail(customer),
                        );
                      },
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showCustomerDetail(Customer customer) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: 500,
          height: 400,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Customer Details',
                    style: AppTextStyles.sidebarTitle,
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () {
                          Navigator.of(context).pop();
                          _editCustomer(customer);
                        },
                        tooltip: 'Edit Customer',
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Customer Info
                      _buildDetailRow('Name', customer.name),
                      if (customer.hasEmail)
                        _buildDetailRow('Email', customer.email!),
                      if (customer.hasPhone)
                        _buildDetailRow('Phone', customer.phone!),
                      if (customer.hasAddress)
                        _buildDetailRow('Address', customer.address!),
                      _buildDetailRow(
                        'Created',
                        _formatDate(customer.createdAt),
                      ),
                      _buildDetailRow(
                        'Last Updated',
                        _formatDate(customer.updatedAt),
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

  void _editCustomer(Customer customer) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddCustomerSheet(customer: customer),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: AppTextStyles.cardSubtitle.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.cardSubtitle,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}