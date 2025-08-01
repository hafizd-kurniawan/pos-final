import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/constants/app_theme.dart';
import '../../../shared/models/vehicle_model.dart';

class VehicleCard extends StatelessWidget {
  final Vehicle vehicle;
  final VoidCallback? onTap;
  final bool showActions;

  const VehicleCard({
    super.key,
    required this.vehicle,
    this.onTap,
    this.showActions = true,
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
            // Vehicle Image
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                color: AppColors.surfaceVariant,
                child: vehicle.thumbnailUrl != null
                    ? CachedNetworkImage(
                        imageUrl: vehicle.thumbnailUrl!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: AppColors.surfaceVariant,
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        errorWidget: (context, url, error) => _buildPlaceholder(),
                      )
                    : _buildPlaceholder(),
              ),
            ),
            
            // Vehicle Info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      vehicle.displayName,
                      style: AppTextStyles.cardTitle.copyWith(
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // License Plate
                    Text(
                      vehicle.licensePlate,
                      style: AppTextStyles.cardSubtitle.copyWith(
                        fontSize: 12,
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Status Badge and Price
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildStatusBadge(),
                        Expanded(
                          child: Text(
                            'Rp ${_formatPrice(vehicle.purchasePrice)}',
                            style: AppTextStyles.cardSubtitle.copyWith(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                            textAlign: TextAlign.right,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppColors.surfaceVariant,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.directions_car,
              size: 32,
              color: AppColors.textTertiary,
            ),
            SizedBox(height: 4),
            Text(
              'No Photo',
              style: TextStyle(
                fontSize: 10,
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color backgroundColor;
    Color textColor;
    
    switch (vehicle.status) {
      case 'available':
        backgroundColor = AppColors.success.withOpacity(0.1);
        textColor = AppColors.success;
        break;
      case 'in_repair':
        backgroundColor = AppColors.warning.withOpacity(0.1);
        textColor = AppColors.warning;
        break;
      case 'sold':
        backgroundColor = AppColors.error.withOpacity(0.1);
        textColor = AppColors.error;
        break;
      case 'reserved':
        backgroundColor = AppColors.info.withOpacity(0.1);
        textColor = AppColors.info;
        break;
      default:
        backgroundColor = AppColors.surfaceVariant;
        textColor = AppColors.textSecondary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 6,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        vehicle.statusDisplay,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  String _formatPrice(double price) {
    if (price >= 1000000000) {
      return '${(price / 1000000000).toStringAsFixed(1)}B';
    } else if (price >= 1000000) {
      return '${(price / 1000000).toStringAsFixed(1)}M';
    } else if (price >= 1000) {
      return '${(price / 1000).toStringAsFixed(0)}K';
    } else {
      return price.toStringAsFixed(0);
    }
  }
}