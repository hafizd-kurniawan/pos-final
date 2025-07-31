import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../../theme.dart';
import '../../../shared/models/app_models.dart';
import '../../../core/constants/api_constants.dart';
import '../services/vehicle_service.dart';

class VehiclesScreen extends StatefulWidget {
  const VehiclesScreen({super.key});

  @override
  State<VehiclesScreen> createState() => _VehiclesScreenState();
}

class _VehiclesScreenState extends State<VehiclesScreen> {
  final VehicleService _vehicleService = VehicleService();
  final TextEditingController _searchController = TextEditingController();
  
  List<Vehicle> _vehicles = [];
  bool _isLoading = true;
  String? _errorMessage;
  VehicleStatus? _filterStatus;
  String? _filterBrand;
  
  @override
  void initState() {
    super.initState();
    _loadVehicles();
  }

  Future<void> _loadVehicles() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _vehicleService.getVehicles(
        search: _searchController.text.trim().isEmpty ? null : _searchController.text.trim(),
        status: _filterStatus,
        brand: _filterBrand,
      );

      if (response.isSuccess) {
        setState(() {
          _vehicles = response.data ?? [];
        });
      } else {
        setState(() {
          _errorMessage = response.error ?? 'Failed to load vehicles';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Network error: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Add Button
          Row(
            children: [
              Expanded(
                child: Text(
                  'Vehicle Inventory',
                  style: AppTextStyles.heading,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddVehicleDialog(),
                icon: const Icon(Icons.add),
                label: const Text('Add Vehicle'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          
          // Search and Filter Row
          Row(
            children: [
              // Search Field
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    labelText: 'Search vehicles...',
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Brand, model, or vehicle code',
                  ),
                  onChanged: (_) => _loadVehicles(),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              
              // Status Filter
              Expanded(
                child: DropdownButtonFormField<VehicleStatus?>(
                  value: _filterStatus,
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    prefixIcon: Icon(Icons.filter_list),
                  ),
                  items: [
                    const DropdownMenuItem<VehicleStatus?>(
                      value: null,
                      child: Text('All Status'),
                    ),
                    ...VehicleStatus.values.map((status) => DropdownMenuItem(
                      value: status,
                      child: Text(status.displayName),
                    )),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _filterStatus = value;
                    });
                    _loadVehicles();
                  },
                ),
              ),
              
              const SizedBox(width: AppSpacing.md),
              
              // Refresh Button
              IconButton(
                onPressed: _loadVehicles,
                icon: const Icon(Icons.refresh),
                tooltip: 'Refresh',
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          
          // Content Area
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
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
              onPressed: _loadVehicles,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_vehicles.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.directions_car_outlined,
              size: 64,
              color: AppColors.secondary,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No vehicles found',
              style: AppTextStyles.title,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Add your first vehicle to get started',
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton.icon(
              onPressed: () => _showAddVehicleDialog(),
              icon: const Icon(Icons.add),
              label: const Text('Add Vehicle'),
            ),
          ],
        ),
      );
    }

    // Vehicles Grid
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final isTablet = screenWidth > 768;
        final columns = isTablet ? 4 : 2;
        
        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: AppSpacing.md,
            mainAxisSpacing: AppSpacing.md,
            childAspectRatio: 0.75,
          ),
          itemCount: _vehicles.length,
          itemBuilder: (context, index) => _buildVehicleCard(_vehicles[index]),
        );
      },
    );
  }

  Widget _buildVehicleCard(Vehicle vehicle) {
    Color statusColor;
    switch (vehicle.status) {
      case VehicleStatus.available:
        statusColor = AppColors.primary;
        break;
      case VehicleStatus.inRepair:
        statusColor = AppColors.secondary;
        break;
      case VehicleStatus.sold:
        statusColor = AppColors.primaryDark;
        break;
      case VehicleStatus.reserved:
        statusColor = Colors.orange;
        break;
    }

    return Card(
      child: InkWell(
        onTap: () => _showVehicleDetails(vehicle),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Vehicle Photo
              Expanded(
                flex: 3,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: vehicle.photoUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            vehicle.photoUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => _buildPhotoPlaceholder(),
                          ),
                        )
                      : _buildPhotoPlaceholder(),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              
              // Vehicle Info
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${vehicle.brand} ${vehicle.model}',
                      style: AppTextStyles.title.copyWith(fontSize: 16),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Year: ${vehicle.year}',
                      style: AppTextStyles.bodySmall,
                    ),
                    Text(
                      'Code: ${vehicle.vehicleCode}',
                      style: AppTextStyles.bodySmall,
                    ),
                    const Spacer(),
                    
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: AppSpacing.xs,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              vehicle.status.displayName,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: statusColor,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => _showVehicleOptions(vehicle),
                          icon: const Icon(Icons.more_vert, size: 16),
                          constraints: const BoxConstraints(),
                          padding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoPlaceholder() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.directions_car,
            size: 48,
            color: AppColors.secondary,
          ),
          SizedBox(height: AppSpacing.xs),
          Text(
            'No Photo',
            style: AppTextStyles.bodySmall,
          ),
        ],
      ),
    );
  }

  void _showAddVehicleDialog() {
    showDialog(
      context: context,
      builder: (context) => const AddVehicleDialog(),
    ).then((result) {
      if (result == true) {
        _loadVehicles();
      }
    });
  }

  void _showVehicleDetails(Vehicle vehicle) {
    showDialog(
      context: context,
      builder: (context) => VehicleDetailsDialog(vehicle: vehicle),
    );
  }

  void _showVehicleOptions(Vehicle vehicle) {
    showModalBottomSheet(
      context: context,
      builder: (context) => VehicleOptionsSheet(
        vehicle: vehicle,
        onUpdate: _loadVehicles,
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

// Add Vehicle Dialog
class AddVehicleDialog extends StatefulWidget {
  const AddVehicleDialog({super.key});

  @override
  State<AddVehicleDialog> createState() => _AddVehicleDialogState();
}

class _AddVehicleDialogState extends State<AddVehicleDialog> {
  final _formKey = GlobalKey<FormState>();
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _colorController = TextEditingController();
  final _engineController = TextEditingController();
  final _chassisController = TextEditingController();
  final _priceController = TextEditingController();
  
  final VehicleService _vehicleService = VehicleService();
  final ImagePicker _imagePicker = ImagePicker();
  
  bool _isLoading = false;
  File? _photoFile;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Vehicle'),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 500,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Photo Upload
                InkWell(
                  onTap: _pickPhoto,
                  child: Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: _photoFile != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              _photoFile!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_a_photo, size: 48, color: AppColors.secondary),
                              SizedBox(height: AppSpacing.sm),
                              Text('Tap to add photo (Required)', style: AppTextStyles.bodySmall),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                
                // Form fields
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _brandController,
                        decoration: const InputDecoration(labelText: 'Brand'),
                        validator: (value) => value?.isEmpty == true ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: TextFormField(
                        controller: _modelController,
                        decoration: const InputDecoration(labelText: 'Model'),
                        validator: (value) => value?.isEmpty == true ? 'Required' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _yearController,
                        decoration: const InputDecoration(labelText: 'Year'),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value?.isEmpty == true) return 'Required';
                          final year = int.tryParse(value!);
                          if (year == null || year < 1950 || year > DateTime.now().year + 1) {
                            return 'Invalid year';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: TextFormField(
                        controller: _colorController,
                        decoration: const InputDecoration(labelText: 'Color'),
                        validator: (value) => value?.isEmpty == true ? 'Required' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                
                TextFormField(
                  controller: _engineController,
                  decoration: const InputDecoration(labelText: 'Engine Number'),
                  validator: (value) => value?.isEmpty == true ? 'Required' : null,
                ),
                const SizedBox(height: AppSpacing.md),
                
                TextFormField(
                  controller: _chassisController,
                  decoration: const InputDecoration(labelText: 'Chassis Number'),
                  validator: (value) => value?.isEmpty == true ? 'Required' : null,
                ),
                const SizedBox(height: AppSpacing.md),
                
                TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(
                    labelText: 'Purchase Price',
                    prefixText: 'Rp ',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value?.isEmpty == true) return 'Required';
                    final price = double.tryParse(value!);
                    if (price == null || price <= 0) return 'Invalid price';
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submitForm,
          child: _isLoading
              ? const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Add Vehicle'),
        ),
      ],
    );
  }

  Future<void> _pickPhoto() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 80,
    );
    
    if (image != null) {
      setState(() {
        _photoFile = File(image.path);
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    if (_photoFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vehicle photo is required'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Create vehicle first
      final vehicleResponse = await _vehicleService.createVehicle(
        brand: _brandController.text.trim(),
        model: _modelController.text.trim(),
        year: int.parse(_yearController.text.trim()),
        color: _colorController.text.trim(),
        engineNumber: _engineController.text.trim(),
        chassisNumber: _chassisController.text.trim(),
        purchasePrice: double.parse(_priceController.text.trim()),
      );

      if (vehicleResponse.isSuccess && vehicleResponse.data != null) {
        // Upload photo
        final photoResponse = await _vehicleService.uploadVehiclePhoto(
          vehicleResponse.data!.id,
          _photoFile!,
        );

        if (mounted) {
          if (photoResponse.isSuccess) {
            Navigator.pop(context, true);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Vehicle added successfully'),
                backgroundColor: AppColors.primary,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Vehicle added but photo upload failed: ${photoResponse.error}'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(vehicleResponse.error ?? 'Failed to add vehicle'),
              backgroundColor: Colors.red,
            ),
          );
        }
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
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _brandController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _colorController.dispose();
    _engineController.dispose();
    _chassisController.dispose();
    _priceController.dispose();
    super.dispose();
  }
}

// Vehicle Details Dialog
class VehicleDetailsDialog extends StatelessWidget {
  final Vehicle vehicle;

  const VehicleDetailsDialog({
    super.key,
    required this.vehicle,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('${vehicle.brand} ${vehicle.model}'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Vehicle Photo
            if (vehicle.photoUrl != null)
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    vehicle.photoUrl!,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            
            const SizedBox(height: AppSpacing.lg),
            
            // Vehicle Details
            _buildDetailRow('Vehicle Code', vehicle.vehicleCode),
            _buildDetailRow('Brand', vehicle.brand),
            _buildDetailRow('Model', vehicle.model),
            _buildDetailRow('Year', vehicle.year.toString()),
            _buildDetailRow('Color', vehicle.color),
            _buildDetailRow('Engine Number', vehicle.engineNumber),
            _buildDetailRow('Chassis Number', vehicle.chassisNumber),
            _buildDetailRow('Purchase Price', 'Rp ${vehicle.purchasePrice.toStringAsFixed(0)}'),
            _buildDetailRow('HPP', 'Rp ${vehicle.hpp.toStringAsFixed(0)}'),
            _buildDetailRow('Status', vehicle.status.displayName),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.body,
            ),
          ),
        ],
      ),
    );
  }
}

// Vehicle Options Bottom Sheet
class VehicleOptionsSheet extends StatelessWidget {
  final Vehicle vehicle;
  final VoidCallback onUpdate;

  const VehicleOptionsSheet({
    super.key,
    required this.vehicle,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Edit Vehicle'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Show edit dialog
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_camera),
            title: const Text('Update Photo'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Show photo update dialog
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete),
            title: const Text('Delete Vehicle'),
            textColor: Colors.red,
            iconColor: Colors.red,
            onTap: () {
              Navigator.pop(context);
              // TODO: Show delete confirmation
            },
          ),
        ],
      ),
    );
  }
}