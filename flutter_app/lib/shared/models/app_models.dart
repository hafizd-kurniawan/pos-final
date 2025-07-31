import '../core/constants/api_constants.dart';

class User {
  final int id;
  final String username;
  final String role;
  final String? fullName;
  final String? email;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.username,
    required this.role,
    this.fullName,
    this.email,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      role: json['role'],
      fullName: json['full_name'],
      email: json['email'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'role': role,
      'full_name': fullName,
      'email': email,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
  
  UserRole get userRole => UserRole.fromString(role);
}

class AuthResponse {
  final String token;
  final User user;

  AuthResponse({
    required this.token,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'],
      user: User.fromJson(json['user']),
    );
  }
}

class Vehicle {
  final int id;
  final String vehicleCode;
  final String brand;
  final String model;
  final int year;
  final String color;
  final String engineNumber;
  final String chassisNumber;
  final double purchasePrice;
  final double hpp;
  final VehicleStatus status;
  final int? customerId;
  final String? photoUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  Vehicle({
    required this.id,
    required this.vehicleCode,
    required this.brand,
    required this.model,
    required this.year,
    required this.color,
    required this.engineNumber,
    required this.chassisNumber,
    required this.purchasePrice,
    required this.hpp,
    required this.status,
    this.customerId,
    this.photoUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'],
      vehicleCode: json['vehicle_code'],
      brand: json['brand'],
      model: json['model'],
      year: json['year'],
      color: json['color'],
      engineNumber: json['engine_number'],
      chassisNumber: json['chassis_number'],
      purchasePrice: (json['purchase_price'] as num).toDouble(),
      hpp: (json['hpp'] as num).toDouble(),
      status: VehicleStatus.fromString(json['status']),
      customerId: json['customer_id'],
      photoUrl: json['photo_url'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vehicle_code': vehicleCode,
      'brand': brand,
      'model': model,
      'year': year,
      'color': color,
      'engine_number': engineNumber,
      'chassis_number': chassisNumber,
      'purchase_price': purchasePrice,
      'hpp': hpp,
      'status': status.value,
      'customer_id': customerId,
      'photo_url': photoUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class Customer {
  final int id;
  final String customerCode;
  final String name;
  final String? phone;
  final String? email;
  final String? address;
  final DateTime createdAt;
  final DateTime updatedAt;

  Customer({
    required this.id,
    required this.customerCode,
    required this.name,
    this.phone,
    this.email,
    this.address,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'],
      customerCode: json['customer_code'],
      name: json['name'],
      phone: json['phone'],
      email: json['email'],
      address: json['address'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_code': customerCode,
      'name': name,
      'phone': phone,
      'email': email,
      'address': address,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class SparePart {
  final int id;
  final String partCode;
  final String name;
  final String? description;
  final double price;
  final int stock;
  final int minimumStock;
  final DateTime createdAt;
  final DateTime updatedAt;

  SparePart({
    required this.id,
    required this.partCode,
    required this.name,
    this.description,
    required this.price,
    required this.stock,
    required this.minimumStock,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SparePart.fromJson(Map<String, dynamic> json) {
    return SparePart(
      id: json['id'],
      partCode: json['part_code'],
      name: json['name'],
      description: json['description'],
      price: (json['price'] as num).toDouble(),
      stock: json['stock'],
      minimumStock: json['minimum_stock'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'part_code': partCode,
      'name': name,
      'description': description,
      'price': price,
      'stock': stock,
      'minimum_stock': minimumStock,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class WorkOrder {
  final int id;
  final String workOrderNumber;
  final int vehicleId;
  final int? mechanicId;
  final String description;
  final double laborCost;
  final double totalPartsCost;
  final double totalCost;
  final WorkOrderStatus status;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final Vehicle? vehicle;
  final User? mechanic;
  final DateTime createdAt;
  final DateTime updatedAt;

  WorkOrder({
    required this.id,
    required this.workOrderNumber,
    required this.vehicleId,
    this.mechanicId,
    required this.description,
    required this.laborCost,
    required this.totalPartsCost,
    required this.totalCost,
    required this.status,
    this.startedAt,
    this.completedAt,
    this.vehicle,
    this.mechanic,
    required this.createdAt,
    required this.updatedAt,
  });

  factory WorkOrder.fromJson(Map<String, dynamic> json) {
    return WorkOrder(
      id: json['id'],
      workOrderNumber: json['work_order_number'],
      vehicleId: json['vehicle_id'],
      mechanicId: json['mechanic_id'],
      description: json['description'],
      laborCost: (json['labor_cost'] as num).toDouble(),
      totalPartsCost: (json['total_parts_cost'] as num).toDouble(),
      totalCost: (json['total_cost'] as num).toDouble(),
      status: WorkOrderStatus.fromString(json['status']),
      startedAt: json['started_at'] != null ? DateTime.parse(json['started_at']) : null,
      completedAt: json['completed_at'] != null ? DateTime.parse(json['completed_at']) : null,
      vehicle: json['vehicle'] != null ? Vehicle.fromJson(json['vehicle']) : null,
      mechanic: json['mechanic'] != null ? User.fromJson(json['mechanic']) : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}

class DashboardStats {
  final int totalVehicles;
  final int availableVehicles;
  final int vehiclesInRepair;
  final int soldToday;
  final double todayRevenue;
  final double monthlyRevenue;
  final int pendingWorkOrders;
  final int lowStockParts;

  DashboardStats({
    required this.totalVehicles,
    required this.availableVehicles,
    required this.vehiclesInRepair,
    required this.soldToday,
    required this.todayRevenue,
    required this.monthlyRevenue,
    required this.pendingWorkOrders,
    required this.lowStockParts,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalVehicles: json['total_vehicles'] ?? 0,
      availableVehicles: json['available_vehicles'] ?? 0,
      vehiclesInRepair: json['vehicles_in_repair'] ?? 0,
      soldToday: json['sold_today'] ?? 0,
      todayRevenue: (json['today_revenue'] as num?)?.toDouble() ?? 0.0,
      monthlyRevenue: (json['monthly_revenue'] as num?)?.toDouble() ?? 0.0,
      pendingWorkOrders: json['pending_work_orders'] ?? 0,
      lowStockParts: json['low_stock_parts'] ?? 0,
    );
  }
}