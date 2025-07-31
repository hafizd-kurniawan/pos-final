import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_theme.dart';
import '../../shared/providers/auth_provider.dart';
import '../../core/widgets/dashboard_layout.dart';
import '../../core/widgets/stats_card.dart';

class MechanicDashboardScreen extends StatefulWidget {
  const MechanicDashboardScreen({super.key});

  @override
  State<MechanicDashboardScreen> createState() => _MechanicDashboardScreenState();
}

class _MechanicDashboardScreenState extends State<MechanicDashboardScreen> {
  String _selectedMenuItem = 'dashboard';

  @override
  Widget build(BuildContext context) {
    return DashboardLayout(
      title: 'Mechanic Dashboard',
      selectedMenuItem: _selectedMenuItem,
      onMenuItemSelected: (item) {
        setState(() {
          _selectedMenuItem = item;
        });
      },
      menuItems: const [
        DashboardMenuItem(
          id: 'dashboard',
          label: 'Dashboard',
          icon: Icons.dashboard,
        ),
        DashboardMenuItem(
          id: 'work_orders',
          label: 'My Work Orders',
          icon: Icons.build,
          badge: '5',
        ),
        DashboardMenuItem(
          id: 'parts',
          label: 'Spare Parts',
          icon: Icons.inventory,
        ),
        DashboardMenuItem(
          id: 'progress',
          label: 'Work Progress',
          icon: Icons.timeline,
        ),
      ],
      body: _buildSelectedContent(),
    );
  }

  Widget _buildSelectedContent() {
    switch (_selectedMenuItem) {
      case 'dashboard':
        return _buildDashboardContent();
      case 'work_orders':
        return _buildWorkOrdersContent();
      case 'parts':
        return _buildPartsContent();
      case 'progress':
        return _buildProgressContent();
      default:
        return _buildDashboardContent();
    }
  }

  Widget _buildDashboardContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.warning, AppColors.warning.withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppBorderRadius.lg),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    return Text(
                      'Welcome, ${authProvider.currentUser?.fullName ?? 'Mechanic'}!',
                      style: AppTextStyles.headlineMedium.copyWith(
                        color: AppColors.white,
                      ),
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Ready to work on vehicle repairs and maintenance',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // Quick Stats
          Text(
            'Work Overview',
            style: AppTextStyles.headlineSmall,
          ),
          const SizedBox(height: AppSpacing.md),
          
          LayoutBuilder(
            builder: (context, constraints) {
              final isTablet = constraints.maxWidth > 600;
              final crossAxisCount = isTablet ? 4 : 2;
              final childAspectRatio = isTablet ? 1.2 : 1.5;
              
              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: AppSpacing.md,
                mainAxisSpacing: AppSpacing.md,
                childAspectRatio: childAspectRatio,
                children: const [
                  StatsCard(
                    title: 'Assigned Work Orders',
                    value: '5',
                    icon: Icons.assignment,
                    color: AppColors.primary,
                    subtitle: 'Active tasks',
                  ),
                  StatsCard(
                    title: 'In Progress',
                    value: '3',
                    icon: Icons.pending,
                    color: AppColors.warning,
                    subtitle: 'Currently working',
                  ),
                  StatsCard(
                    title: 'Completed Today',
                    value: '2',
                    icon: Icons.check_circle,
                    color: AppColors.success,
                    subtitle: 'Finished repairs',
                  ),
                  StatsCard(
                    title: 'Parts Used',
                    value: '12',
                    icon: Icons.inventory_2,
                    color: AppColors.info,
                    subtitle: 'This week',
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWorkOrdersContent() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.build,
            size: 64,
            color: AppColors.warning,
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            'My Work Orders',
            style: AppTextStyles.headlineMedium,
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            'Work order management features will be implemented here',
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPartsContent() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory,
            size: 64,
            color: AppColors.info,
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            'Spare Parts',
            style: AppTextStyles.headlineMedium,
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            'Spare parts inventory features will be implemented here',
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressContent() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.timeline,
            size: 64,
            color: AppColors.secondary,
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            'Work Progress',
            style: AppTextStyles.headlineMedium,
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            'Work progress tracking features will be implemented here',
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}