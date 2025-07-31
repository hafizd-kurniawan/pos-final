import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_theme.dart';
import '../../core/widgets/dashboard_layout.dart';
import '../../shared/providers/sales_provider.dart';
import '../../shared/providers/customer_provider.dart';
import '../../shared/providers/vehicle_provider.dart';
import '../../shared/models/sales_model.dart';
import '../../shared/models/customer_model.dart';
import '../../shared/models/vehicle_model.dart';

class CreateSalesScreen extends StatefulWidget {
  const CreateSalesScreen({super.key});

  @override
  State<CreateSalesScreen> createState() => _CreateSalesScreenState();
}

class _CreateSalesScreenState extends State<CreateSalesScreen> {
  final _formKey = GlobalKey<FormState>();
  final _priceController = TextEditingController();
  final _notesController = TextEditingController();
  
  Customer? _selectedCustomer;
  Vehicle? _selectedVehicle;
  String _paymentMethod = 'cash';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CustomerProvider>().loadCustomers(refresh: true);
      context.read<VehicleProvider>().loadVehicles(
        refresh: true,
        status: 'available', // Only show available vehicles
      );
    });
  }

  @override
  void dispose() {
    _priceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DashboardLayout(
      title: 'Create New Sale',
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        const SizedBox(width: AppSpacing.md),
        ElevatedButton(
          onPressed: _isLoading ? null : _submitSale,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Create Sale'),
        ),
      ],
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCustomerSelection(),
              const SizedBox(height: AppSpacing.lg),
              _buildVehicleSelection(),
              const SizedBox(height: AppSpacing.lg),
              _buildPriceAndPayment(),
              const SizedBox(height: AppSpacing.lg),
              _buildNotesSection(),
              const SizedBox(height: AppSpacing.xl),
              _buildSummaryCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomerSelection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.person, color: AppColors.primary),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Customer Selection',
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Consumer<CustomerProvider>(
              builder: (context, customerProvider, child) {
                if (customerProvider.isLoading) {
                  return const LinearProgressIndicator();
                }

                if (customerProvider.error != null) {
                  return Column(
                    children: [
                      Text(
                        'Error loading customers: ${customerProvider.error}',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      TextButton(
                        onPressed: () {
                          customerProvider.loadCustomers(refresh: true);
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  );
                }

                return DropdownButtonFormField<Customer>(
                  value: _selectedCustomer,
                  decoration: const InputDecoration(
                    labelText: 'Select Customer *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  items: customerProvider.customers.map((customer) {
                    return DropdownMenuItem<Customer>(
                      value: customer,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(customer.name),
                          Text(
                            customer.phone ?? 'No phone',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (customer) {
                    setState(() {
                      _selectedCustomer = customer;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a customer';
                    }
                    return null;
                  },
                );
              },
            ),
            const SizedBox(height: AppSpacing.sm),
            TextButton.icon(
              onPressed: () {
                // TODO: Navigate to add customer screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Add Customer feature coming soon'),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Add New Customer'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleSelection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.directions_car, color: AppColors.primary),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Vehicle Selection',
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Consumer<VehicleProvider>(
              builder: (context, vehicleProvider, child) {
                if (vehicleProvider.isLoading) {
                  return const LinearProgressIndicator();
                }

                if (vehicleProvider.error != null) {
                  return Column(
                    children: [
                      Text(
                        'Error loading vehicles: ${vehicleProvider.error}',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      TextButton(
                        onPressed: () {
                          vehicleProvider.loadVehicles(
                            refresh: true,
                            status: 'available',
                          );
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  );
                }

                final availableVehicles = vehicleProvider.availableVehicles;

                return DropdownButtonFormField<Vehicle>(
                  value: _selectedVehicle,
                  decoration: const InputDecoration(
                    labelText: 'Select Vehicle *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.directions_car),
                  ),
                  items: availableVehicles.map((vehicle) {
                    return DropdownMenuItem<Vehicle>(
                      value: vehicle,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('${vehicle.brand} ${vehicle.model}'),
                          Text(
                            '${vehicle.year} - Rp ${_formatCurrency(vehicle.sellingPrice ?? 0)}',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (vehicle) {
                    setState(() {
                      _selectedVehicle = vehicle;
                      if (vehicle != null) {
                        _priceController.text = (vehicle.sellingPrice ?? 0).toStringAsFixed(0);
                      }
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a vehicle';
                    }
                    return null;
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceAndPayment() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.attach_money, color: AppColors.primary),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Price & Payment',
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _priceController,
              decoration: const InputDecoration(
                labelText: 'Selling Price *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
                prefixText: 'Rp ',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                TextInputFormatter.withFunction((oldValue, newValue) {
                  if (newValue.text.isEmpty) return newValue;
                  final number = int.tryParse(newValue.text);
                  if (number == null) return oldValue;
                  return newValue;
                }),
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter selling price';
                }
                final price = double.tryParse(value);
                if (price == null || price <= 0) {
                  return 'Please enter a valid price';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.md),
            DropdownButtonFormField<String>(
              value: _paymentMethod,
              decoration: const InputDecoration(
                labelText: 'Payment Method *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.payment),
              ),
              items: const [
                DropdownMenuItem(value: 'cash', child: Text('Cash')),
                DropdownMenuItem(value: 'transfer', child: Text('Bank Transfer')),
              ],
              onChanged: (value) {
                setState(() {
                  _paymentMethod = value!;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.note, color: AppColors.primary),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Additional Notes',
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (Optional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.note),
                hintText: 'Any additional information about this sale...',
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    if (_selectedCustomer == null || _selectedVehicle == null) {
      return const SizedBox();
    }

    final price = double.tryParse(_priceController.text) ?? 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.summarize, color: AppColors.primary),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Sale Summary',
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _buildSummaryRow('Customer:', _selectedCustomer!.name),
            _buildSummaryRow('Phone:', _selectedCustomer!.phone ?? 'No phone'),
            const Divider(),
            _buildSummaryRow(
              'Vehicle:',
              '${_selectedVehicle!.brand} ${_selectedVehicle!.model}',
            ),
            _buildSummaryRow('Year:', _selectedVehicle!.year.toString()),
            _buildSummaryRow('License Plate:', _selectedVehicle!.plateNumber ?? 'N/A'),
            const Divider(),
            _buildSummaryRow('Payment Method:', _paymentMethod.toUpperCase()),
            _buildSummaryRow(
              'Selling Price:',
              'Rp ${_formatCurrency(price)}',
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isTotal
                ? AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)
                : AppTextStyles.bodyMedium,
          ),
          Text(
            value,
            style: isTotal
                ? AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  )
                : AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitSale() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedCustomer == null || _selectedVehicle == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select both customer and vehicle'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final price = double.parse(_priceController.text);
      final request = CreateSalesRequest(
        customerId: _selectedCustomer!.id,
        vehicleId: _selectedVehicle!.id,
        sellingPrice: price,
        paymentMethod: _paymentMethod,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      );

      final success = await context.read<SalesProvider>().createSalesInvoice(request);

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Sale created successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        }
      } else {
        if (mounted) {
          final error = context.read<SalesProvider>().error ?? 'Unknown error';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to create sale: $error'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _formatCurrency(double amount) {
    return amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }
}