import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/api_constants.dart';
import '../../../shared/widgets/app_widgets.dart';
import '../../../shared/models/models.dart';

class SimpleDashboard extends StatefulWidget {
  final UserRole userRole;

  const SimpleDashboard({
    super.key,
    required this.userRole,
  });

  @override
  State<SimpleDashboard> createState() => _SimpleDashboardState();
}

class _SimpleDashboardState extends State<SimpleDashboard> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.userRole.displayName} Dashboard'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: _buildMainContent(),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildMainContent() {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboardHome();
      case 1:
        return _buildVehiclesPage();
      case 2:
        return _buildSalesPage();
      case 3:
        return _buildCustomersPage();
      default:
        return _buildDashboardHome();
    }
  }

  Widget _buildDashboardHome() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome, ${widget.userRole.displayName}!',
                    style: AppTextStyles.h3,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Modern Point of Sale System for Vehicle Management',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          
          // Quick stats
          Text(
            'Quick Overview',
            style: AppTextStyles.h4,
          ),
          const SizedBox(height: AppSpacing.md),
          
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: AppSpacing.md,
            mainAxisSpacing: AppSpacing.md,
            children: [
              _buildStatCard(
                'Total Vehicles',
                '25',
                Icons.directions_car,
                AppColors.primary,
              ),
              _buildStatCard(
                'Available',
                '18',
                Icons.check_circle,
                AppColors.success,
              ),
              _buildStatCard(
                'In Repair',
                '5',
                Icons.build,
                AppColors.warning,
              ),
              _buildStatCard(
                'Sold Today',
                '2',
                Icons.sold,
                AppColors.error,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          
          // Quick actions
          Text(
            'Quick Actions',
            style: AppTextStyles.h4,
          ),
          const SizedBox(height: AppSpacing.md),
          
          _buildQuickActionsGrid(),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: AppIconSizes.lg),
                const Spacer(),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              value,
              style: AppTextStyles.h2.copyWith(color: color),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              title,
              style: AppTextStyles.labelMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsGrid() {
    final actions = _getQuickActions();
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
        childAspectRatio: 1.5,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) {
        final action = actions[index];
        return Card(
          child: InkWell(
            onTap: action['onTap'],
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    action['icon'],
                    size: AppIconSizes.lg,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    action['title'],
                    style: AppTextStyles.labelLarge,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  List<Map<String, dynamic>> _getQuickActions() {
    switch (widget.userRole) {
      case UserRole.admin:
        return [
          {
            'title': 'Add Vehicle',
            'icon': Icons.add_circle,
            'onTap': () => _showMessage('Add Vehicle feature'),
          },
          {
            'title': 'New Sale',
            'icon': Icons.point_of_sale,
            'onTap': () => _showMessage('New Sale feature'),
          },
          {
            'title': 'Reports',
            'icon': Icons.analytics,
            'onTap': () => _showMessage('Reports feature'),
          },
          {
            'title': 'Users',
            'icon': Icons.people,
            'onTap': () => _showMessage('User management feature'),
          },
        ];
      case UserRole.kasir:
        return [
          {
            'title': 'New Sale',
            'icon': Icons.point_of_sale,
            'onTap': () => _showMessage('New Sale feature'),
          },
          {
            'title': 'Customers',
            'icon': Icons.people,
            'onTap': () => _showMessage('Customer management feature'),
          },
          {
            'title': 'Purchase',
            'icon': Icons.shopping_cart,
            'onTap': () => _showMessage('Purchase feature'),
          },
          {
            'title': 'Invoices',
            'icon': Icons.receipt,
            'onTap': () => _showMessage('Invoice management feature'),
          },
        ];
      case UserRole.mekanik:
        return [
          {
            'title': 'Work Orders',
            'icon': Icons.build,
            'onTap': () => _showMessage('Work Orders feature'),
          },
          {
            'title': 'Parts',
            'icon': Icons.settings,
            'onTap': () => _showMessage('Parts management feature'),
          },
        ];
    }
  }

  Widget _buildVehiclesPage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.directions_car,
            size: 64,
            color: AppColors.primary,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Vehicle Inventory',
            style: AppTextStyles.h3,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Vehicle management features coming soon...',
            style: AppTextStyles.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildSalesPage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.point_of_sale,
            size: 64,
            color: AppColors.primary,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Sales Management',
            style: AppTextStyles.h3,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Sales management features coming soon...',
            style: AppTextStyles.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildCustomersPage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.people,
            size: 64,
            color: AppColors.primary,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Customer Management',
            style: AppTextStyles.h3,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Customer management features coming soon...',
            style: AppTextStyles.bodyMedium,
          ),
        ],
      ),
    );
  }

  BottomNavigationBar _buildBottomNavigation() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) {
        setState(() {
          _selectedIndex = index;
        });
      },
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.secondary,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.directions_car),
          label: 'Vehicles',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.point_of_sale),
          label: 'Sales',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people),
          label: 'Customers',
        ),
      ],
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _logout() {
    Navigator.of(context).pushReplacementNamed('/');
    // In a real app, clear authentication state
  }
}