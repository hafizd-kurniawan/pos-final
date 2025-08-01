import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_theme.dart';
import '../../../shared/providers/vehicle_provider.dart';

class VehicleFilterSheet extends StatefulWidget {
  const VehicleFilterSheet({super.key});

  @override
  State<VehicleFilterSheet> createState() => _VehicleFilterSheetState();
}

class _VehicleFilterSheetState extends State<VehicleFilterSheet> {
  String? _selectedStatus;
  String? _selectedBrand;
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    final vehicleProvider = context.read<VehicleProvider>();
    _selectedStatus = vehicleProvider.statusFilter;
    _selectedBrand = vehicleProvider.brandFilter;
    _selectedCategory = vehicleProvider.categoryFilter;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filter Vehicles',
                style: AppTextStyles.sidebarTitle,
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          
          const Divider(),
          
          // Status Filter
          Text(
            'Status',
            style: AppTextStyles.cardTitle.copyWith(fontSize: 14),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _buildFilterChip('All', null, _selectedStatus),
              _buildFilterChip('Available', 'available', _selectedStatus),
              _buildFilterChip('In Repair', 'in_repair', _selectedStatus),
              _buildFilterChip('Sold', 'sold', _selectedStatus),
              _buildFilterChip('Reserved', 'reserved', _selectedStatus),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Brand Filter
          Consumer<VehicleProvider>(
            builder: (context, vehicleProvider, _) {
              final brands = vehicleProvider.distinctBrands;
              if (brands.isNotEmpty) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Brand',
                      style: AppTextStyles.cardTitle.copyWith(fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        _buildFilterChip('All', null, _selectedBrand),
                        ...brands.map((brand) =>
                            _buildFilterChip(brand, brand, _selectedBrand)),
                      ],
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
          
          const SizedBox(height: 24),
          
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _clearFilters,
                  child: const Text('Clear All'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _applyFilters,
                  child: const Text('Apply Filters'),
                ),
              ),
            ],
          ),
          
          // Add bottom padding for safe area
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String? value, String? selectedValue) {
    final isSelected = value == selectedValue;
    
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          if (label == 'Status') {
            _selectedStatus = selected ? value : null;
          } else if (label == 'Brand') {
            _selectedBrand = selected ? value : null;
          }
        });
      },
      selectedColor: AppColors.primary.withOpacity(0.2),
      checkmarkColor: AppColors.primary,
    );
  }

  void _clearFilters() {
    setState(() {
      _selectedStatus = null;
      _selectedBrand = null;
      _selectedCategory = null;
    });
  }

  Future<void> _applyFilters() async {
    final vehicleProvider = context.read<VehicleProvider>();
    
    vehicleProvider.setStatusFilter(_selectedStatus);
    vehicleProvider.setBrandFilter(_selectedBrand);
    vehicleProvider.setCategoryFilter(_selectedCategory);
    
    await vehicleProvider.applyFilters();
    
    if (mounted) {
      Navigator.of(context).pop();
    }
  }
}