import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/api_constants.dart';
import '../../../shared/widgets/app_widgets.dart';
import '../../../shared/models/models.dart';
import '../../vehicles/screens/vehicles_screen.dart';
import '../../sales/screens/sales_screen.dart';
import '../../customers/screens/customers_screen.dart';
import '../widgets/dashboard_overview.dart';

class MainDashboard extends StatefulWidget {
  final UserRole userRole;

  const MainDashboard({
    super.key,
    required this.userRole,
  });

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  int _selectedIndex = 0;
  int _unreadNotifications = 0;

  @override
  void initState() {
    super.initState();
    _loadUnreadNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isTablet = constraints.maxWidth > AppBreakpoints.tablet;
          
          if (isTablet) {
            return _buildTabletLayout();
          } else {
            return _buildMobileLayout();
          }
        },
      ),
    );
  }

  Widget _buildTabletLayout() {
    return Row(
      children: [
        // Sidebar Navigation
        _buildSidebar(),
        // Main Content
        Expanded(
          child: _buildMainContent(),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Scaffold(
      appBar: _buildAppBar(),
      drawer: _buildDrawer(),
      body: _buildMainContent(),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 280,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          right: BorderSide(color: AppColors.border, width: 0.5),
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.directions_car,
                    color: AppColors.onPrimary,
                    size: AppIconSizes.lg,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'POS Vehicle',
                  style: AppTextStyles.h4,
                ),
                Text(
                  widget.userRole.displayName,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
          ),
          
          const Divider(height: 1),
          
          // Navigation Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              children: _buildNavigationItems(),
            ),
          ),
          
          const Divider(height: 1),
          
          // User Actions
          _buildUserActions(),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: AppColors.primary,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.directions_car,
                  color: AppColors.onPrimary,
                  size: AppIconSizes.xl,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'POS Vehicle Management',
                  style: AppTextStyles.h4.copyWith(
                    color: AppColors.onPrimary,
                  ),
                ),
                Text(
                  widget.userRole.displayName,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.onPrimary.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              children: _buildNavigationItems(),
            ),
          ),
          _buildUserActions(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(_getPageTitle()),
      actions: [
        // Notifications
        Stack(
          children: [
            IconButton(
              onPressed: _showNotifications,
              icon: const Icon(Icons.notifications_outlined),
            ),
            if (_unreadNotifications > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    _unreadNotifications > 99 ? '99+' : _unreadNotifications.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
        // Profile
        IconButton(
          onPressed: _showProfile,
          icon: const Icon(Icons.account_circle_outlined),
        ),
      ],
    );
  }

  Widget _buildBottomNavigation() {
    final items = _getNavigationItems();
    
    return BottomNavigationBar(
      currentIndex: _selectedIndex.clamp(0, items.length - 1),
      onTap: (index) {
        setState(() {
          _selectedIndex = index;
        });
      },
      type: BottomNavigationBarType.fixed,
      items: items.take(4).map((item) {
        return BottomNavigationBarItem(
          icon: Icon(item.icon),
          label: item.label,
        );
      }).toList(),
    );
  }

  Widget _buildMainContent() {
    final pages = _getPages();
    
    return IndexedStack(
      index: _selectedIndex.clamp(0, pages.length - 1),
      children: pages,
    );
  }

  List<NavigationItem> _getNavigationItems() {
    final baseItems = [
      NavigationItem(
        icon: Icons.dashboard_outlined,
        label: 'Dashboard',
        index: 0,
      ),
    ];

    switch (widget.userRole) {
      case UserRole.admin:
        return [
          ...baseItems,
          NavigationItem(icon: Icons.directions_car_outlined, label: 'Vehicles', index: 1),
          NavigationItem(icon: Icons.people_outlined, label: 'Customers', index: 2),
          NavigationItem(icon: Icons.receipt_long_outlined, label: 'Sales', index: 3),
          NavigationItem(icon: Icons.shopping_cart_outlined, label: 'Purchases', index: 4),
          NavigationItem(icon: Icons.build_outlined, label: 'Work Orders', index: 5),
          NavigationItem(icon: Icons.inventory_outlined, label: 'Inventory', index: 6),
          NavigationItem(icon: Icons.people_alt_outlined, label: 'Users', index: 7),
          NavigationItem(icon: Icons.analytics_outlined, label: 'Reports', index: 8),
        ];
      
      case UserRole.kasir:
        return [
          ...baseItems,
          NavigationItem(icon: Icons.directions_car_outlined, label: 'Vehicles', index: 1),
          NavigationItem(icon: Icons.people_outlined, label: 'Customers', index: 2),
          NavigationItem(icon: Icons.receipt_long_outlined, label: 'Sales', index: 3),
          NavigationItem(icon: Icons.shopping_cart_outlined, label: 'Purchases', index: 4),
          NavigationItem(icon: Icons.analytics_outlined, label: 'Reports', index: 5),
        ];
      
      case UserRole.mekanik:
        return [
          ...baseItems,
          NavigationItem(icon: Icons.build_outlined, label: 'Work Orders', index: 1),
          NavigationItem(icon: Icons.inventory_outlined, label: 'Parts', index: 2),
          NavigationItem(icon: Icons.directions_car_outlined, label: 'Vehicles', index: 3),
        ];
    }
  }

  List<Widget> _buildNavigationItems() {
    return _getNavigationItems().map((item) {
      final isSelected = _selectedIndex == item.index;
      
      return ListTile(
        leading: Icon(
          item.icon,
          color: isSelected ? AppColors.primary : AppColors.secondary,
        ),
        title: Text(
          item.label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: isSelected ? AppColors.primary : AppColors.onSurface,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        selected: isSelected,
        selectedColor: AppColors.primary,
        selectedTileColor: AppColors.primaryContainer,
        onTap: () {
          setState(() {
            _selectedIndex = item.index;
          });
          
          // Close drawer on mobile
          if (Scaffold.of(context).hasDrawer) {
            Navigator.pop(context);
          }
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.xs,
        ),
      );
    }).toList();
  }

  Widget _buildUserActions() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.error),
            title: Text(
              'Logout',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.error,
              ),
            ),
            onTap: _handleLogout,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _getPages() {
    final basePages = [
      DashboardOverview(userRole: widget.userRole),
    ];

    switch (widget.userRole) {
      case UserRole.admin:
        return [
          ...basePages,
          const VehiclesScreen(),
          const CustomersScreen(),
          const SalesScreen(),
          const Center(child: Text('Purchases Screen')), // Placeholder
          const Center(child: Text('Work Orders Screen')), // Placeholder
          const Center(child: Text('Inventory Screen')), // Placeholder
          const Center(child: Text('Users Screen')), // Placeholder
          const Center(child: Text('Reports Screen')), // Placeholder
        ];
      
      case UserRole.kasir:
        return [
          ...basePages,
          const VehiclesScreen(),
          const CustomersScreen(),
          const SalesScreen(),
          const Center(child: Text('Purchases Screen')), // Placeholder
          const Center(child: Text('Reports Screen')), // Placeholder
        ];
      
      case UserRole.mekanik:
        return [
          ...basePages,
          const Center(child: Text('Work Orders Screen')), // Placeholder
          const Center(child: Text('Parts Screen')), // Placeholder
          const VehiclesScreen(),
        ];
    }
  }

  String _getPageTitle() {
    final items = _getNavigationItems();
    if (_selectedIndex < items.length) {
      return items[_selectedIndex].label;
    }
    return 'Dashboard';
  }

  void _loadUnreadNotifications() {
    // Simulate loading unread notifications
    setState(() {
      _unreadNotifications = 3; // Demo value
    });
  }

  void _showNotifications() {
    // Navigate to notifications screen
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notifications'),
        content: const Text('Notification system will be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showProfile() {
    // Navigate to profile screen
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Profile'),
        content: Text('User: ${widget.userRole.displayName}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
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