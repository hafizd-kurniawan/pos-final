import 'package:flutter/material.dart';
import '../../../theme.dart';

class WorkOrdersScreen extends StatefulWidget {
  const WorkOrdersScreen({super.key});

  @override
  State<WorkOrdersScreen> createState() => _WorkOrdersScreenState();
}

class _WorkOrdersScreenState extends State<WorkOrdersScreen> {
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
                  'Work Orders',
                  style: AppTextStyles.heading,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  // TODO: Implement new work order
                },
                icon: const Icon(Icons.add),
                label: const Text('New Work Order'),
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
                    Icons.work,
                    size: 64,
                    color: AppColors.secondary,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Work Order Management',
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