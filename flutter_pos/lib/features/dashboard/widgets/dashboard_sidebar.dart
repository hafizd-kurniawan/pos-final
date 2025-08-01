import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_theme.dart';
import '../../../shared/providers/auth_provider.dart';
import '../screens/kasir_dashboard.dart';

class DashboardSidebar extends StatelessWidget {
  final int selectedIndex;
  final List<DashboardPage> pages;
  final Function(int) onPageSelected;
  final String userRole;

  const DashboardSidebar({
    super.key,
    required this.selectedIndex,
    required this.pages,
    required this.onPageSelected,
    required this.userRole,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          right: BorderSide(
            color: AppColors.border,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppColors.border,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.store,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'POS System',
                        style: AppTextStyles.sidebarTitle.copyWith(
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        _getRoleDisplay(userRole),
                        style: AppTextStyles.cardSubtitle.copyWith(
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Navigation Items
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: pages.length,
              itemBuilder: (context, index) {
                final page = pages[index];
                final isSelected = index == selectedIndex;
                
                return Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withOpacity(0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListTile(
                    leading: Icon(
                      page.icon,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textSecondary,
                      size: 20,
                    ),
                    title: Text(
                      page.title,
                      style: AppTextStyles.sidebarItem.copyWith(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w500,
                      ),
                    ),
                    onTap: () => onPageSelected(index),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                );
              },
            ),
          ),

          // Footer
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: AppColors.border,
                  width: 1,
                ),
              ),
            ),
            child: Consumer<AuthProvider>(
              builder: (context, authProvider, _) {
                return Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.primary,
                      child: Text(
                        authProvider.user?.initials ?? 'U',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            authProvider.user?.displayName ?? 'User',
                            style: AppTextStyles.cardTitle.copyWith(
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            authProvider.user?.role.toUpperCase() ?? 'USER',
                            style: AppTextStyles.cardSubtitle.copyWith(
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
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

  String _getRoleDisplay(String role) {
    switch (role) {
      case 'admin':
        return 'Administrator Dashboard';
      case 'kasir':
        return 'Cashier Dashboard';
      case 'mekanik':
        return 'Mechanic Dashboard';
      default:
        return 'Dashboard';
    }
  }
}