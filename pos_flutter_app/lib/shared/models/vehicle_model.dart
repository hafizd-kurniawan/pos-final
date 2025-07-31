class Vehicle {
  final int id;
  final String vehicleCode;
  final int categoryId;
  final String brand;
  final String model;
  final int year;
  final String? chassisNumber;
  final String? engineNumber;
  final String? plateNumber;
  final String? color;
  final String? fuelType;
  final String? transmission;
  final double? purchasePrice;
  final double repairCost;
  final double? hpp;
  final double? sellingPrice;
  final String status;
  final String? conditionNotes;
  final String? primaryPhoto;
  final DateTime? purchasedDate;
  final DateTime? soldDate;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final VehicleCategory? category;
  final List<VehiclePhoto>? photos;
  
  Vehicle({
    required this.id,
    required this.vehicleCode,
    required this.categoryId,
    required this.brand,
    required this.model,
    required this.year,
    this.chassisNumber,
    this.engineNumber,
    this.plateNumber,
    this.color,
    this.fuelType,
    this.transmission,
    this.purchasePrice,
    required this.repairCost,
    this.hpp,
    this.sellingPrice,
    required this.status,
    this.conditionNotes,
    this.primaryPhoto,
    this.purchasedDate,
    this.soldDate,
    required this.createdAt,
    this.updatedAt,
    this.category,
    this.photos,
  });
  
  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'] as int,
      vehicleCode: json['vehicle_code'] as String,
      categoryId: json['category_id'] as int,
      brand: json['brand'] as String,
      model: json['model'] as String,
      year: json['year'] as int,
      chassisNumber: json['chassis_number'] as String?,
      engineNumber: json['engine_number'] as String?,
      plateNumber: json['plate_number'] as String?,
      color: json['color'] as String?,
      fuelType: json['fuel_type'] as String?,
      transmission: json['transmission'] as String?,
      purchasePrice: (json['purchase_price'] as num?)?.toDouble(),
      repairCost: (json['repair_cost'] as num?)?.toDouble() ?? 0.0,
      hpp: (json['hpp'] as num?)?.toDouble(),
      sellingPrice: (json['selling_price'] as num?)?.toDouble(),
      status: json['status'] as String,
      conditionNotes: json['condition_notes'] as String?,
      primaryPhoto: json['primary_photo'] as String?,
      purchasedDate: json['purchased_date'] != null 
          ? DateTime.parse(json['purchased_date'] as String)
          : null,
      soldDate: json['sold_date'] != null 
          ? DateTime.parse(json['sold_date'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      category: json['category'] != null 
          ? VehicleCategory.fromJson(json['category'] as Map<String, dynamic>)
          : null,
      photos: json['photos'] != null
          ? (json['photos'] as List)
              .map((p) => VehiclePhoto.fromJson(p as Map<String, dynamic>))
              .toList()
          : null,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vehicle_code': vehicleCode,
      'category_id': categoryId,
      'brand': brand,
      'model': model,
      'year': year,
      'chassis_number': chassisNumber,
      'engine_number': engineNumber,
      'plate_number': plateNumber,
      'color': color,
      'fuel_type': fuelType,
      'transmission': transmission,
      'purchase_price': purchasePrice,
      'repair_cost': repairCost,
      'hpp': hpp,
      'selling_price': sellingPrice,
      'status': status,
      'condition_notes': conditionNotes,
      'primary_photo': primaryPhoto,
      'purchased_date': purchasedDate?.toIso8601String(),
      'sold_date': soldDate?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'category': category?.toJson(),
      'photos': photos?.map((p) => p.toJson()).toList(),
    };
  }
  
  // Status helpers
  bool get isAvailable => status == 'available';
  bool get isInRepair => status == 'in_repair';
  bool get isSold => status == 'sold';
  bool get isReserved => status == 'reserved';
  
  // Display helpers
  String get displayName => '$year $brand $model';
  String get thumbnail => primaryPhoto ?? photos?.firstOrNull?.photoPath ?? '';
  bool get hasPhoto => thumbnail.isNotEmpty;
  
  Vehicle copyWith({
    int? id,
    String? vehicleCode,
    int? categoryId,
    String? brand,
    String? model,
    int? year,
    String? chassisNumber,
    String? engineNumber,
    String? plateNumber,
    String? color,
    String? fuelType,
    String? transmission,
    double? purchasePrice,
    double? repairCost,
    double? hpp,
    double? sellingPrice,
    String? status,
    String? conditionNotes,
    String? primaryPhoto,
    DateTime? purchasedDate,
    DateTime? soldDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    VehicleCategory? category,
    List<VehiclePhoto>? photos,
  }) {
    return Vehicle(
      id: id ?? this.id,
      vehicleCode: vehicleCode ?? this.vehicleCode,
      categoryId: categoryId ?? this.categoryId,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      year: year ?? this.year,
      chassisNumber: chassisNumber ?? this.chassisNumber,
      engineNumber: engineNumber ?? this.engineNumber,
      plateNumber: plateNumber ?? this.plateNumber,
      color: color ?? this.color,
      fuelType: fuelType ?? this.fuelType,
      transmission: transmission ?? this.transmission,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      repairCost: repairCost ?? this.repairCost,
      hpp: hpp ?? this.hpp,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      status: status ?? this.status,
      conditionNotes: conditionNotes ?? this.conditionNotes,
      primaryPhoto: primaryPhoto ?? this.primaryPhoto,
      purchasedDate: purchasedDate ?? this.purchasedDate,
      soldDate: soldDate ?? this.soldDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      category: category ?? this.category,
      photos: photos ?? this.photos,
    );
  }
}

class VehicleCategory {
  final int id;
  final String name;
  final String? description;
  final DateTime createdAt;
  final DateTime? updatedAt;
  
  VehicleCategory({
    required this.id,
    required this.name,
    this.description,
    required this.createdAt,
    this.updatedAt,
  });
  
  factory VehicleCategory.fromJson(Map<String, dynamic> json) {
    return VehicleCategory(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

class VehiclePhoto {
  final int id;
  final int vehicleId;
  final String photoType;
  final String photoPath;
  final bool isPrimary;
  final String? description;
  final DateTime createdAt;
  
  VehiclePhoto({
    required this.id,
    required this.vehicleId,
    required this.photoType,
    required this.photoPath,
    required this.isPrimary,
    this.description,
    required this.createdAt,
  });
  
  factory VehiclePhoto.fromJson(Map<String, dynamic> json) {
    return VehiclePhoto(
      id: json['id'] as int,
      vehicleId: json['vehicle_id'] as int,
      photoType: json['photo_type'] as String,
      photoPath: json['photo_path'] as String,
      isPrimary: json['is_primary'] as bool? ?? false,
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vehicle_id': vehicleId,
      'photo_type': photoType,
      'photo_path': photoPath,
      'is_primary': isPrimary,
      'description': description,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

// Vehicle creation/update DTOs
class CreateVehicleRequest {
  final int categoryId;
  final String brand;
  final String model;
  final int year;
  final String? chassisNumber;
  final String? engineNumber;
  final String? plateNumber;
  final String? color;
  final String? fuelType;
  final String? transmission;
  final double? purchasePrice;
  final String? conditionNotes;
  
  CreateVehicleRequest({
    required this.categoryId,
    required this.brand,
    required this.model,
    required this.year,
    this.chassisNumber,
    this.engineNumber,
    this.plateNumber,
    this.color,
    this.fuelType,
    this.transmission,
    this.purchasePrice,
    this.conditionNotes,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'category_id': categoryId,
      'brand': brand,
      'model': model,
      'year': year,
      'chassis_number': chassisNumber,
      'engine_number': engineNumber,
      'plate_number': plateNumber,
      'color': color,
      'fuel_type': fuelType,
      'transmission': transmission,
      'purchase_price': purchasePrice,
      'condition_notes': conditionNotes,
    };
  }
}

extension ListExtension<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}