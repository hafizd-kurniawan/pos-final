import 'package:flutter/material.dart';
import '../../../theme.dart';
import '../../../shared/models/app_models.dart';
import '../services/dashboard_service.dart';
import '../../auth/services/auth_service.dart';
import '../../auth/screens/login_screen.dart';
import '../../vehicles/screens/vehicles_screen.dart';
import '../../customers/screens/customers_screen.dart';
import '../../sales/screens/sales_screen.dart';
import '../../purchases/screens/purchases_screen.dart';
import '../../work_orders/screens/work_orders_screen.dart';
import '../../reports/screens/reports_screen.dart';

class MainDashboard extends StatefulWidget {
  const MainDashboard({super.key});

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  final DashboardService _dashboardService = DashboardService();
  final AuthService _authService = AuthService();
  
  User? _currentUser;
  DashboardStats? _stats;
  bool _isLoading = true;
  String? _errorMessage;
  
  int _selectedIndex = 0;
  
  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Get user profile
      final userResponse = await _authService.getProfile();
      if (userResponse.isSuccess) {
        _currentUser = userResponse.data;
        
        // Get dashboard stats based on user role
        final statsResponse = await _dashboardService.getDashboardByRole(_currentUser!.userRole);
        if (statsResponse.isSuccess) {
          _stats = statsResponse.data;
        } else {
          _errorMessage = statsResponse.error;
        }
      } else {
        _errorMessage = userResponse.error;
      }
    } catch (e) {
      _errorMessage = 'Failed to load dashboard data';
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar Navigation
          _buildSidebar(),
          
          // Main Content
          Expanded(
            child: Column(
              children: [
                // Top App Bar
                _buildTopBar(),
                
                // Content Area
                Expanded(
                  child: _buildMainContent(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 280,
      color: AppColors.white,
      child: Column(
        children: [
          // Sidebar Header
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: const BoxDecoration(
              color: AppColors.primary,
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.directions_car,
                  size: 48,
                  color: AppColors.white,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'POS Vehicle',
                  style: AppTextStyles.title.copyWith(color: AppColors.white),
                ),
                if (_currentUser != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    _currentUser!.userRole.displayName,
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.white),
                  ),
                ],
              ],
            ),
          ),
          
          // Navigation Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              children: _buildNavigationItems(),
            ),
          ),
          
          // Logout Button
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _handleLogout,
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildNavigationItems() {
    final items = <NavigationItem>[];
    
    // Common items for all roles
    items.add(NavigationItem(
      icon: Icons.dashboard,
      label: 'Dashboard',
      index: 0,
    ));
    
    if (_currentUser != null) {
      switch (_currentUser!.userRole) {
        case UserRole.admin:
          items.addAll([
            NavigationItem(icon: Icons.directions_car, label: 'Vehicles', index: 1),
            NavigationItem(icon: Icons.people, label: 'Customers', index: 2),
            NavigationItem(icon: Icons.point_of_sale, label: 'Sales', index: 3),
            NavigationItem(icon: Icons.shopping_cart, label: 'Purchases', index: 4),
            NavigationItem(icon: Icons.work, label: 'Work Orders', index: 5),
            NavigationItem(icon: Icons.analytics, label: 'Reports', index: 6),
          ]);
          break;
        case UserRole.kasir:
          items.addAll([
            NavigationItem(icon: Icons.directions_car, label: 'Vehicles', index: 1),
            NavigationItem(icon: Icons.people, label: 'Customers', index: 2),
            NavigationItem(icon: Icons.point_of_sale, label: 'Sales', index: 3),
            NavigationItem(icon: Icons.shopping_cart, label: 'Purchases', index: 4),
            NavigationItem(icon: Icons.receipt, label: 'Reports', index: 5),
          ]);
          break;
        case UserRole.mekanik:
          items.addAll([
            NavigationItem(icon: Icons.work, label: 'Work Orders', index: 1),
            NavigationItem(icon: Icons.directions_car, label: 'Vehicles', index: 2),
            NavigationItem(icon: Icons.inventory, label: 'Parts', index: 3),
          ]);
          break;
      }
    }

    return items.map((item) => _buildNavigationTile(item)).toList();
  }

  Widget _buildNavigationTile(NavigationItem item) {
    final isSelected = _selectedIndex == item.index;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: ListTile(
        leading: Icon(
          item.icon,
          color: isSelected ? AppColors.primary : AppColors.secondary,
        ),
        title: Text(
          item.label,
          style: AppTextStyles.body.copyWith(
            color: isSelected ? AppColors.primary : AppColors.onSurface,
            fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
        selected: isSelected,
        selectedTileColor: AppColors.primary.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        onTap: () => setState(() => _selectedIndex = item.index),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.border),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              _getPageTitle(),
              style: AppTextStyles.heading,
            ),
          ),
          
          // Refresh Button
          IconButton(
            onPressed: _loadDashboardData,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
          
          // Profile Info
          if (_currentUser != null) ...[
            const SizedBox(width: AppSpacing.md),
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primary,
                  child: Text(
                    _currentUser!.username.substring(0, 1).toUpperCase(),
                    style: AppTextStyles.body.copyWith(color: AppColors.white),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _currentUser!.fullName ?? _currentUser!.username,
                      style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w500),
                    ),
                    Text(
                      _currentUser!.userRole.displayName,
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade300,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              _errorMessage!,
              style: AppTextStyles.body,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton(
              onPressed: _loadDashboardData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    switch (_selectedIndex) {
      case 0:
        return _buildDashboardHome();
      case 1:
        return const VehiclesScreen();
      case 2:
        return const CustomersScreen();
      case 3:
        return const SalesScreen();
      case 4:
        return const PurchasesScreen();
      case 5:
        return const WorkOrdersScreen();
      case 6:
        return const ReportsScreen();
      default:
        return _buildDashboardHome();
    }
  }

  Widget _buildDashboardHome() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome message
          Text(
            'Welcome back, ${_currentUser?.fullName ?? _currentUser?.username ?? 'User'}!',
            style: AppTextStyles.heading,
          ),
          const SizedBox(height: AppSpacing.lg),
          
          // Stats Grid - 4 columns for tablets
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
    if (_stats == null) {
      return [
        _buildStatCard('Loading...', '--', Icons.directions_car, AppColors.primary),
        _buildStatCard('Loading...', '--', Icons.check_circle, AppColors.primaryLight),
        _buildStatCard('Loading...', '--', Icons.build, AppColors.secondary),
        _buildStatCard('Loading...', '--', Icons.sell, AppColors.primaryDark),
      ];
    }

    return [
      _buildStatCard('Total Vehicles', _stats!.totalVehicles.toString(), Icons.directions_car, AppColors.primary),
      _buildStatCard('Available', _stats!.availableVehicles.toString(), Icons.check_circle, AppColors.primaryLight),
      _buildStatCard('In Repair', _stats!.vehiclesInRepair.toString(), Icons.build, AppColors.secondary),
      _buildStatCard('Sold Today', _stats!.soldToday.toString(), Icons.sell, AppColors.primaryDark),
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
    
    if (_currentUser != null) {
      switch (_currentUser!.userRole) {
        case UserRole.admin:
          actions.addAll([
            {'title': 'Add Vehicle', 'icon': Icons.add_circle, 'color': AppColors.primary, 'index': 1},
            {'title': 'View Reports', 'icon': Icons.analytics, 'color': AppColors.secondary, 'index': 6},
            {'title': 'Manage Sales', 'icon': Icons.point_of_sale, 'color': AppColors.primaryLight, 'index': 3},
            {'title': 'Work Orders', 'icon': Icons.work, 'color': AppColors.primaryDark, 'index': 5},
          ]);
          break;
        case UserRole.kasir:
          actions.addAll([
            {'title': 'New Sale', 'icon': Icons.point_of_sale, 'color': AppColors.primary, 'index': 3},
            {'title': 'Purchase Vehicle', 'icon': Icons.shopping_cart, 'color': AppColors.secondary, 'index': 4},
            {'title': 'Customer List', 'icon': Icons.person, 'color': AppColors.primaryLight, 'index': 2},
            {'title': 'View Vehicles', 'icon': Icons.directions_car, 'color': AppColors.primaryDark, 'index': 1},
          ]);
          break;
        case UserRole.mekanik:
          actions.addAll([
            {'title': 'My Work Orders', 'icon': Icons.work, 'color': AppColors.primary, 'index': 1},
            {'title': 'Vehicle Status', 'icon': Icons.directions_car, 'color': AppColors.secondary, 'index': 2},
            {'title': 'Parts Inventory', 'icon': Icons.inventory, 'color': AppColors.primaryLight, 'index': 3},
            {'title': 'Time Log', 'icon': Icons.schedule, 'color': AppColors.primaryDark, 'index': 1},
          ]);
          break;
      }
    }

    return actions.map((action) => _buildActionCard(
      action['title'],
      action['icon'],
      action['color'],
      action['index'],
    )).toList();
  }

  Widget _buildActionCard(String title, IconData icon, Color color, int targetIndex) {
    return Card(
      child: InkWell(
        onTap: () => setState(() => _selectedIndex = targetIndex),
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

  String _getPageTitle() {
    switch (_selectedIndex) {
      case 0:
        return 'Dashboard';
      case 1:
        return 'Vehicle Management';
      case 2:
        return 'Customer Management';
      case 3:
        return 'Sales Management';
      case 4:
        return 'Purchase Management';
      case 5:
        return 'Work Orders';
      case 6:
        return 'Reports & Analytics';
      default:
        return 'Dashboard';
    }
  }

  void _handleLogout() async {
    await _authService.logout();
    
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ),
      );
    }
  }
}

class NavigationItem {
  final IconData icon;
  final String label;
  final int index;

  NavigationItem({
    required this.icon,
    required this.label,
    required this.index,
  });
}