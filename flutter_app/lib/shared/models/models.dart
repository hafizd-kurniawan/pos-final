/// Data Transfer Objects (DTOs) for API communication
/// Matching the Go backend structure

/// Base API Response
class ApiResponse<T> {
  final String? message;
  final T? data;
  final String? error;
  final String? details;

  ApiResponse({
    this.message,
    this.data,
    this.error,
    this.details,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json, T Function(dynamic)? fromJsonT) {
    return ApiResponse<T>(
      message: json['message'],
      data: fromJsonT != null && json['data'] != null ? fromJsonT(json['data']) : json['data'],
      error: json['error'],
      details: json['details'],
    );
  }

  bool get isSuccess => error == null;
}

/// User Model
class User {
  final String id;
  final String username;
  final String email;
  final String fullName;
  final String phone;
  final String role;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.fullName,
    required this.phone,
    required this.role,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      fullName: json['full_name'],
      phone: json['phone'],
      role: json['role'],
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'full_name': fullName,
      'phone': phone,
      'role': role,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

/// Authentication DTOs
class LoginRequest {
  final String username;
  final String password;

  LoginRequest({
    required this.username,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
    };
  }
}

class LoginResponse {
  final String token;
  final User user;

  LoginResponse({
    required this.token,
    required this.user,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'],
      user: User.fromJson(json['user']),
    );
  }
}

/// Vehicle Model
class Vehicle {
  final String id;
  final String vehicleCategoryId;
  final String name;
  final String brand;
  final String model;
  final int year;
  final String color;
  final String licensePlate;
  final String engineNumber;
  final String chassisNumber;
  final int purchasePrice;
  final int repairCost;
  final int sellingPrice;
  final int hpp; // Harga Pokok Penjualan
  final String status;
  final String? description;
  final String? primaryPhotoUrl;
  final List<VehiclePhoto>? photos;
  final DateTime createdAt;
  final DateTime updatedAt;

  Vehicle({
    required this.id,
    required this.vehicleCategoryId,
    required this.name,
    required this.brand,
    required this.model,
    required this.year,
    required this.color,
    required this.licensePlate,
    required this.engineNumber,
    required this.chassisNumber,
    required this.purchasePrice,
    required this.repairCost,
    required this.sellingPrice,
    required this.hpp,
    required this.status,
    this.description,
    this.primaryPhotoUrl,
    this.photos,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'],
      vehicleCategoryId: json['vehicle_category_id'],
      name: json['name'],
      brand: json['brand'],
      model: json['model'],
      year: json['year'],
      color: json['color'],
      licensePlate: json['license_plate'],
      engineNumber: json['engine_number'],
      chassisNumber: json['chassis_number'],
      purchasePrice: json['purchase_price'],
      repairCost: json['repair_cost'] ?? 0,
      sellingPrice: json['selling_price'] ?? 0,
      hpp: json['hpp'] ?? 0,
      status: json['status'],
      description: json['description'],
      primaryPhotoUrl: json['primary_photo_url'],
      photos: json['photos'] != null 
          ? (json['photos'] as List).map((e) => VehiclePhoto.fromJson(e)).toList()
          : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vehicle_category_id': vehicleCategoryId,
      'name': name,
      'brand': brand,
      'model': model,
      'year': year,
      'color': color,
      'license_plate': licensePlate,
      'engine_number': engineNumber,
      'chassis_number': chassisNumber,
      'purchase_price': purchasePrice,
      'repair_cost': repairCost,
      'selling_price': sellingPrice,
      'hpp': hpp,
      'status': status,
      'description': description,
      'primary_photo_url': primaryPhotoUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

/// Vehicle Photo Model
class VehiclePhoto {
  final String id;
  final String vehicleId;
  final String photoUrl;
  final String angle;
  final bool isPrimary;
  final DateTime createdAt;

  VehiclePhoto({
    required this.id,
    required this.vehicleId,
    required this.photoUrl,
    required this.angle,
    required this.isPrimary,
    required this.createdAt,
  });

  factory VehiclePhoto.fromJson(Map<String, dynamic> json) {
    return VehiclePhoto(
      id: json['id'],
      vehicleId: json['vehicle_id'],
      photoUrl: json['photo_url'],
      angle: json['angle'],
      isPrimary: json['is_primary'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

/// Customer Model
class Customer {
  final String id;
  final String customerCode;
  final String name;
  final String? phone;
  final String? email;
  final String? address;
  final String? idNumber;
  final DateTime createdAt;
  final DateTime updatedAt;

  Customer({
    required this.id,
    required this.customerCode,
    required this.name,
    this.phone,
    this.email,
    this.address,
    this.idNumber,
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
      idNumber: json['id_number'],
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
      'id_number': idNumber,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

/// Sales Invoice Model
class SalesInvoice {
  final String id;
  final String invoiceNumber;
  final String customerId;
  final String vehicleId;
  final int sellingPrice;
  final int profit;
  final String paymentMethod;
  final String? transferProofUrl;
  final String? notes;
  final Customer? customer;
  final Vehicle? vehicle;
  final DateTime createdAt;
  final DateTime updatedAt;

  SalesInvoice({
    required this.id,
    required this.invoiceNumber,
    required this.customerId,
    required this.vehicleId,
    required this.sellingPrice,
    required this.profit,
    required this.paymentMethod,
    this.transferProofUrl,
    this.notes,
    this.customer,
    this.vehicle,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SalesInvoice.fromJson(Map<String, dynamic> json) {
    return SalesInvoice(
      id: json['id'],
      invoiceNumber: json['invoice_number'],
      customerId: json['customer_id'],
      vehicleId: json['vehicle_id'],
      sellingPrice: json['selling_price'],
      profit: json['profit'],
      paymentMethod: json['payment_method'],
      transferProofUrl: json['transfer_proof_url'],
      notes: json['notes'],
      customer: json['customer'] != null ? Customer.fromJson(json['customer']) : null,
      vehicle: json['vehicle'] != null ? Vehicle.fromJson(json['vehicle']) : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}

/// Purchase Invoice Model
class PurchaseInvoice {
  final String id;
  final String invoiceNumber;
  final String customerId;
  final String vehicleId;
  final int purchasePrice;
  final String paymentMethod;
  final String? transferProofUrl;
  final String? notes;
  final Customer? customer;
  final Vehicle? vehicle;
  final DateTime createdAt;
  final DateTime updatedAt;

  PurchaseInvoice({
    required this.id,
    required this.invoiceNumber,
    required this.customerId,
    required this.vehicleId,
    required this.purchasePrice,
    required this.paymentMethod,
    this.transferProofUrl,
    this.notes,
    this.customer,
    this.vehicle,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PurchaseInvoice.fromJson(Map<String, dynamic> json) {
    return PurchaseInvoice(
      id: json['id'],
      invoiceNumber: json['invoice_number'],
      customerId: json['customer_id'],
      vehicleId: json['vehicle_id'],
      purchasePrice: json['purchase_price'],
      paymentMethod: json['payment_method'],
      transferProofUrl: json['transfer_proof_url'],
      notes: json['notes'],
      customer: json['customer'] != null ? Customer.fromJson(json['customer']) : null,
      vehicle: json['vehicle'] != null ? Vehicle.fromJson(json['vehicle']) : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}

/// Work Order Model
class WorkOrder {
  final String id;
  final String workOrderNumber;
  final String vehicleId;
  final String? mechanicId;
  final String description;
  final int estimatedCost;
  final int actualCost;
  final String status;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final Vehicle? vehicle;
  final User? mechanic;
  final List<WorkOrderPart>? parts;
  final DateTime createdAt;
  final DateTime updatedAt;

  WorkOrder({
    required this.id,
    required this.workOrderNumber,
    required this.vehicleId,
    this.mechanicId,
    required this.description,
    required this.estimatedCost,
    required this.actualCost,
    required this.status,
    this.startedAt,
    this.completedAt,
    this.vehicle,
    this.mechanic,
    this.parts,
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
      estimatedCost: json['estimated_cost'],
      actualCost: json['actual_cost'] ?? 0,
      status: json['status'],
      startedAt: json['started_at'] != null ? DateTime.parse(json['started_at']) : null,
      completedAt: json['completed_at'] != null ? DateTime.parse(json['completed_at']) : null,
      vehicle: json['vehicle'] != null ? Vehicle.fromJson(json['vehicle']) : null,
      mechanic: json['mechanic'] != null ? User.fromJson(json['mechanic']) : null,
      parts: json['parts'] != null 
          ? (json['parts'] as List).map((e) => WorkOrderPart.fromJson(e)).toList()
          : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}

/// Work Order Part Model
class WorkOrderPart {
  final String id;
  final String workOrderId;
  final String sparePartId;
  final int quantity;
  final int unitPrice;
  final int totalPrice;
  final SparePart? sparePart;
  final DateTime createdAt;

  WorkOrderPart({
    required this.id,
    required this.workOrderId,
    required this.sparePartId,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    this.sparePart,
    required this.createdAt,
  });

  factory WorkOrderPart.fromJson(Map<String, dynamic> json) {
    return WorkOrderPart(
      id: json['id'],
      workOrderId: json['work_order_id'],
      sparePartId: json['spare_part_id'],
      quantity: json['quantity'],
      unitPrice: json['unit_price'],
      totalPrice: json['total_price'],
      sparePart: json['spare_part'] != null ? SparePart.fromJson(json['spare_part']) : null,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

/// Spare Part Model
class SparePart {
  final String id;
  final String partCode;
  final String name;
  final String? description;
  final String category;
  final int price;
  final int stock;
  final int minimumStock;
  final String? supplier;
  final String? location;
  final DateTime createdAt;
  final DateTime updatedAt;

  SparePart({
    required this.id,
    required this.partCode,
    required this.name,
    this.description,
    required this.category,
    required this.price,
    required this.stock,
    required this.minimumStock,
    this.supplier,
    this.location,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SparePart.fromJson(Map<String, dynamic> json) {
    return SparePart(
      id: json['id'],
      partCode: json['part_code'],
      name: json['name'],
      description: json['description'],
      category: json['category'],
      price: json['price'],
      stock: json['stock'],
      minimumStock: json['minimum_stock'],
      supplier: json['supplier'],
      location: json['location'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  bool get isLowStock => stock <= minimumStock;
}

/// Notification Model
class AppNotification {
  final String id;
  final String userId;
  final String type;
  final String title;
  final String message;
  final Map<String, dynamic>? data;
  final bool isRead;
  final DateTime createdAt;

  AppNotification({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.message,
    this.data,
    required this.isRead,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'],
      userId: json['user_id'],
      type: json['type'],
      title: json['title'],
      message: json['message'],
      data: json['data'],
      isRead: json['is_read'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

/// Dashboard Data Models
class DashboardMetrics {
  final int totalVehicles;
  final int availableVehicles;
  final int vehiclesInRepair;
  final int soldVehicles;
  final int totalCustomers;
  final int totalSales;
  final int totalPurchases;
  final int totalWorkOrders;
  final int pendingWorkOrders;
  final int completedWorkOrders;
  final int lowStockParts;
  final int totalRevenue;
  final int totalProfit;

  DashboardMetrics({
    required this.totalVehicles,
    required this.availableVehicles,
    required this.vehiclesInRepair,
    required this.soldVehicles,
    required this.totalCustomers,
    required this.totalSales,
    required this.totalPurchases,
    required this.totalWorkOrders,
    required this.pendingWorkOrders,
    required this.completedWorkOrders,
    required this.lowStockParts,
    required this.totalRevenue,
    required this.totalProfit,
  });

  factory DashboardMetrics.fromJson(Map<String, dynamic> json) {
    return DashboardMetrics(
      totalVehicles: json['total_vehicles'] ?? 0,
      availableVehicles: json['available_vehicles'] ?? 0,
      vehiclesInRepair: json['vehicles_in_repair'] ?? 0,
      soldVehicles: json['sold_vehicles'] ?? 0,
      totalCustomers: json['total_customers'] ?? 0,
      totalSales: json['total_sales'] ?? 0,
      totalPurchases: json['total_purchases'] ?? 0,
      totalWorkOrders: json['total_work_orders'] ?? 0,
      pendingWorkOrders: json['pending_work_orders'] ?? 0,
      completedWorkOrders: json['completed_work_orders'] ?? 0,
      lowStockParts: json['low_stock_parts'] ?? 0,
      totalRevenue: json['total_revenue'] ?? 0,
      totalProfit: json['total_profit'] ?? 0,
    );
  }
}