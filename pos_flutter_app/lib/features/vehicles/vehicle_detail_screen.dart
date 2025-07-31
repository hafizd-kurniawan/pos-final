import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../core/constants/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../shared/models/vehicle_model.dart';

class VehicleDetailScreen extends StatefulWidget {
  final Vehicle vehicle;

  const VehicleDetailScreen({
    super.key,
    required this.vehicle,
  });

  @override
  State<VehicleDetailScreen> createState() => _VehicleDetailScreenState();
}

class _VehicleDetailScreenState extends State<VehicleDetailScreen> {
  int _selectedPhotoIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.vehicle.displayName),
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Edit vehicle
            },
            icon: const Icon(Icons.edit),
            tooltip: 'Edit Vehicle',
          ),
          IconButton(
            onPressed: () {
              // TODO: More options
            },
            icon: const Icon(Icons.more_vert),
            tooltip: 'More Options',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Photo Gallery
            _buildPhotoGallery(),
            
            // Vehicle Information
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBasicInfo(),
                  const SizedBox(height: AppSpacing.xl),
                  _buildTechnicalInfo(),
                  const SizedBox(height: AppSpacing.xl),
                  _buildPricingInfo(),
                  const SizedBox(height: AppSpacing.xl),
                  _buildAdditionalInfo(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoGallery() {
    final photos = widget.vehicle.photos ?? [];
    
    if (photos.isEmpty && !widget.vehicle.hasPhoto) {
      return Container(
        height: 300,
        color: AppColors.surfaceVariant,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.directions_car,
                size: 64,
                color: AppColors.textTertiary,
              ),
              SizedBox(height: AppSpacing.md),
              Text(
                'No Photos Available',
                style: AppTextStyles.bodyMedium,
              ),
            ],
          ),
        ),
      );
    }

    // Use primary photo if available, otherwise first photo
    final displayPhoto = widget.vehicle.primaryPhoto ?? photos.firstOrNull?.photoPath;
    
    return Column(
      children: [
        // Main Photo
        Container(
          height: 300,
          width: double.infinity,
          color: AppColors.surfaceVariant,
          child: displayPhoto != null
              ? CachedNetworkImage(
                  imageUrl: '${AppConstants.apiBaseUrl.replaceAll('/api/v1', '')}/static/uploads/$displayPhoto',
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  errorWidget: (context, url, error) => const Center(
                    child: Icon(
                      Icons.broken_image,
                      size: 64,
                      color: AppColors.textTertiary,
                    ),
                  ),
                )
              : const Center(
                  child: Icon(
                    Icons.directions_car,
                    size: 64,
                    color: AppColors.textTertiary,
                  ),
                ),
        ),

        // Photo Thumbnails
        if (photos.length > 1)
          Container(
            height: 80,
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              itemCount: photos.length,
              itemBuilder: (context, index) {
                final photo = photos[index];
                final isSelected = _selectedPhotoIndex == index;
                
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedPhotoIndex = index;
                    });
                  },
                  child: Container(
                    width: 60,
                    height: 60,
                    margin: const EdgeInsets.only(right: AppSpacing.sm),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.border,
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(AppBorderRadius.md),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppBorderRadius.md),
                      child: CachedNetworkImage(
                        imageUrl: '${AppConstants.apiBaseUrl.replaceAll('/api/v1', '')}/static/uploads/${photo.photoPath}',
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const Center(
                          child: CircularProgressIndicator(),
                        ),
                        errorWidget: (context, url, error) => const Icon(
                          Icons.broken_image,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildBasicInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.vehicle.displayName,
                    style: AppTextStyles.headlineMedium,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Code: ${widget.vehicle.vehicleCode}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            _buildStatusChip(widget.vehicle.status),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        
        // Basic Details Grid
        _buildInfoGrid([
          _InfoItem('Brand', widget.vehicle.brand),
          _InfoItem('Model', widget.vehicle.model),
          _InfoItem('Year', widget.vehicle.year.toString()),
          _InfoItem('Color', widget.vehicle.color ?? 'Not specified'),
        ]),
      ],
    );
  }

  Widget _buildTechnicalInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Technical Details',
          style: AppTextStyles.headlineSmall,
        ),
        const SizedBox(height: AppSpacing.md),
        
        _buildInfoGrid([
          _InfoItem('Fuel Type', widget.vehicle.fuelType ?? 'Not specified'),
          _InfoItem('Transmission', widget.vehicle.transmission ?? 'Not specified'),
          _InfoItem('Chassis Number', widget.vehicle.chassisNumber ?? 'Not specified'),
          _InfoItem('Engine Number', widget.vehicle.engineNumber ?? 'Not specified'),
          _InfoItem('License Plate', widget.vehicle.plateNumber ?? 'Not specified'),
        ]),
      ],
    );
  }

  Widget _buildPricingInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pricing Information',
          style: AppTextStyles.headlineSmall,
        ),
        const SizedBox(height: AppSpacing.md),
        
        _buildInfoGrid([
          _InfoItem(
            'Purchase Price', 
            widget.vehicle.purchasePrice != null 
                ? 'Rp ${_formatCurrency(widget.vehicle.purchasePrice!)}'
                : 'Not specified'
          ),
          _InfoItem(
            'Repair Cost', 
            'Rp ${_formatCurrency(widget.vehicle.repairCost)}'
          ),
          _InfoItem(
            'HPP (Cost of Goods)', 
            widget.vehicle.hpp != null 
                ? 'Rp ${_formatCurrency(widget.vehicle.hpp!)}'
                : 'Not calculated'
          ),
          _InfoItem(
            'Selling Price', 
            widget.vehicle.sellingPrice != null 
                ? 'Rp ${_formatCurrency(widget.vehicle.sellingPrice!)}'
                : 'Not set'
          ),
        ]),
      ],
    );
  }

  Widget _buildAdditionalInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Additional Information',
          style: AppTextStyles.headlineSmall,
        ),
        const SizedBox(height: AppSpacing.md),
        
        _buildInfoGrid([
          _InfoItem(
            'Purchased Date', 
            widget.vehicle.purchasedDate != null 
                ? _formatDate(widget.vehicle.purchasedDate!)
                : 'Not specified'
          ),
          _InfoItem(
            'Sold Date', 
            widget.vehicle.soldDate != null 
                ? _formatDate(widget.vehicle.soldDate!)
                : 'Not sold'
          ),
          _InfoItem(
            'Created Date', 
            _formatDate(widget.vehicle.createdAt)
          ),
          _InfoItem(
            'Last Updated', 
            widget.vehicle.updatedAt != null 
                ? _formatDate(widget.vehicle.updatedAt!)
                : 'Never updated'
          ),
        ]),
        
        if (widget.vehicle.conditionNotes != null) ...[
          const SizedBox(height: AppSpacing.md),
          Text(
            'Condition Notes',
            style: AppTextStyles.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(AppBorderRadius.md),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              widget.vehicle.conditionNotes!,
              style: AppTextStyles.bodyMedium,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildInfoGrid(List<_InfoItem> items) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 600 ? 2 : 1;
        
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: AppSpacing.md,
            mainAxisSpacing: AppSpacing.sm,
            childAspectRatio: 3,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(AppBorderRadius.md),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    item.label,
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    item.value,
                    style: AppTextStyles.bodyMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            );
          },
        );
      },
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
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppBorderRadius.circular),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelMedium.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _formatCurrency(double amount) {
    // Simple currency formatting
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _InfoItem {
  final String label;
  final String value;
  
  _InfoItem(this.label, this.value);
}

extension ListExtension<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}