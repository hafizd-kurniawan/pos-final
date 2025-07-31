import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_theme.dart';
import '../../shared/providers/sales_provider.dart';
import '../../shared/models/sales_model.dart';
import 'create_sales_screen.dart';
import 'sales_detail_screen.dart';

class SalesManagementWidget extends StatefulWidget {
  const SalesManagementWidget({super.key});

  @override
  State<SalesManagementWidget> createState() => _SalesManagementWidgetState();
}

class _SalesManagementWidgetState extends State<SalesManagementWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SalesProvider>().loadSalesInvoices(refresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: AppSpacing.lg),
          _buildSalesStatistics(),
          const SizedBox(height: AppSpacing.lg),
          Expanded(child: _buildSalesList()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sales Management',
                style: AppTextStyles.headlineMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Manage sales transactions and invoices',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CreateSalesScreen(),
              ),
            ).then((result) {
              if (result == true) {
                context.read<SalesProvider>().loadSalesInvoices(refresh: true);
              }
            });
          },
          icon: const Icon(Icons.add, size: 20),
          label: const Text('New Sale'),
        ),
      ],
    );
  }

  Widget _buildSalesStatistics() {
    return Consumer<SalesProvider>(
      builder: (context, salesProvider, child) {
        final stats = salesProvider.getSalesStatistics();
        
        return Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Total Revenue',
                'Rp ${_formatCurrency(stats['total_revenue'])}',
                Icons.attach_money,
                AppColors.primary,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _buildStatCard(
                'Total Sales',
                '${stats['total_invoices']}',
                Icons.receipt_long,
                AppColors.secondary,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _buildStatCard(
                'Average Sale',
                'Rp ${_formatCurrency(stats['average_sale'])}',
                Icons.trending_up,
                AppColors.success,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _buildStatCard(
                'Cash Sales',
                '${stats['cash_sales']}',
                Icons.money,
                AppColors.warning,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppBorderRadius.md),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: AppSpacing.sm),
              Flexible(
                child: Text(
                  title,
                  style: AppTextStyles.labelMedium.copyWith(color: color),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: AppTextStyles.titleMedium.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSalesList() {
    return Consumer<SalesProvider>(
      builder: (context, salesProvider, child) {
        if (salesProvider.isLoading && salesProvider.salesInvoices.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (salesProvider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: AppColors.error,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Error: ${salesProvider.error}',
                  style: AppTextStyles.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.md),
                ElevatedButton(
                  onPressed: () {
                    salesProvider.loadSalesInvoices(refresh: true);
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (salesProvider.salesInvoices.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.receipt_long,
                  size: 64,
                  color: AppColors.textTertiary,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'No sales found',
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Create your first sale to get started',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CreateSalesScreen(),
                      ),
                    ).then((result) {
                      if (result == true) {
                        context.read<SalesProvider>().loadSalesInvoices(refresh: true);
                      }
                    });
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Create Sale'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => salesProvider.loadSalesInvoices(refresh: true),
          child: ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.sm),
            itemCount: salesProvider.salesInvoices.length,
            itemBuilder: (context, index) {
              final invoice = salesProvider.salesInvoices[index];
              return _buildSalesCard(invoice);
            },
          ),
        );
      },
    );
  }

  Widget _buildSalesCard(SalesInvoice invoice) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SalesDetailScreen(invoiceId: invoice.id),
            ),
          );
        },
        borderRadius: BorderRadius.circular(AppBorderRadius.md),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          invoice.invoiceNumber,
                          style: AppTextStyles.titleSmall.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Customer: ${invoice.customer?.name ?? 'Unknown'}',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Rp ${_formatCurrency(invoice.sellingPrice)}',
                        style: AppTextStyles.titleSmall.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _getPaymentMethodColor(invoice.paymentMethod).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                          border: Border.all(
                            color: _getPaymentMethodColor(invoice.paymentMethod).withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          invoice.paymentMethod.toUpperCase(),
                          style: AppTextStyles.labelSmall.copyWith(
                            color: _getPaymentMethodColor(invoice.paymentMethod),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Icon(
                    Icons.directions_car,
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      '${invoice.vehicle?.brand ?? ''} ${invoice.vehicle?.model ?? ''} (${invoice.vehicle?.year ?? ''})',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.access_time,
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    _formatDate(invoice.createdAt),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getPaymentMethodColor(String paymentMethod) {
    switch (paymentMethod.toLowerCase()) {
      case 'cash':
        return AppColors.success;
      case 'transfer':
        return AppColors.primary;
      default:
        return AppColors.textSecondary;
    }
  }

  String _formatCurrency(double amount) {
    return amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}