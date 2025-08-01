import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_theme.dart';
import '../../../shared/providers/auth_provider.dart';
import '../widgets/dashboard_sidebar.dart';
import '../widgets/dashboard_stats_card.dart';
import 'kasir_dashboard.dart';

class MechanicDashboard extends StatefulWidget {
  const MechanicDashboard({super.key});

  @override
  State<MechanicDashboard> createState() => _MechanicDashboardState();
}

class _MechanicDashboardState extends State<MechanicDashboard> {
  int _selectedIndex = 0;
  
  final List<DashboardPage> _pages = [
    DashboardPage(
      title: 'Work Overview',
      icon: Icons.dashboard_outlined,
      content: MechanicOverviewContent(),
    ),
    DashboardPage(
      title: 'My Work Orders',
      icon: Icons.build_outlined,
      content: Center(child: Text('My Work Orders - Coming Soon')),
    ),
    DashboardPage(
      title: 'Spare Parts',
      icon: Icons.inventory_2_outlined,
      content: Center(child: Text('Spare Parts Inventory - Coming Soon')),
    ),
    DashboardPage(
      title: 'Work History',
      icon: Icons.history_outlined,
      content: Center(child: Text('Work History - Coming Soon')),
    ),
  ];

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
            userRole: 'mekanik',
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
                                  'Welcome, ${authProvider.user?.displayName ?? 'Mechanic'}',
                                  style: AppTextStyles.cardSubtitle,
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      
                      // Mechanic Actions
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
                                      authProvider.user?.initials ?? 'M',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    authProvider.user?.displayName ?? 'Mechanic',
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

class MechanicOverviewContent extends StatelessWidget {
  const MechanicOverviewContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Work Overview',
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
                    DashboardStatsCard(
                      title: 'Pending Work Orders',
                      value: '3',
                      icon: Icons.pending_actions_outlined,
                      color: AppColors.warning,
                    ),
                    DashboardStatsCard(
                      title: 'In Progress',
                      value: '1',
                      icon: Icons.build_outlined,
                      color: AppColors.info,
                    ),
                    DashboardStatsCard(
                      title: 'Completed Today',
                      value: '2',
                      icon: Icons.check_circle_outlined,
                      color: AppColors.success,
                    ),
                    DashboardStatsCard(
                      title: 'Low Stock Items',
                      value: '5',
                      icon: Icons.warning_outlined,
                      color: AppColors.error,
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