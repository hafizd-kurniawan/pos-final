import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_theme.dart';
import '../../core/widgets/dashboard_layout.dart';
import '../../shared/providers/sales_provider.dart';
import '../../shared/models/sales_model.dart';

class SalesDetailScreen extends StatefulWidget {
  final int invoiceId;

  const SalesDetailScreen({
    super.key,
    required this.invoiceId,
  });

  @override
  State<SalesDetailScreen> createState() => _SalesDetailScreenState();
}

class _SalesDetailScreenState extends State<SalesDetailScreen> {
  bool _isLoading = true;
  SalesInvoice? _invoice;

  @override
  void initState() {
    super.initState();
    _loadInvoice();
  }

  Future<void> _loadInvoice() async {
    setState(() {
      _isLoading = true;
    });

    final invoice = await context.read<SalesProvider>().getSalesInvoice(widget.invoiceId);
    
    setState(() {
      _invoice = invoice;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DashboardLayout(
      title: 'Sales Invoice',
      actions: [
        if (_invoice != null) ...[
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadInvoice,
          ),
          const SizedBox(width: AppSpacing.md),
          ElevatedButton.icon(
            onPressed: _generatePDF,
            icon: const Icon(Icons.picture_as_pdf, size: 20),
            label: const Text('PDF'),
          ),
        ],
      ],
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _invoice == null
              ? _buildErrorView()
              : _buildInvoiceDetail(),
    );
  }

  Widget _buildErrorView() {
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
            'Invoice not found',
            style: AppTextStyles.headlineSmall.copyWith(
              color: AppColors.error,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Go Back'),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceDetail() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInvoiceHeader(),
          const SizedBox(height: AppSpacing.lg),
          _buildCustomerInfo(),
          const SizedBox(height: AppSpacing.lg),
          _buildVehicleInfo(),
          const SizedBox(height: AppSpacing.lg),
          _buildPaymentInfo(),
          if (_invoice!.notes != null) ...[
            const SizedBox(height: AppSpacing.lg),
            _buildNotesSection(),
          ],
          const SizedBox(height: AppSpacing.lg),
          _buildTimelineInfo(),
        ],
      ),
    );
  }

  Widget _buildInvoiceHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.receipt_long, color: AppColors.primary, size: 28),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _invoice!.invoiceNumber,
                        style: AppTextStyles.headlineMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      Text(
                        'Sales Invoice',
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppBorderRadius.md),
                    border: Border.all(color: AppColors.success.withOpacity(0.3)),
                  ),
                  child: Text(
                    'PAID',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppBorderRadius.md),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Text(
                    'Total Amount',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Rp ${_formatCurrency(_invoice!.sellingPrice)}',
                    style: AppTextStyles.headlineLarge.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerInfo() {
    final customer = _invoice!.customer;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.person, color: AppColors.primary),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Customer Information',
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            if (customer != null) ...[
              _buildInfoRow('Name', customer.name, Icons.person),
              _buildInfoRow('Phone', customer.phone, Icons.phone),
              _buildInfoRow('Email', customer.email, Icons.email),
              if (customer.address.isNotEmpty)
                _buildInfoRow('Address', customer.address, Icons.location_on),
            ] else ...[
              Text(
                'Customer information not available',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleInfo() {
    final vehicle = _invoice!.vehicle;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.directions_car, color: AppColors.primary),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Vehicle Information',
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            if (vehicle != null) ...[
              _buildInfoRow('Brand & Model', '${vehicle.brand} ${vehicle.model}', Icons.directions_car),
              _buildInfoRow('Year', vehicle.year.toString(), Icons.calendar_today),
              _buildInfoRow('License Plate', vehicle.licensePlate, Icons.confirmation_number),
              _buildInfoRow('Engine', vehicle.engine, Icons.settings),
              _buildInfoRow('Color', vehicle.color, Icons.palette),
              if (vehicle.description.isNotEmpty)
                _buildInfoRow('Description', vehicle.description, Icons.description),
            ] else ...[
              Text(
                'Vehicle information not available',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.payment, color: AppColors.primary),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Payment Information',
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _buildInfoRow(
              'Payment Method',
              _invoice!.paymentMethod.toUpperCase(),
              Icons.payment,
            ),
            _buildInfoRow(
              'Amount',
              'Rp ${_formatCurrency(_invoice!.sellingPrice)}',
              Icons.attach_money,
            ),
            if (_invoice!.transferProofPath != null) ...[
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Icon(Icons.receipt, size: 20, color: AppColors.textSecondary),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Transfer Proof:',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  TextButton.icon(
                    onPressed: () {
                      // TODO: Show transfer proof
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Transfer proof view coming soon'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.visibility, size: 16),
                    label: const Text('View'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNotesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.note, color: AppColors.primary),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Notes',
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(AppBorderRadius.md),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(
                _invoice!.notes!,
                style: AppTextStyles.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.timeline, color: AppColors.primary),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Timeline',
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _buildInfoRow(
              'Created',
              _formatDateTime(_invoice!.createdAt),
              Icons.access_time,
            ),
            if (_invoice!.updatedAt != null)
              _buildInfoRow(
                'Last Updated',
                _formatDateTime(_invoice!.updatedAt!),
                Icons.update,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            flex: 2,
            child: Text(
              '$label:',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: AppTextStyles.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _generatePDF() async {
    final salesProvider = context.read<SalesProvider>();
    
    try {
      final pdfUrl = await salesProvider.generateInvoicePDF(_invoice!.id);
      
      if (pdfUrl != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF generated: $pdfUrl'),
            action: SnackBarAction(
              label: 'View',
              onPressed: () {
                // TODO: Open PDF viewer
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('PDF viewer coming soon'),
                  ),
                );
              },
            ),
          ),
        );
      } else if (mounted) {
        final error = salesProvider.error ?? 'Unknown error';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate PDF: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatCurrency(double amount) {
    return amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    
    return '${dateTime.day} ${months[dateTime.month - 1]} ${dateTime.year} at ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}