import 'package:flutter/material.dart';
import '../../../theme.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Expanded(
                child: Text(
                  'Sales Management',
                  style: AppTextStyles.heading,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  // TODO: Implement new sale
                },
                icon: const Icon(Icons.add),
                label: const Text('New Sale'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          
          // Content
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.point_of_sale,
                    size: 64,
                    color: AppColors.secondary,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Sales Management',
                    style: AppTextStyles.title,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Feature will be implemented here',
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}