import 'package:flutter/material.dart';
import '../../../theme.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
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
                  'Customer Management',
                  style: AppTextStyles.heading,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  // TODO: Implement add customer
                },
                icon: const Icon(Icons.add),
                label: const Text('Add Customer'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          
          // Search Bar
          TextField(
            decoration: const InputDecoration(
              labelText: 'Search customers...',
              prefixIcon: Icon(Icons.search),
              hintText: 'Name, phone, or customer code',
            ),
            onChanged: (value) {
              // TODO: Implement search
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          
          // Content
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 64,
                    color: AppColors.secondary,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Customer Management',
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