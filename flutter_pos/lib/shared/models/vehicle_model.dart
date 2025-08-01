class Vehicle {
  final String id;
  final String brand;
  final String model;
  final String year;
  final String licensePlate;
  final String categoryId;
  final String? categoryName;
  final double purchasePrice;
  final double? repairCost;
  final double? sellingPrice;
  final String status;
  final String? supplierId;
  final String? supplierName;
  final String? description;
  final List<VehiclePhoto> photos;
  final DateTime createdAt;
  final DateTime updatedAt;

  Vehicle({
    required this.id,
    required this.brand,
    required this.model,
    required this.year,
    required this.licensePlate,
    required this.categoryId,
    this.categoryName,
    required this.purchasePrice,
    this.repairCost,
    this.sellingPrice,
    required this.status,
    this.supplierId,
    this.supplierName,
    this.description,
    this.photos = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id']?.toString() ?? '',
      brand: json['brand']?.toString() ?? '',
      model: json['model']?.toString() ?? '',
      year: json['year']?.toString() ?? '',
      licensePlate: json['license_plate']?.toString() ?? '',
      categoryId: json['category_id']?.toString() ?? '',
      categoryName: json['category_name']?.toString(),
      purchasePrice: (json['purchase_price'] as num?)?.toDouble() ?? 0.0,
      repairCost: (json['repair_cost'] as num?)?.toDouble(),
      sellingPrice: (json['selling_price'] as num?)?.toDouble(),
      status: json['status']?.toString() ?? 'available',
      supplierId: json['supplier_id']?.toString(),
      supplierName: json['supplier_name']?.toString(),
      description: json['description']?.toString(),
      photos: (json['photos'] as List<dynamic>?)
              ?.map((p) => VehiclePhoto.fromJson(p as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'brand': brand,
      'model': model,
      'year': year,
      'license_plate': licensePlate,
      'category_id': categoryId,
      'category_name': categoryName,
      'purchase_price': purchasePrice,
      'repair_cost': repairCost,
      'selling_price': sellingPrice,
      'status': status,
      'supplier_id': supplierId,
      'supplier_name': supplierName,
      'description': description,
      'photos': photos.map((p) => p.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Helper methods
  String get displayName => '$brand $model ($year)';
  String get statusDisplay {
    switch (status) {
      case 'available':
        return 'Available';
      case 'in_repair':
        return 'In Repair';
      case 'sold':
        return 'Sold';
      case 'reserved':
        return 'Reserved';
      default:
        return status;
    }
  }

  String? get thumbnailUrl {
    if (photos.isNotEmpty) {
      return photos.first.url;
    }
    return null;
  }

  bool get hasPhotos => photos.isNotEmpty;
  bool get isAvailable => status == 'available';
  bool get isInRepair => status == 'in_repair';
  bool get isSold => status == 'sold';
  bool get isReserved => status == 'reserved';
}

class VehiclePhoto {
  final String id;
  final String vehicleId;
  final String url;
  final String? description;
  final int position;
  final DateTime createdAt;

  VehiclePhoto({
    required this.id,
    required this.vehicleId,
    required this.url,
    this.description,
    required this.position,
    required this.createdAt,
  });

  factory VehiclePhoto.fromJson(Map<String, dynamic> json) {
    return VehiclePhoto(
      id: json['id']?.toString() ?? '',
      vehicleId: json['vehicle_id']?.toString() ?? '',
      url: json['url']?.toString() ?? '',
      description: json['description']?.toString(),
      position: (json['position'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vehicle_id': vehicleId,
      'url': url,
      'description': description,
      'position': position,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class VehicleCategory {
  final String id;
  final String name;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;

  VehicleCategory({
    required this.id,
    required this.name,
    this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  factory VehicleCategory.fromJson(Map<String, dynamic> json) {
    return VehicleCategory(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}