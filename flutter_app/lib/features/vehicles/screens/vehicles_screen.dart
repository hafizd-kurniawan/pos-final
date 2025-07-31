import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/app_widgets.dart';
import '../../../shared/models/models.dart';

class VehiclesScreen extends StatefulWidget {
  const VehiclesScreen({super.key});

  @override
  State<VehiclesScreen> createState() => _VehiclesScreenState();
}

class _VehiclesScreenState extends State<VehiclesScreen> {
  List<Vehicle> _vehicles = [];
  bool _isLoading = true;
  String _searchQuery = '';
  VehicleStatus? _filterStatus;

  @override
  void initState() {
    super.initState();
    _loadVehicles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vehicle Inventory'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: _showAddVehicle,
            icon: const Icon(Icons.add),
            tooltip: 'Add Vehicle',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Bar
          AppSearchBar(
            hintText: 'Search vehicles...',
            onChanged: (query) {
              setState(() {
                _searchQuery = query;
              });
            },
            onFilterTap: _showFilterDialog,
          ),
          
          // Filter Chips
          if (_filterStatus != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Row(
                children: [
                  Chip(
                    label: Text(_filterStatus!.displayName),
                    onDeleted: () {
                      setState(() {
                        _filterStatus = null;
                      });
                    },
                  ),
                ],
              ),
            ),
          
          // Vehicle Grid
          Expanded(
            child: _isLoading
                ? const AppLoading(message: 'Loading vehicles...')
                : _buildVehicleGrid(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddVehicle,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildVehicleGrid() {
    final filteredVehicles = _vehicles.where((vehicle) {
      final matchesSearch = vehicle.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          vehicle.brand.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          vehicle.licensePlate.toLowerCase().contains(_searchQuery.toLowerCase());
      
      final matchesFilter = _filterStatus == null || 
          vehicle.status.toLowerCase() == _filterStatus!.value;
      
      return matchesSearch && matchesFilter;
    }).toList();

    if (filteredVehicles.isEmpty) {
      return AppEmptyState(
        message: _searchQuery.isNotEmpty || _filterStatus != null
            ? 'No vehicles found matching your criteria'
            : 'No vehicles in inventory',
        icon: Icons.directions_car_outlined,
        actionLabel: 'Add Vehicle',
        onActionTap: _showAddVehicle,
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive grid: 4 columns on tablet, 2 on mobile
        final isTablet = constraints.maxWidth > AppBreakpoints.tablet;
        final crossAxisCount = isTablet ? 4 : 2;
        final childAspectRatio = isTablet ? 0.75 : 0.8;

        return GridView.builder(
          padding: const EdgeInsets.all(AppSpacing.md),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: AppSpacing.gridSpacing,
            mainAxisSpacing: AppSpacing.gridSpacing,
            childAspectRatio: childAspectRatio,
          ),
          itemCount: filteredVehicles.length,
          itemBuilder: (context, index) {
            final vehicle = filteredVehicles[index];
            return VehicleCard(
              name: vehicle.name,
              brand: vehicle.brand,
              year: vehicle.year.toString(),
              price: 'Rp ${_formatCurrency(vehicle.sellingPrice)}',
              status: vehicle.status,
              imageUrl: vehicle.primaryPhotoUrl,
              onTap: () => _showVehicleDetail(vehicle),
            );
          },
        );
      },
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Vehicles'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Filter by status:'),
            const SizedBox(height: AppSpacing.md),
            ...VehicleStatus.values.map((status) {
              return ListTile(
                title: Text(status.displayName),
                leading: Radio<VehicleStatus>(
                  value: status,
                  groupValue: _filterStatus,
                  onChanged: (value) {
                    setState(() {
                      _filterStatus = value;
                    });
                    Navigator.pop(context);
                  },
                ),
              );
            }),
            ListTile(
              title: const Text('Clear Filter'),
              leading: Radio<VehicleStatus?>(
                value: null,
                groupValue: _filterStatus,
                onChanged: (value) {
                  setState(() {
                    _filterStatus = null;
                  });
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showVehicleDetail(Vehicle vehicle) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600, maxHeight: 800),
          child: Column(
            children: [
              AppBar(
                title: Text(vehicle.name),
                automaticallyImplyLeading: false,
                actions: [
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
                      // Vehicle Image
                      Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: AppRadius.medium,
                          color: AppColors.surfaceVariant,
                        ),
                        child: vehicle.primaryPhotoUrl != null
                            ? ClipRRect(
                                borderRadius: AppRadius.medium,
                                child: Image.network(
                                  vehicle.primaryPhotoUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return _buildPlaceholder();
                                  },
                                ),
                              )
                            : _buildPlaceholder(),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      
                      // Vehicle Details
                      _buildDetailRow('Brand', vehicle.brand),
                      _buildDetailRow('Model', vehicle.model),
                      _buildDetailRow('Year', vehicle.year.toString()),
                      _buildDetailRow('Color', vehicle.color),
                      _buildDetailRow('License Plate', vehicle.licensePlate),
                      _buildDetailRow('Engine Number', vehicle.engineNumber),
                      _buildDetailRow('Chassis Number', vehicle.chassisNumber),
                      _buildDetailRow('Status', vehicle.status),
                      _buildDetailRow('Purchase Price', 'Rp ${_formatCurrency(vehicle.purchasePrice)}'),
                      _buildDetailRow('Selling Price', 'Rp ${_formatCurrency(vehicle.sellingPrice)}'),
                      _buildDetailRow('Repair Cost', 'Rp ${_formatCurrency(vehicle.repairCost)}'),
                      _buildDetailRow('HPP', 'Rp ${_formatCurrency(vehicle.hpp)}'),
                      
                      if (vehicle.description != null) ...[
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          'Description',
                          style: AppTextStyles.labelLarge,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          vehicle.description!,
                          style: AppTextStyles.bodyMedium,
                        ),
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

  Widget _buildPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: AppRadius.medium,
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.directions_car,
              size: AppIconSizes.xl,
              color: AppColors.secondary,
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              'No Photo Available',
              style: AppTextStyles.bodySmall,
            ),
          ],
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

  String _formatCurrency(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  void _loadVehicles() async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    
    // Demo data
    setState(() {
      _vehicles = [
        Vehicle(
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
          status: 'available',
          description: 'Well maintained family car with low mileage',
          primaryPhotoUrl: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Vehicle(
          id: '2',
          vehicleCategoryId: '1',
          name: 'Honda Civic RS',
          brand: 'Honda',
          model: 'Civic',
          year: 2022,
          color: 'Black',
          licensePlate: 'B 5678 DEF',
          engineNumber: 'ENG654321',
          chassisNumber: 'CHS210987',
          purchasePrice: 450000000,
          repairCost: 15000000,
          sellingPrice: 480000000,
          hpp: 465000000,
          status: 'in_repair',
          description: 'Sporty sedan with turbo engine',
          primaryPhotoUrl: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Vehicle(
          id: '3',
          vehicleCategoryId: '2',
          name: 'Yamaha NMAX',
          brand: 'Yamaha',
          model: 'NMAX',
          year: 2023,
          color: 'Blue',
          licensePlate: 'B 9012 GHI',
          engineNumber: 'ENG987654',
          chassisNumber: 'CHS456789',
          purchasePrice: 28000000,
          repairCost: 2000000,
          sellingPrice: 32000000,
          hpp: 30000000,
          status: 'sold',
          description: 'Premium automatic scooter',
          primaryPhotoUrl: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];
      _isLoading = false;
    });
  }

  void _showAddVehicle() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Add Vehicle feature will be implemented with mandatory photo upload'),
        duration: Duration(seconds: 3),
      ),
    );
  }
}