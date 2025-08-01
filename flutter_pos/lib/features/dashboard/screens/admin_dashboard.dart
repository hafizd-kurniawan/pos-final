import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_theme.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/providers/vehicle_provider.dart';
import '../../../shared/providers/customer_provider.dart';
import '../../../shared/providers/notification_provider.dart';
import '../widgets/dashboard_sidebar.dart';
import '../widgets/dashboard_stats_card.dart';
import 'kasir_dashboard.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;
  
  final List<DashboardPage> _pages = [
    DashboardPage(
      title: 'Admin Overview',
      icon: Icons.dashboard_outlined,
      content: AdminOverviewContent(),
    ),
    DashboardPage(
      title: 'User Management',
      icon: Icons.people_outline,
      content: Center(child: Text('User Management - Coming Soon')),
    ),
    DashboardPage(
      title: 'System Analytics',
      icon: Icons.analytics_outlined,
      content: Center(child: Text('System Analytics - Coming Soon')),
    ),
    DashboardPage(
      title: 'Reports',
      icon: Icons.assessment_outlined,
      content: Center(child: Text('Advanced Reports - Coming Soon')),
    ),
    DashboardPage(
      title: 'Settings',
      icon: Icons.settings_outlined,
      content: Center(child: Text('System Settings - Coming Soon')),
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

    await Future.wait([
      vehicleProvider.loadVehicles(refresh: true),
      customerProvider.loadCustomers(refresh: true),
      notificationProvider.loadNotifications(refresh: true),
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
            userRole: 'admin',
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
                                  'Welcome, ${authProvider.user?.displayName ?? 'Admin'}',
                                  style: AppTextStyles.cardSubtitle,
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      
                      // Admin Actions
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
                                      authProvider.user?.initials ?? 'A',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    authProvider.user?.displayName ?? 'Admin',
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
}

class AdminOverviewContent extends StatelessWidget {
  const AdminOverviewContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'System Overview',
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
                    Consumer<CustomerProvider>(
                      builder: (context, customerProvider, _) {
                        return DashboardStatsCard(
                          title: 'Total Customers',
                          value: customerProvider.customers.length.toString(),
                          icon: Icons.people_outline,
                          color: AppColors.info,
                        );
                      },
                    ),
                    DashboardStatsCard(
                      title: 'Today Sales',
                      value: '0',
                      icon: Icons.point_of_sale_outlined,
                      color: AppColors.success,
                    ),
                    DashboardStatsCard(
                      title: 'Active Users',
                      value: '4',
                      icon: Icons.supervisor_account_outlined,
                      color: AppColors.warning,
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