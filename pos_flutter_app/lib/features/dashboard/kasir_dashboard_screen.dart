import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../shared/providers/auth_provider.dart';
import '../../shared/providers/notification_provider.dart';
import '../../core/widgets/dashboard_layout.dart';
import '../../core/widgets/stats_card.dart';
import '../vehicles/vehicle_management_widget.dart';

class KasirDashboardScreen extends StatefulWidget {
  const KasirDashboardScreen({super.key});

  @override
  State<KasirDashboardScreen> createState() => _KasirDashboardScreenState();
}

class _KasirDashboardScreenState extends State<KasirDashboardScreen> {
  String _selectedMenuItem = 'dashboard';

  @override
  void initState() {
    super.initState();
    // Load notifications on startup
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().loadNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DashboardLayout(
      title: 'Kasir Dashboard',
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
          id: 'sales',
          label: 'Sales Management',
          icon: Icons.point_of_sale,
        ),
        DashboardMenuItem(
          id: 'vehicles',
          label: 'Vehicle Inventory',
          icon: Icons.directions_car,
        ),
        DashboardMenuItem(
          id: 'customers',
          label: 'Customer Management',
          icon: Icons.people,
        ),
        DashboardMenuItem(
          id: 'purchases',
          label: 'Purchase Management',
          icon: Icons.shopping_cart,
        ),
        DashboardMenuItem(
          id: 'reports',
          label: 'Reports',
          icon: Icons.analytics,
        ),
      ],
      body: _buildSelectedContent(),
    );
  }

  Widget _buildSelectedContent() {
    switch (_selectedMenuItem) {
      case 'dashboard':
        return _buildDashboardContent();
      case 'sales':
        return _buildSalesContent();
      case 'vehicles':
        return _buildVehiclesContent();
      case 'customers':
        return _buildCustomersContent();
      case 'purchases':
        return _buildPurchasesContent();
      case 'reports':
        return _buildReportsContent();
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
                colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
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
                      'Welcome back, ${authProvider.currentUser?.fullName ?? 'Kasir'}!',
                      style: AppTextStyles.headlineMedium.copyWith(
                        color: AppColors.white,
                      ),
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Ready to manage vehicle sales and customer transactions',
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
            'Quick Overview',
            style: AppTextStyles.headlineSmall,
          ),
          const SizedBox(height: AppSpacing.md),
          
          LayoutBuilder(
            builder: (context, constraints) {
              // Responsive grid - 4 columns on tablet, 2 on mobile
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
                    title: 'Available Vehicles',
                    value: '24',
                    icon: Icons.directions_car,
                    color: AppColors.success,
                    subtitle: 'Ready for sale',
                  ),
                  StatsCard(
                    title: 'Today\'s Sales',
                    value: '8',
                    icon: Icons.trending_up,
                    color: AppColors.primary,
                    subtitle: 'Transactions',
                  ),
                  StatsCard(
                    title: 'Pending Repairs',
                    value: '12',
                    icon: Icons.build,
                    color: AppColors.warning,
                    subtitle: 'In workshop',
                  ),
                  StatsCard(
                    title: 'Total Revenue',
                    value: 'Rp 245M',
                    icon: Icons.monetization_on,
                    color: AppColors.info,
                    subtitle: 'This month',
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: AppSpacing.xl),

          // Quick Actions
          Text(
            'Quick Actions',
            style: AppTextStyles.headlineSmall,
          ),
          const SizedBox(height: AppSpacing.md),
          
          LayoutBuilder(
            builder: (context, constraints) {
              final isTablet = constraints.maxWidth > 600;
              final crossAxisCount = isTablet ? 4 : 2;
              
              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: AppSpacing.md,
                mainAxisSpacing: AppSpacing.md,
                childAspectRatio: 1.5,
                children: [
                  _buildQuickActionCard(
                    'Create Sale',
                    Icons.add_shopping_cart,
                    AppColors.primary,
                    () => setState(() => _selectedMenuItem = 'sales'),
                  ),
                  _buildQuickActionCard(
                    'Add Vehicle',
                    Icons.add_circle,
                    AppColors.success,
                    () => setState(() => _selectedMenuItem = 'vehicles'),
                  ),
                  _buildQuickActionCard(
                    'New Customer',
                    Icons.person_add,
                    AppColors.info,
                    () => setState(() => _selectedMenuItem = 'customers'),
                  ),
                  _buildQuickActionCard(
                    'View Reports',
                    Icons.assessment,
                    AppColors.secondary,
                    () => setState(() => _selectedMenuItem = 'reports'),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppBorderRadius.md),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppBorderRadius.circular),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 32,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                title,
                style: AppTextStyles.labelLarge,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSalesContent() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.point_of_sale,
            size: 64,
            color: AppColors.primary,
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            'Sales Management',
            style: AppTextStyles.headlineMedium,
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            'Sales management features will be implemented here',
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildVehiclesContent() {
    return const VehicleManagementWidget();
  }

  Widget _buildCustomersContent() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people,
            size: 64,
            color: AppColors.info,
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            'Customer Management',
            style: AppTextStyles.headlineMedium,
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            'Customer management features will be implemented here',
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPurchasesContent() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart,
            size: 64,
            color: AppColors.warning,
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            'Purchase Management',
            style: AppTextStyles.headlineMedium,
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            'Purchase management features will be implemented here',
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildReportsContent() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.analytics,
            size: 64,
            color: AppColors.secondary,
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            'Reports & Analytics',
            style: AppTextStyles.headlineMedium,
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            'Reports and analytics features will be implemented here',
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}