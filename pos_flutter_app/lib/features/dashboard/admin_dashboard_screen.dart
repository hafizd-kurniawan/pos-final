import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_theme.dart';
import '../../shared/providers/auth_provider.dart';
import '../../core/widgets/dashboard_layout.dart';
import '../../core/widgets/stats_card.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  String _selectedMenuItem = 'dashboard';

  @override
  Widget build(BuildContext context) {
    return DashboardLayout(
      title: 'Admin Dashboard',
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
          id: 'users',
          label: 'User Management',
          icon: Icons.people,
        ),
        DashboardMenuItem(
          id: 'vehicles',
          label: 'Vehicle Overview',
          icon: Icons.directions_car,
        ),
        DashboardMenuItem(
          id: 'work_orders',
          label: 'Work Orders',
          icon: Icons.build,
        ),
        DashboardMenuItem(
          id: 'analytics',
          label: 'Analytics',
          icon: Icons.analytics,
        ),
        DashboardMenuItem(
          id: 'settings',
          label: 'System Settings',
          icon: Icons.settings,
        ),
      ],
      body: _buildSelectedContent(),
    );
  }

  Widget _buildSelectedContent() {
    switch (_selectedMenuItem) {
      case 'dashboard':
        return _buildDashboardContent();
      case 'users':
        return _buildUsersContent();
      case 'vehicles':
        return _buildVehiclesContent();
      case 'work_orders':
        return _buildWorkOrdersContent();
      case 'analytics':
        return _buildAnalyticsContent();
      case 'settings':
        return _buildSettingsContent();
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
                colors: [AppColors.secondary, AppColors.secondary.withOpacity(0.8)],
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
                      'Welcome, ${authProvider.currentUser?.fullName ?? 'Admin'}!',
                      style: AppTextStyles.headlineMedium.copyWith(
                        color: AppColors.white,
                      ),
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Monitor and manage your entire POS system',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // System Overview
          Text(
            'System Overview',
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
                    title: 'Total Users',
                    value: '15',
                    icon: Icons.people,
                    color: AppColors.primary,
                    subtitle: '3 Admin, 8 Kasir, 4 Mekanik',
                  ),
                  StatsCard(
                    title: 'Total Vehicles',
                    value: '87',
                    icon: Icons.directions_car,
                    color: AppColors.success,
                    subtitle: '24 Available, 12 In Repair, 51 Sold',
                  ),
                  StatsCard(
                    title: 'Active Work Orders',
                    value: '18',
                    icon: Icons.build,
                    color: AppColors.warning,
                    subtitle: 'Across all mechanics',
                  ),
                  StatsCard(
                    title: 'Monthly Revenue',
                    value: 'Rp 2.8B',
                    icon: Icons.monetization_on,
                    color: AppColors.info,
                    subtitle: '+15% from last month',
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: AppSpacing.xl),

          // Performance Metrics
          Text(
            'Performance Metrics',
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
                    title: 'Avg Repair Time',
                    value: '5.2 days',
                    icon: Icons.timer,
                    color: AppColors.success,
                    subtitle: 'Industry standard: 7 days',
                  ),
                  StatsCard(
                    title: 'Customer Satisfaction',
                    value: '4.8/5',
                    icon: Icons.star,
                    color: AppColors.warning,
                    subtitle: 'Based on 245 reviews',
                  ),
                  StatsCard(
                    title: 'Parts Efficiency',
                    value: '94%',
                    icon: Icons.inventory,
                    color: AppColors.info,
                    subtitle: 'Stock utilization rate',
                  ),
                  StatsCard(
                    title: 'Profit Margin',
                    value: '23.5%',
                    icon: Icons.trending_up,
                    color: AppColors.primary,
                    subtitle: 'This quarter',
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildUsersContent() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people,
            size: 64,
            color: AppColors.primary,
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            'User Management',
            style: AppTextStyles.headlineMedium,
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            'User management features will be implemented here',
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildVehiclesContent() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.directions_car,
            size: 64,
            color: AppColors.success,
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            'Vehicle Overview',
            style: AppTextStyles.headlineMedium,
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            'Vehicle overview features will be implemented here',
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.center,
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
            'Work Orders Management',
            style: AppTextStyles.headlineMedium,
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            'Work orders management features will be implemented here',
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsContent() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.analytics,
            size: 64,
            color: AppColors.info,
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            'Analytics & Reports',
            style: AppTextStyles.headlineMedium,
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            'Analytics and reporting features will be implemented here',
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsContent() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.settings,
            size: 64,
            color: AppColors.secondary,
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            'System Settings',
            style: AppTextStyles.headlineMedium,
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            'System settings features will be implemented here',
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}