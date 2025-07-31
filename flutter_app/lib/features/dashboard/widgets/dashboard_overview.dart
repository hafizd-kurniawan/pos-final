import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/api_constants.dart';
import '../../../shared/widgets/app_widgets.dart';
import '../../../shared/models/models.dart';

class DashboardOverview extends StatefulWidget {
  final UserRole userRole;

  const DashboardOverview({
    super.key,
    required this.userRole,
  });

  @override
  State<DashboardOverview> createState() => _DashboardOverviewState();
}

class _DashboardOverviewState extends State<DashboardOverview> {
  DashboardMetrics? _metrics;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.userRole.displayName} Dashboard'),
        automaticallyImplyLeading: false,
      ),
      body: _isLoading
          ? const AppLoading(message: 'Loading dashboard...')
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildWelcomeSection(),
                  const SizedBox(height: AppSpacing.lg),
                  _buildQuickMetrics(),
                  const SizedBox(height: AppSpacing.lg),
                  _buildQuickActions(),
                  const SizedBox(height: AppSpacing.lg),
                  _buildRecentActivity(),
                ],
              ),
            ),
    );
  }

  Widget _buildWelcomeSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadius.large,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome back!',
            style: AppTextStyles.h3.copyWith(
              color: AppColors.onPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Here\'s what\'s happening in your ${widget.userRole.displayName.toLowerCase()} dashboard today.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.onPrimary.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Icon(
                Icons.access_time,
                color: AppColors.onPrimary.withOpacity(0.8),
                size: AppIconSizes.sm,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                _getCurrentTime(),
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.onPrimary.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickMetrics() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Overview',
          style: AppTextStyles.h4,
        ),
        const SizedBox(height: AppSpacing.md),
        LayoutBuilder(
          builder: (context, constraints) {
            // Calculate item width for 4-column grid with responsive design
            final screenWidth = constraints.maxWidth;
            final isTablet = screenWidth > AppBreakpoints.tablet;
            final columns = isTablet ? 4 : 2;
            final spacing = AppSpacing.gridSpacing;
            final itemWidth = (screenWidth - (spacing * (columns - 1))) / columns;
            
            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: _getMetricCards().map((card) {
                return SizedBox(
                  width: itemWidth,
                  child: card,
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: AppTextStyles.h4,
        ),
        const SizedBox(height: AppSpacing.md),
        LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = constraints.maxWidth;
            final isTablet = screenWidth > AppBreakpoints.tablet;
            final columns = isTablet ? 4 : 2;
            final spacing = AppSpacing.gridSpacing;
            final itemWidth = (screenWidth - (spacing * (columns - 1))) / columns;
            
            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: _getActionCards().map((card) {
                return SizedBox(
                  width: itemWidth,
                  child: card,
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
          style: AppTextStyles.h4,
        ),
        const SizedBox(height: AppSpacing.md),
        AppCard(
          child: Column(
            children: [
              _buildActivityItem(
                'Vehicle Added',
                'Toyota Avanza 2023 added to inventory',
                '2 hours ago',
                Icons.directions_car,
                AppColors.success,
              ),
              const Divider(height: 1),
              _buildActivityItem(
                'Sale Completed',
                'Honda Civic sold to customer C001',
                '4 hours ago',
                Icons.receipt_long,
                AppColors.primary,
              ),
              const Divider(height: 1),
              _buildActivityItem(
                'Work Order Created',
                'Repair job assigned to Mechanic 1',
                '6 hours ago',
                Icons.build,
                AppColors.warning,
              ),
              const Divider(height: 1),
              _buildActivityItem(
                'Low Stock Alert',
                'Brake pads running low in inventory',
                '1 day ago',
                Icons.warning,
                AppColors.error,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem(
    String title,
    String description,
    String time,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              icon,
              color: color,
              size: AppIconSizes.sm,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.labelLarge,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  description,
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
          Text(
            time,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.secondary,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _getMetricCards() {
    if (_metrics == null) return [];

    final baseMetrics = [
      MetricCard(
        label: 'Total Vehicles',
        value: _metrics!.totalVehicles.toString(),
        icon: Icons.directions_car,
        color: AppColors.primary,
        trend: '+5.2%',
        isPositiveTrend: true,
      ),
      MetricCard(
        label: 'Available',
        value: _metrics!.availableVehicles.toString(),
        icon: Icons.check_circle,
        color: AppColors.success,
      ),
      MetricCard(
        label: 'In Repair',
        value: _metrics!.vehiclesInRepair.toString(),
        icon: Icons.build_circle,
        color: AppColors.warning,
      ),
      MetricCard(
        label: 'Total Sales',
        value: _metrics!.totalSales.toString(),
        icon: Icons.trending_up,
        color: AppColors.primary,
        trend: '+12.3%',
        isPositiveTrend: true,
      ),
    ];

    switch (widget.userRole) {
      case UserRole.admin:
        return [
          ...baseMetrics,
          MetricCard(
            label: 'Total Revenue',
            value: 'Rp ${_formatCurrency(_metrics!.totalRevenue)}',
            icon: Icons.account_balance_wallet,
            color: AppColors.success,
            trend: '+8.7%',
            isPositiveTrend: true,
          ),
          MetricCard(
            label: 'Total Profit',
            value: 'Rp ${_formatCurrency(_metrics!.totalProfit)}',
            icon: Icons.monetization_on,
            color: AppColors.success,
            trend: '+15.2%',
            isPositiveTrend: true,
          ),
          MetricCard(
            label: 'Work Orders',
            value: _metrics!.totalWorkOrders.toString(),
            icon: Icons.assignment,
            color: AppColors.secondary,
          ),
          MetricCard(
            label: 'Low Stock Parts',
            value: _metrics!.lowStockParts.toString(),
            icon: Icons.inventory,
            color: _metrics!.lowStockParts > 0 ? AppColors.error : AppColors.success,
          ),
        ];
      
      case UserRole.kasir:
        return [
          ...baseMetrics,
          MetricCard(
            label: 'Today\'s Revenue',
            value: 'Rp ${_formatCurrency(_metrics!.totalRevenue ~/ 30)}', // Demo daily value
            icon: Icons.today,
            color: AppColors.success,
          ),
          MetricCard(
            label: 'Customers',
            value: _metrics!.totalCustomers.toString(),
            icon: Icons.people,
            color: AppColors.primary,
          ),
          MetricCard(
            label: 'Purchases',
            value: _metrics!.totalPurchases.toString(),
            icon: Icons.shopping_cart,
            color: AppColors.secondary,
          ),
        ];
      
      case UserRole.mekanik:
        return [
          MetricCard(
            label: 'Pending Jobs',
            value: _metrics!.pendingWorkOrders.toString(),
            icon: Icons.pending_actions,
            color: AppColors.warning,
          ),
          MetricCard(
            label: 'Completed Jobs',
            value: _metrics!.completedWorkOrders.toString(),
            icon: Icons.check_circle,
            color: AppColors.success,
          ),
          MetricCard(
            label: 'In Progress',
            value: (_metrics!.totalWorkOrders - _metrics!.pendingWorkOrders - _metrics!.completedWorkOrders).toString(),
            icon: Icons.build,
            color: AppColors.primary,
          ),
          MetricCard(
            label: 'Low Stock Parts',
            value: _metrics!.lowStockParts.toString(),
            icon: Icons.inventory,
            color: _metrics!.lowStockParts > 0 ? AppColors.error : AppColors.success,
          ),
        ];
    }
  }

  List<Widget> _getActionCards() {
    switch (widget.userRole) {
      case UserRole.admin:
        return [
          GridCard(
            title: 'Add Vehicle',
            subtitle: 'Register new vehicle',
            icon: Icons.add_box,
            iconColor: AppColors.primary,
            onTap: () => _navigateToAddVehicle(),
          ),
          GridCard(
            title: 'Create User',
            subtitle: 'Add new system user',
            icon: Icons.person_add,
            iconColor: AppColors.success,
            onTap: () => _navigateToAddUser(),
          ),
          GridCard(
            title: 'Work Orders',
            subtitle: 'Manage repair jobs',
            icon: Icons.build,
            iconColor: AppColors.warning,
            onTap: () => _navigateToWorkOrders(),
          ),
          GridCard(
            title: 'Reports',
            subtitle: 'View analytics',
            icon: Icons.analytics,
            iconColor: AppColors.secondary,
            onTap: () => _navigateToReports(),
          ),
        ];
      
      case UserRole.kasir:
        return [
          GridCard(
            title: 'New Sale',
            subtitle: 'Create sales invoice',
            icon: Icons.point_of_sale,
            iconColor: AppColors.primary,
            onTap: () => _navigateToNewSale(),
          ),
          GridCard(
            title: 'Add Customer',
            subtitle: 'Register new customer',
            icon: Icons.person_add,
            iconColor: AppColors.success,
            onTap: () => _navigateToAddCustomer(),
          ),
          GridCard(
            title: 'Purchase Vehicle',
            subtitle: 'Buy from customer',
            icon: Icons.shopping_cart,
            iconColor: AppColors.warning,
            onTap: () => _navigateToNewPurchase(),
          ),
          GridCard(
            title: 'Sales Reports',
            subtitle: 'View sales data',
            icon: Icons.receipt_long,
            iconColor: AppColors.secondary,
            onTap: () => _navigateToSalesReports(),
          ),
        ];
      
      case UserRole.mekanik:
        return [
          GridCard(
            title: 'My Work Orders',
            subtitle: 'View assigned jobs',
            icon: Icons.assignment,
            iconColor: AppColors.primary,
            onTap: () => _navigateToMyWorkOrders(),
          ),
          GridCard(
            title: 'Use Parts',
            subtitle: 'Record parts usage',
            icon: Icons.inventory,
            iconColor: AppColors.success,
            onTap: () => _navigateToUseParts(),
          ),
          GridCard(
            title: 'Update Progress',
            subtitle: 'Track job progress',
            icon: Icons.update,
            iconColor: AppColors.warning,
            onTap: () => _navigateToUpdateProgress(),
          ),
          GridCard(
            title: 'Parts Inventory',
            subtitle: 'Check parts stock',
            icon: Icons.storage,
            iconColor: AppColors.secondary,
            onTap: () => _navigateToPartsInventory(),
          ),
        ];
    }
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');
    final day = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'][now.weekday % 7];
    final month = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'][now.month - 1];
    
    return '$day, ${now.day} $month $hour:$minute';
  }

  String _formatCurrency(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  void _loadDashboardData() async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    
    // Demo data
    setState(() {
      _metrics = DashboardMetrics(
        totalVehicles: 156,
        availableVehicles: 89,
        vehiclesInRepair: 32,
        soldVehicles: 35,
        totalCustomers: 245,
        totalSales: 180,
        totalPurchases: 95,
        totalWorkOrders: 67,
        pendingWorkOrders: 12,
        completedWorkOrders: 45,
        lowStockParts: 8,
        totalRevenue: 2500000000,
        totalProfit: 850000000,
      );
      _isLoading = false;
    });
  }

  // Navigation methods (placeholders)
  void _navigateToAddVehicle() => _showComingSoon('Add Vehicle');
  void _navigateToAddUser() => _showComingSoon('Add User');
  void _navigateToWorkOrders() => _showComingSoon('Work Orders');
  void _navigateToReports() => _showComingSoon('Reports');
  void _navigateToNewSale() => _showComingSoon('New Sale');
  void _navigateToAddCustomer() => _showComingSoon('Add Customer');
  void _navigateToNewPurchase() => _showComingSoon('New Purchase');
  void _navigateToSalesReports() => _showComingSoon('Sales Reports');
  void _navigateToMyWorkOrders() => _showComingSoon('My Work Orders');
  void _navigateToUseParts() => _showComingSoon('Use Parts');
  void _navigateToUpdateProgress() => _showComingSoon('Update Progress');
  void _navigateToPartsInventory() => _showComingSoon('Parts Inventory');

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature feature coming soon!'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}