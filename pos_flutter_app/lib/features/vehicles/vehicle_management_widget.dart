import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../core/constants/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../shared/providers/vehicle_provider.dart';
import '../../shared/models/vehicle_model.dart';
import '../vehicles/add_vehicle_screen.dart';
import '../vehicles/vehicle_detail_screen.dart';

class VehicleManagementWidget extends StatefulWidget {
  const VehicleManagementWidget({super.key});

  @override
  State<VehicleManagementWidget> createState() => _VehicleManagementWidgetState();
}

class _VehicleManagementWidgetState extends State<VehicleManagementWidget> {
  final _searchController = TextEditingController();
  String _selectedStatus = 'all';
  String _selectedBrand = 'all';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadVehicles();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadVehicles({bool refresh = false}) async {
    if (_isLoading && !refresh) return;
    
    setState(() {
      _isLoading = true;
    });

    await context.read<VehicleProvider>().loadVehicles(
      refresh: refresh,
      status: _selectedStatus == 'all' ? null : _selectedStatus,
      search: _searchController.text.trim().isEmpty ? null : _searchController.text.trim(),
      brand: _selectedBrand == 'all' ? null : _selectedBrand,
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showAddVehicleDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
          child: const AddVehicleScreen(),
        ),
      ),
    ).then((result) {
      if (result == true) {
        _loadVehicles(refresh: true);
      }
    });
  }

  void _showVehicleDetail(Vehicle vehicle) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800, maxHeight: 600),
          child: VehicleDetailScreen(vehicle: vehicle),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header and Filters
        Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title and Add Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Vehicle Inventory',
                    style: AppTextStyles.headlineMedium,
                  ),
                  ElevatedButton.icon(
                    onPressed: _showAddVehicleDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Vehicle'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // Search and Filters
              Row(
                children: [
                  // Search
                  Expanded(
                    flex: 3,
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: 'Search vehicles...',
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: (value) {
                        // Debounce search
                        Future.delayed(const Duration(milliseconds: 500), () {
                          if (_searchController.text == value) {
                            _loadVehicles(refresh: true);
                          }
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),

                  // Status Filter
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      value: _selectedStatus,
                      decoration: const InputDecoration(
                        labelText: 'Status',
                        prefixIcon: Icon(Icons.filter_alt),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'all', child: Text('All Status')),
                        DropdownMenuItem(value: 'available', child: Text('Available')),
                        DropdownMenuItem(value: 'in_repair', child: Text('In Repair')),
                        DropdownMenuItem(value: 'sold', child: Text('Sold')),
                        DropdownMenuItem(value: 'reserved', child: Text('Reserved')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedStatus = value!;
                        });
                        _loadVehicles(refresh: true);
                      },
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),

                  // Brand Filter
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      value: _selectedBrand,
                      decoration: const InputDecoration(
                        labelText: 'Brand',
                        prefixIcon: Icon(Icons.branding_watermark),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'all', child: Text('All Brands')),
                        DropdownMenuItem(value: 'toyota', child: Text('Toyota')),
                        DropdownMenuItem(value: 'honda', child: Text('Honda')),
                        DropdownMenuItem(value: 'suzuki', child: Text('Suzuki')),
                        DropdownMenuItem(value: 'daihatsu', child: Text('Daihatsu')),
                        DropdownMenuItem(value: 'mitsubishi', child: Text('Mitsubishi')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedBrand = value!;
                        });
                        _loadVehicles(refresh: true);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Vehicle Grid
        Expanded(
          child: Consumer<VehicleProvider>(
            builder: (context, vehicleProvider, child) {
              if (vehicleProvider.isLoading && vehicleProvider.vehicles.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (vehicleProvider.error != null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: AppColors.error,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'Error: ${vehicleProvider.error}',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.error,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      ElevatedButton(
                        onPressed: () => _loadVehicles(refresh: true),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              if (vehicleProvider.vehicles.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.directions_car_outlined,
                        size: 64,
                        color: AppColors.textTertiary,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'No vehicles found',
                        style: AppTextStyles.headlineSmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Try adjusting your search filters or add a new vehicle',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textTertiary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      ElevatedButton.icon(
                        onPressed: _showAddVehicleDialog,
                        icon: const Icon(Icons.add),
                        label: const Text('Add First Vehicle'),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () => _loadVehicles(refresh: true),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // Responsive grid
                    final crossAxisCount = constraints.maxWidth > 1200
                        ? 4
                        : constraints.maxWidth > 800
                            ? 3
                            : constraints.maxWidth > 600
                                ? 2
                                : 1;

                    return GridView.builder(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: AppSpacing.md,
                        mainAxisSpacing: AppSpacing.md,
                        childAspectRatio: 0.8, // Taller cards for vehicle info
                      ),
                      itemCount: vehicleProvider.vehicles.length,
                      itemBuilder: (context, index) {
                        final vehicle = vehicleProvider.vehicles[index];
                        return VehicleCard(
                          vehicle: vehicle,
                          onTap: () => _showVehicleDetail(vehicle),
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
}

class VehicleCard extends StatelessWidget {
  final Vehicle vehicle;
  final VoidCallback onTap;

  const VehicleCard({
    super.key,
    required this.vehicle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Vehicle Photo
            Expanded(
              flex: 2,
              child: Container(
                width: double.infinity,
                color: AppColors.surfaceVariant,
                child: vehicle.hasPhoto
                    ? CachedNetworkImage(
                        imageUrl: '${AppConstants.apiBaseUrl.replaceAll('/api/v1', '')}/static/uploads/${vehicle.thumbnail}',
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const Center(
                          child: CircularProgressIndicator(),
                        ),
                        errorWidget: (context, url, error) => _buildPlaceholderImage(),
                      )
                    : _buildPlaceholderImage(),
              ),
            ),

            // Vehicle Info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      vehicle.displayName,
                      style: AppTextStyles.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xs),

                    // Vehicle Code
                    Text(
                      vehicle.vehicleCode,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    // Status
                    _buildStatusChip(vehicle.status),
                    const Spacer(),

                    // Price
                    if (vehicle.sellingPrice != null)
                      Text(
                        'Rp ${_formatCurrency(vehicle.sellingPrice!)}',
                        style: AppTextStyles.titleMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    else if (vehicle.purchasePrice != null)
                      Text(
                        'Purchase: Rp ${_formatCurrency(vehicle.purchasePrice!)}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: AppColors.surfaceVariant,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.directions_car,
              size: 48,
              color: AppColors.textTertiary,
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              'No Photo',
              style: AppTextStyles.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String label;
    
    switch (status) {
      case 'available':
        color = AppColors.available;
        label = 'Available';
        break;
      case 'in_repair':
        color = AppColors.inRepair;
        label = 'In Repair';
        break;
      case 'sold':
        color = AppColors.sold;
        label = 'Sold';
        break;
      case 'reserved':
        color = AppColors.reserved;
        label = 'Reserved';
        break;
      default:
        color = AppColors.textSecondary;
        label = status.toUpperCase();
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppBorderRadius.sm),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _formatCurrency(double amount) {
    // Simple currency formatting
    if (amount >= 1000000000) {
      return '${(amount / 1000000000).toStringAsFixed(1)}B';
    } else if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}K';
    }
    return amount.toStringAsFixed(0);
  }
}