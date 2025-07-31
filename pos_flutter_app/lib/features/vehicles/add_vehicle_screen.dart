import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../../core/constants/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../shared/providers/vehicle_provider.dart';
import '../../shared/models/vehicle_model.dart';

class AddVehicleScreen extends StatefulWidget {
  const AddVehicleScreen({super.key});

  @override
  State<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _chassisController = TextEditingController();
  final _engineController = TextEditingController();
  final _plateController = TextEditingController();
  final _colorController = TextEditingController();
  final _purchasePriceController = TextEditingController();
  final _conditionNotesController = TextEditingController();

  String _fuelType = 'gasoline';
  String _transmission = 'manual';
  int _categoryId = 1; // Default category
  List<File> _selectedPhotos = [];
  bool _isLoading = false;

  final ImagePicker _imagePicker = ImagePicker();

  @override
  void dispose() {
    _brandController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _chassisController.dispose();
    _engineController.dispose();
    _plateController.dispose();
    _colorController.dispose();
    _purchasePriceController.dispose();
    _conditionNotesController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await _imagePicker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (images.isNotEmpty) {
        // Limit to 8 photos (matching API photo types)
        final limitedImages = images.take(8).toList();
        setState(() {
          _selectedPhotos = limitedImages.map((xfile) => File(xfile.path)).toList();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking images: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    // Validate required photos
    if (_selectedPhotos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('At least one vehicle photo is required'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Create vehicle request
      final request = CreateVehicleRequest(
        categoryId: _categoryId,
        brand: _brandController.text.trim(),
        model: _modelController.text.trim(),
        year: int.parse(_yearController.text.trim()),
        chassisNumber: _chassisController.text.trim().isEmpty ? null : _chassisController.text.trim(),
        engineNumber: _engineController.text.trim().isEmpty ? null : _engineController.text.trim(),
        plateNumber: _plateController.text.trim().isEmpty ? null : _plateController.text.trim(),
        color: _colorController.text.trim().isEmpty ? null : _colorController.text.trim(),
        fuelType: _fuelType,
        transmission: _transmission,
        purchasePrice: _purchasePriceController.text.trim().isEmpty 
            ? null 
            : double.parse(_purchasePriceController.text.trim().replaceAll(',', '')),
        conditionNotes: _conditionNotesController.text.trim().isEmpty ? null : _conditionNotesController.text.trim(),
      );

      // Create vehicle
      final vehicleProvider = context.read<VehicleProvider>();
      final success = await vehicleProvider.createVehicle(request);

      if (success && vehicleProvider.vehicles.isNotEmpty) {
        // Get the newly created vehicle (should be first in list)
        final newVehicle = vehicleProvider.vehicles.first;
        
        // TODO: Upload photos for the new vehicle
        // This would require implementing the file upload functionality
        // For now, we'll show success message
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Vehicle created successfully!'),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.of(context).pop(true); // Return true to indicate success
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(vehicleProvider.error ?? 'Failed to create vehicle'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _removePhoto(int index) {
    setState(() {
      _selectedPhotos.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Vehicle'),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            TextButton(
              onPressed: _submitForm,
              child: const Text('Save'),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Vehicle Photos Section
              _buildPhotosSection(),
              const SizedBox(height: AppSpacing.xl),

              // Basic Information
              Text(
                'Basic Information',
                style: AppTextStyles.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.md),
              _buildBasicInfoSection(),
              const SizedBox(height: AppSpacing.xl),

              // Technical Details
              Text(
                'Technical Details',
                style: AppTextStyles.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.md),
              _buildTechnicalSection(),
              const SizedBox(height: AppSpacing.xl),

              // Additional Information
              Text(
                'Additional Information',
                style: AppTextStyles.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.md),
              _buildAdditionalInfoSection(),
              const SizedBox(height: AppSpacing.xl),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  child: _isLoading
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                              ),
                            ),
                            SizedBox(width: AppSpacing.sm),
                            Text('Creating Vehicle...'),
                          ],
                        )
                      : const Text('Create Vehicle'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotosSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Vehicle Photos *',
              style: AppTextStyles.headlineSmall,
            ),
            ElevatedButton.icon(
              onPressed: _pickImages,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Add Photos'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Add multiple photos of the vehicle. At least one photo is required.',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // Photo Grid
        if (_selectedPhotos.isNotEmpty)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: AppSpacing.sm,
              mainAxisSpacing: AppSpacing.sm,
              childAspectRatio: 1,
            ),
            itemCount: _selectedPhotos.length,
            itemBuilder: (context, index) {
              return Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppBorderRadius.md),
                      image: DecorationImage(
                        image: FileImage(_selectedPhotos[index]),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () => _removePhoto(index),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: AppColors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          )
        else
          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border, style: BorderStyle.solid),
              borderRadius: BorderRadius.circular(AppBorderRadius.md),
              color: AppColors.surfaceVariant,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add_photo_alternate_outlined,
                  size: 48,
                  color: AppColors.textTertiary,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Tap "Add Photos" to select vehicle images',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildBasicInfoSection() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _brandController,
                decoration: const InputDecoration(
                  labelText: 'Brand *',
                  hintText: 'e.g., Toyota, Honda',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Brand is required';
                  }
                  return null;
                },
                textCapitalization: TextCapitalization.words,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: TextFormField(
                controller: _modelController,
                decoration: const InputDecoration(
                  labelText: 'Model *',
                  hintText: 'e.g., Avanza, Civic',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Model is required';
                  }
                  return null;
                },
                textCapitalization: TextCapitalization.words,
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
                decoration: const InputDecoration(
                  labelText: 'Year *',
                  hintText: 'e.g., 2020',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                ],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Year is required';
                  }
                  final year = int.tryParse(value.trim());
                  if (year == null || year < 1980 || year > DateTime.now().year + 1) {
                    return 'Enter a valid year';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: TextFormField(
                controller: _colorController,
                decoration: const InputDecoration(
                  labelText: 'Color',
                  hintText: 'e.g., White, Black',
                ),
                textCapitalization: TextCapitalization.words,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),

        TextFormField(
          controller: _purchasePriceController,
          decoration: const InputDecoration(
            labelText: 'Purchase Price',
            hintText: 'Enter amount in IDR',
            prefixText: 'Rp ',
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
        ),
      ],
    );
  }

  Widget _buildTechnicalSection() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _fuelType,
                decoration: const InputDecoration(
                  labelText: 'Fuel Type',
                ),
                items: const [
                  DropdownMenuItem(value: 'gasoline', child: Text('Gasoline')),
                  DropdownMenuItem(value: 'diesel', child: Text('Diesel')),
                  DropdownMenuItem(value: 'electric', child: Text('Electric')),
                  DropdownMenuItem(value: 'hybrid', child: Text('Hybrid')),
                ],
                onChanged: (value) {
                  setState(() {
                    _fuelType = value!;
                  });
                },
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _transmission,
                decoration: const InputDecoration(
                  labelText: 'Transmission',
                ),
                items: const [
                  DropdownMenuItem(value: 'manual', child: Text('Manual')),
                  DropdownMenuItem(value: 'automatic', child: Text('Automatic')),
                  DropdownMenuItem(value: 'cvt', child: Text('CVT')),
                ],
                onChanged: (value) {
                  setState(() {
                    _transmission = value!;
                  });
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),

        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _chassisController,
                decoration: const InputDecoration(
                  labelText: 'Chassis Number',
                  hintText: 'Vehicle chassis number',
                ),
                textCapitalization: TextCapitalization.characters,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: TextFormField(
                controller: _engineController,
                decoration: const InputDecoration(
                  labelText: 'Engine Number',
                  hintText: 'Vehicle engine number',
                ),
                textCapitalization: TextCapitalization.characters,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),

        TextFormField(
          controller: _plateController,
          decoration: const InputDecoration(
            labelText: 'License Plate',
            hintText: 'e.g., B 1234 ABC',
          ),
          textCapitalization: TextCapitalization.characters,
        ),
      ],
    );
  }

  Widget _buildAdditionalInfoSection() {
    return Column(
      children: [
        TextFormField(
          controller: _conditionNotesController,
          decoration: const InputDecoration(
            labelText: 'Condition Notes',
            hintText: 'Describe the vehicle condition, any damage, etc.',
          ),
          maxLines: 3,
          textCapitalization: TextCapitalization.sentences,
        ),
      ],
    );
  }
}