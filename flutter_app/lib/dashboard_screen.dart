import 'package:flutter/material.dart';
import 'theme.dart';

class DashboardScreen extends StatefulWidget {
  final String userRole;

  const DashboardScreen({
    super.key,
    required this.userRole,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.userRole} Dashboard'),
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
        return _buildReportsPage();
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
          Text(
            'Welcome, ${widget.userRole}!',
            style: AppTextStyles.heading,
          ),
          const SizedBox(height: AppSpacing.lg),
          
          // Stats Grid - 4 columns for tablet
          LayoutBuilder(
            builder: (context, constraints) {
              final screenWidth = constraints.maxWidth;
              final isTablet = screenWidth > 768;
              final columns = isTablet ? 4 : 2;
              
              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: columns,
                crossAxisSpacing: AppSpacing.md,
                mainAxisSpacing: AppSpacing.md,
                childAspectRatio: 1.2,
                children: _buildStatsCards(),
              );
            },
          ),
          
          const SizedBox(height: AppSpacing.xl),
          
          // Quick Actions
          Text(
            'Quick Actions',
            style: AppTextStyles.title,
          ),
          const SizedBox(height: AppSpacing.md),
          
          LayoutBuilder(
            builder: (context, constraints) {
              final screenWidth = constraints.maxWidth;
              final isTablet = screenWidth > 768;
              final columns = isTablet ? 4 : 2;
              
              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: columns,
                crossAxisSpacing: AppSpacing.md,
                mainAxisSpacing: AppSpacing.md,
                childAspectRatio: 1.0,
                children: _buildQuickActions(),
              );
            },
          ),
        ],
      ),
    );
  }

  List<Widget> _buildStatsCards() {
    return [
      _buildStatCard('Total Vehicles', '45', Icons.directions_car, AppColors.primary),
      _buildStatCard('Available', '28', Icons.check_circle, AppColors.primaryLight),
      _buildStatCard('In Repair', '12', Icons.build, AppColors.secondary),
      _buildStatCard('Sold Today', '5', Icons.sell, AppColors.primaryDark),
    ];
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: AppSpacing.sm),
            Text(
              value,
              style: AppTextStyles.heading.copyWith(color: color),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              title,
              style: AppTextStyles.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildQuickActions() {
    final actions = <Map<String, dynamic>>[];
    
    if (widget.userRole == 'Admin') {
      actions.addAll([
        {'title': 'Add Vehicle', 'icon': Icons.add_circle, 'color': AppColors.primary},
        {'title': 'Manage Users', 'icon': Icons.people, 'color': AppColors.secondary},
        {'title': 'View Reports', 'icon': Icons.analytics, 'color': AppColors.primaryLight},
        {'title': 'Settings', 'icon': Icons.settings, 'color': AppColors.primaryDark},
      ]);
    } else if (widget.userRole == 'Kasir') {
      actions.addAll([
        {'title': 'New Sale', 'icon': Icons.point_of_sale, 'color': AppColors.primary},
        {'title': 'Purchase Vehicle', 'icon': Icons.shopping_cart, 'color': AppColors.secondary},
        {'title': 'Customer List', 'icon': Icons.person, 'color': AppColors.primaryLight},
        {'title': 'Daily Report', 'icon': Icons.receipt, 'color': AppColors.primaryDark},
      ]);
    } else if (widget.userRole == 'Mekanik') {
      actions.addAll([
        {'title': 'Work Orders', 'icon': Icons.work, 'color': AppColors.primary},
        {'title': 'Parts Inventory', 'icon': Icons.inventory, 'color': AppColors.secondary},
        {'title': 'My Tasks', 'icon': Icons.task, 'color': AppColors.primaryLight},
        {'title': 'Time Log', 'icon': Icons.schedule, 'color': AppColors.primaryDark},
      ]);
    }

    return actions.map((action) => _buildActionCard(
      action['title'],
      action['icon'],
      action['color'],
    )).toList();
  }

  Widget _buildActionCard(String title, IconData icon, Color color) {
    return Card(
      child: InkWell(
        onTap: () => _showActionDialog(title),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: AppSpacing.md),
              Text(
                title,
                style: AppTextStyles.body,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVehiclesPage() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Vehicle Inventory', style: AppTextStyles.heading),
              ElevatedButton.icon(
                onPressed: () => _showActionDialog('Add Vehicle'),
                icon: const Icon(Icons.add),
                label: const Text('Add Vehicle'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final screenWidth = constraints.maxWidth;
                final isTablet = screenWidth > 768;
                final columns = isTablet ? 4 : 2;
                
                return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    crossAxisSpacing: AppSpacing.md,
                    mainAxisSpacing: AppSpacing.md,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: 12,
                  itemBuilder: (context, index) => _buildVehicleCard(index),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleCard(int index) {
    final vehicles = [
      {'brand': 'Toyota', 'model': 'Avanza', 'year': '2020', 'status': 'Available'},
      {'brand': 'Honda', 'model': 'Civic', 'year': '2019', 'status': 'In Repair'},
      {'brand': 'Suzuki', 'model': 'Ertiga', 'year': '2021', 'status': 'Available'},
      {'brand': 'Daihatsu', 'model': 'Xenia', 'year': '2018', 'status': 'Sold'},
    ];
    
    final vehicle = vehicles[index % vehicles.length];
    final statusColor = vehicle['status'] == 'Available' 
        ? AppColors.primary 
        : vehicle['status'] == 'In Repair' 
            ? AppColors.secondary 
            : AppColors.primaryDark;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Vehicle Photo Placeholder
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.directions_car,
                size: 48,
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            
            Text(
              '${vehicle['brand']} ${vehicle['model']}',
              style: AppTextStyles.title.copyWith(fontSize: 16),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              'Year: ${vehicle['year']}',
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(height: AppSpacing.xs),
            
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                vehicle['status']!,
                style: AppTextStyles.bodySmall.copyWith(
                  color: statusColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSalesPage() {
    return const Center(
      child: Text('Sales Management', style: AppTextStyles.heading),
    );
  }

  Widget _buildReportsPage() {
    return const Center(
      child: Text('Reports & Analytics', style: AppTextStyles.heading),
    );
  }

  Widget _buildBottomNavigation() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) => setState(() => _selectedIndex = index),
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
          icon: Icon(Icons.analytics),
          label: 'Reports',
        ),
      ],
    );
  }

  void _showActionDialog(String action) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(action),
        content: Text('$action feature will be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _logout() {
    Navigator.pop(context);
  }
}