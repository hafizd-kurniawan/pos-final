import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/constants/app_theme.dart';
import '../../../core/config/app_config.dart';
import '../../../shared/providers/vehicle_provider.dart';
import '../../../shared/models/vehicle_model.dart';
import '../widgets/vehicle_card.dart';
import '../widgets/vehicle_filter_sheet.dart';
import '../widgets/add_vehicle_sheet.dart';

class VehicleGridScreen extends StatefulWidget {
  const VehicleGridScreen({super.key});

  @override
  State<VehicleGridScreen> createState() => _VehicleGridScreenState();
}

class _VehicleGridScreenState extends State<VehicleGridScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadVehicles();
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
      final vehicleProvider = context.read<VehicleProvider>();
      vehicleProvider.loadMore();
    }
  }

  Future<void> _loadVehicles() async {
    final vehicleProvider = context.read<VehicleProvider>();
    await vehicleProvider.loadVehicles(refresh: true);
  }

  void _onSearchChanged(String query) {
    final vehicleProvider = context.read<VehicleProvider>();
    vehicleProvider.setSearchQuery(query);
  }

  Future<void> _applySearch() async {
    final vehicleProvider = context.read<VehicleProvider>();
    await vehicleProvider.applyFilters();
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const VehicleFilterSheet(),
    );
  }

  void _showAddVehicleSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddVehicleSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search and Filter Bar
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
                    hintText: 'Search vehicles by brand, model, or license plate...',
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
              
              // Filter Button
              Consumer<VehicleProvider>(
                builder: (context, vehicleProvider, _) {
                  final hasFilters = vehicleProvider.statusFilter != null ||
                      vehicleProvider.brandFilter != null ||
                      vehicleProvider.categoryFilter != null;
                  
                  return IconButton(
                    icon: Stack(
                      children: [
                        const Icon(Icons.filter_list),
                        if (hasFilters)
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                      ],
                    ),
                    onPressed: _showFilterSheet,
                    tooltip: 'Filter vehicles',
                  );
                },
              ),
              
              // Add Vehicle Button
              ElevatedButton.icon(
                onPressed: _showAddVehicleSheet,
                icon: const Icon(Icons.add),
                label: const Text('Add Vehicle'),
              ),
            ],
          ),
        ),

        // Vehicle Grid
        Expanded(
          child: Consumer<VehicleProvider>(
            builder: (context, vehicleProvider, _) {
              if (vehicleProvider.isLoading && vehicleProvider.vehicles.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (vehicleProvider.error != null) {
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
                        'Error loading vehicles',
                        style: AppTextStyles.cardTitle,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        vehicleProvider.error!,
                        style: AppTextStyles.cardSubtitle,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadVehicles,
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
                        size: 48,
                        color: AppColors.textTertiary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No vehicles found',
                        style: AppTextStyles.cardTitle,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add your first vehicle to get started',
                        style: AppTextStyles.cardSubtitle,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _showAddVehicleSheet,
                        icon: const Icon(Icons.add),
                        label: const Text('Add Vehicle'),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: _loadVehicles,
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
                        childAspectRatio: 0.75, // Adjust for card height
                      ),
                      itemCount: vehicleProvider.vehicles.length + 
                          (vehicleProvider.hasMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == vehicleProvider.vehicles.length) {
                          // Loading indicator for pagination
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

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

  void _showVehicleDetail(Vehicle vehicle) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: 600,
          height: 500,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Vehicle Details',
                    style: AppTextStyles.sidebarTitle,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Vehicle Photo
                      if (vehicle.thumbnailUrl != null)
                        Container(
                          width: double.infinity,
                          height: 200,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: CachedNetworkImage(
                              imageUrl: vehicle.thumbnailUrl!,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: AppColors.surfaceVariant,
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: AppColors.surfaceVariant,
                                child: const Icon(
                                  Icons.directions_car,
                                  size: 48,
                                  color: AppColors.textTertiary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      
                      const SizedBox(height: 16),
                      
                      // Vehicle Info
                      _buildDetailRow('Brand', vehicle.brand),
                      _buildDetailRow('Model', vehicle.model),
                      _buildDetailRow('Year', vehicle.year),
                      _buildDetailRow('License Plate', vehicle.licensePlate),
                      _buildDetailRow('Status', vehicle.statusDisplay),
                      _buildDetailRow('Purchase Price', 'Rp ${vehicle.purchasePrice.toStringAsFixed(0)}'),
                      if (vehicle.sellingPrice != null)
                        _buildDetailRow('Selling Price', 'Rp ${vehicle.sellingPrice!.toStringAsFixed(0)}'),
                      if (vehicle.description != null && vehicle.description!.isNotEmpty)
                        _buildDetailRow('Description', vehicle.description!),
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
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
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
}