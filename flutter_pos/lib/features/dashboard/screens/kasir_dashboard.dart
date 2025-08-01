import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_theme.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/providers/vehicle_provider.dart';
import '../../../shared/providers/customer_provider.dart';
import '../../../shared/providers/notification_provider.dart';
import '../widgets/dashboard_sidebar.dart';
import '../widgets/dashboard_stats_card.dart';
import '../../vehicles/screens/vehicle_grid_screen.dart';
import '../../customers/screens/customer_grid_screen.dart';

class KasirDashboard extends StatefulWidget {
  const KasirDashboard({super.key});

  @override
  State<KasirDashboard> createState() => _KasirDashboardState();
}

class _KasirDashboardState extends State<KasirDashboard> {
  int _selectedIndex = 0;
  
  final List<DashboardPage> _pages = [
    DashboardPage(
      title: 'Dashboard Overview',
      icon: Icons.dashboard_outlined,
      content: DashboardOverviewContent(),
    ),
    DashboardPage(
      title: 'Vehicle Management',
      icon: Icons.directions_car_outlined,
      content: VehicleGridScreen(),
    ),
    DashboardPage(
      title: 'Customer Management',
      icon: Icons.people_outline,
      content: CustomerGridScreen(),
    ),
    DashboardPage(
      title: 'Sales Management',
      icon: Icons.point_of_sale_outlined,
      content: Center(child: Text('Sales Management - Coming Soon')),
    ),
    DashboardPage(
      title: 'Purchase Management',
      icon: Icons.shopping_cart_outlined,
      content: Center(child: Text('Purchase Management - Coming Soon')),
    ),
    DashboardPage(
      title: 'Reports',
      icon: Icons.analytics_outlined,
      content: Center(child: Text('Reports - Coming Soon')),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final vehicleProvider = context.read<VehicleProvider>();
    final customerProvider = context.read<CustomerProvider>();
    final notificationProvider = context.read<NotificationProvider>();

    // Load initial data
    await Future.wait([
      vehicleProvider.loadVehicles(refresh: true),
      vehicleProvider.loadCategories(),
      customerProvider.loadCustomers(refresh: true),
      notificationProvider.loadNotifications(refresh: true),
      notificationProvider.loadUnreadCount(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          DashboardSidebar(
            selectedIndex: _selectedIndex,
            pages: _pages,
            onPageSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            userRole: 'kasir',
          ),
          
          // Main Content
          Expanded(
            child: Column(
              children: [
                // App Bar
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    border: Border(
                      bottom: BorderSide(
                        color: AppColors.border,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _pages[_selectedIndex].title,
                              style: AppTextStyles.sidebarTitle,
                            ),
                            Consumer<AuthProvider>(
                              builder: (context, authProvider, _) {
                                return Text(
                                  'Welcome, ${authProvider.user?.displayName ?? 'Kasir'}',
                                  style: AppTextStyles.cardSubtitle,
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      
                      // Notification Icon
                      Consumer<NotificationProvider>(
                        builder: (context, notificationProvider, _) {
                          return Stack(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.notifications_outlined),
                                onPressed: () {
                                  _showNotifications(context);
                                },
                              ),
                              if (notificationProvider.hasUnread)
                                Positioned(
                                  right: 8,
                                  top: 8,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: AppColors.error,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    constraints: const BoxConstraints(
                                      minWidth: 16,
                                      minHeight: 16,
                                    ),
                                    child: Text(
                                      notificationProvider.unreadCount.toString(),
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
                          );
                        },
                      ),
                      
                      const SizedBox(width: 8),
                      
                      // User Menu
                      Consumer<AuthProvider>(
                        builder: (context, authProvider, _) {
                          return PopupMenuButton<String>(
                            offset: const Offset(0, 40),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceVariant,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircleAvatar(
                                    radius: 16,
                                    backgroundColor: AppColors.primary,
                                    child: Text(
                                      authProvider.user?.initials ?? 'K',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    authProvider.user?.displayName ?? 'Kasir',
                                    style: AppTextStyles.cardSubtitle,
                                  ),
                                  const Icon(
                                    Icons.arrow_drop_down,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'profile',
                                child: Row(
                                  children: [
                                    Icon(Icons.person_outline),
                                    SizedBox(width: 8),
                                    Text('Profile'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'settings',
                                child: Row(
                                  children: [
                                    Icon(Icons.settings_outlined),
                                    SizedBox(width: 8),
                                    Text('Settings'),
                                  ],
                                ),
                              ),
                              const PopupMenuDivider(),
                              const PopupMenuItem(
                                value: 'logout',
                                child: Row(
                                  children: [
                                    Icon(Icons.logout_outlined),
                                    SizedBox(width: 8),
                                    Text('Logout'),
                                  ],
                                ),
                              ),
                            ],
                            onSelected: (value) async {
                              switch (value) {
                                case 'profile':
                                  // TODO: Show profile dialog
                                  break;
                                case 'settings':
                                  // TODO: Show settings dialog
                                  break;
                                case 'logout':
                                  await authProvider.logout();
                                  break;
                              }
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
                
                // Page Content
                Expanded(
                  child: _pages[_selectedIndex].content,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showNotifications(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: 400,
          height: 500,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Notifications',
                    style: AppTextStyles.sidebarTitle,
                  ),
                  Consumer<NotificationProvider>(
                    builder: (context, notificationProvider, _) {
                      return TextButton(
                        onPressed: notificationProvider.hasUnread
                            ? () => notificationProvider.markAllAsRead()
                            : null,
                        child: const Text('Mark All Read'),
                      );
                    },
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: Consumer<NotificationProvider>(
                  builder: (context, notificationProvider, _) {
                    if (notificationProvider.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (notificationProvider.notifications.isEmpty) {
                      return const Center(
                        child: Text('No notifications'),
                      );
                    }

                    return ListView.builder(
                      itemCount: notificationProvider.notifications.length,
                      itemBuilder: (context, index) {
                        final notification = notificationProvider.notifications[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: notification.isRead
                                ? AppColors.surfaceVariant
                                : AppColors.primary,
                            child: Icon(
                              _getNotificationIcon(notification.type),
                              color: notification.isRead
                                  ? AppColors.textSecondary
                                  : Colors.white,
                              size: 16,
                            ),
                          ),
                          title: Text(
                            notification.title,
                            style: TextStyle(
                              fontWeight: notification.isRead
                                  ? FontWeight.normal
                                  : FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(notification.message),
                          trailing: Text(
                            notification.timeAgo,
                            style: AppTextStyles.cardSubtitle.copyWith(
                              fontSize: 12,
                            ),
                          ),
                          onTap: () {
                            if (!notification.isRead) {
                              notificationProvider.markAsRead(notification.id);
                            }
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'work_order':
        return Icons.build_outlined;
      case 'low_stock':
        return Icons.warning_outlined;
      case 'sales':
        return Icons.point_of_sale_outlined;
      case 'purchase':
        return Icons.shopping_cart_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }
}

class DashboardPage {
  final String title;
  final IconData icon;
  final Widget content;

  DashboardPage({
    required this.title,
    required this.icon,
    required this.content,
  });
}

class DashboardOverviewContent extends StatelessWidget {
  const DashboardOverviewContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Overview',
            style: AppTextStyles.sidebarTitle,
          ),
          const SizedBox(height: 16),
          
          // Stats Grid
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isTablet = constraints.maxWidth > 600;
                final crossAxisCount = isTablet ? 4 : 2;
                
                return GridView.count(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.5,
                  children: [
                    Consumer<VehicleProvider>(
                      builder: (context, vehicleProvider, _) {
                        return DashboardStatsCard(
                          title: 'Total Vehicles',
                          value: vehicleProvider.vehicles.length.toString(),
                          icon: Icons.directions_car_outlined,
                          color: AppColors.primary,
                        );
                      },
                    ),
                    Consumer<VehicleProvider>(
                      builder: (context, vehicleProvider, _) {
                        final available = vehicleProvider.availableVehicles.length;
                        return DashboardStatsCard(
                          title: 'Available',
                          value: available.toString(),
                          icon: Icons.check_circle_outline,
                          color: AppColors.success,
                        );
                      },
                    ),
                    Consumer<CustomerProvider>(
                      builder: (context, customerProvider, _) {
                        return DashboardStatsCard(
                          title: 'Customers',
                          value: customerProvider.customers.length.toString(),
                          icon: Icons.people_outline,
                          color: AppColors.info,
                        );
                      },
                    ),
                    Consumer<NotificationProvider>(
                      builder: (context, notificationProvider, _) {
                        return DashboardStatsCard(
                          title: 'Notifications',
                          value: notificationProvider.unreadCount.toString(),
                          icon: Icons.notifications_outlined,
                          color: AppColors.warning,
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}