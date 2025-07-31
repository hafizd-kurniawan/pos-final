class PurchaseInvoice {
  final int id;
  final String invoiceNumber;
  final String supplierName;
  final String? supplierContact;
  final String vehicleBrand;
  final String vehicleModel;
  final int vehicleYear;
  final double purchasePrice;
  final String? notes;
  final String? transferProofPath;
  final int? vehicleId;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final Vehicle? vehicle;
  
  PurchaseInvoice({
    required this.id,
    required this.invoiceNumber,
    required this.supplierName,
    this.supplierContact,
    required this.vehicleBrand,
    required this.vehicleModel,
    required this.vehicleYear,
    required this.purchasePrice,
    this.notes,
    this.transferProofPath,
    this.vehicleId,
    required this.createdAt,
    this.updatedAt,
    this.vehicle,
  });
  
  factory PurchaseInvoice.fromJson(Map<String, dynamic> json) {
    return PurchaseInvoice(
      id: json['id'] as int,
      invoiceNumber: json['invoice_number'] as String,
      supplierName: json['supplier_name'] as String,
      supplierContact: json['supplier_contact'] as String?,
      vehicleBrand: json['vehicle_brand'] as String,
      vehicleModel: json['vehicle_model'] as String,
      vehicleYear: json['vehicle_year'] as int,
      purchasePrice: (json['purchase_price'] as num).toDouble(),
      notes: json['notes'] as String?,
      transferProofPath: json['transfer_proof_path'] as String?,
      vehicleId: json['vehicle_id'] as int?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      vehicle: json['vehicle'] != null 
          ? Vehicle.fromJson(json['vehicle'] as Map<String, dynamic>)
          : null,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'invoice_number': invoiceNumber,
      'supplier_name': supplierName,
      'supplier_contact': supplierContact,
      'vehicle_brand': vehicleBrand,
      'vehicle_model': vehicleModel,
      'vehicle_year': vehicleYear,
      'purchase_price': purchasePrice,
      'notes': notes,
      'transfer_proof_path': transferProofPath,
      'vehicle_id': vehicleId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'vehicle': vehicle?.toJson(),
    };
  }
}

class CreatePurchaseRequest {
  final String supplierName;
  final String? supplierContact;
  final String vehicleBrand;
  final String vehicleModel;
  final int vehicleYear;
  final double purchasePrice;
  final String? notes;
  
  CreatePurchaseRequest({
    required this.supplierName,
    this.supplierContact,
    required this.vehicleBrand,
    required this.vehicleModel,
    required this.vehicleYear,
    required this.purchasePrice,
    this.notes,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'supplier_name': supplierName,
      'supplier_contact': supplierContact,
      'vehicle_brand': vehicleBrand,
      'vehicle_model': vehicleModel,
      'vehicle_year': vehicleYear,
      'purchase_price': purchasePrice,
      'notes': notes,
    };
  }
}

// Import statements that would be needed
import 'vehicle_model.dart';