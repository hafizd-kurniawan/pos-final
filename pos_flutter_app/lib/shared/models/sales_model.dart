import 'customer_model.dart';
import 'vehicle_model.dart';

class SalesInvoice {
  final int id;
  final String invoiceNumber;
  final int customerId;
  final int vehicleId;
  final double sellingPrice;
  final String paymentMethod;
  final String? notes;
  final String? transferProofPath;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final Customer? customer;
  final Vehicle? vehicle;
  
  SalesInvoice({
    required this.id,
    required this.invoiceNumber,
    required this.customerId,
    required this.vehicleId,
    required this.sellingPrice,
    required this.paymentMethod,
    this.notes,
    this.transferProofPath,
    required this.createdAt,
    this.updatedAt,
    this.customer,
    this.vehicle,
  });
  
  factory SalesInvoice.fromJson(Map<String, dynamic> json) {
    return SalesInvoice(
      id: json['id'] as int,
      invoiceNumber: json['invoice_number'] as String,
      customerId: json['customer_id'] as int,
      vehicleId: json['vehicle_id'] as int,
      sellingPrice: (json['selling_price'] as num).toDouble(),
      paymentMethod: json['payment_method'] as String,
      notes: json['notes'] as String?,
      transferProofPath: json['transfer_proof_path'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      customer: json['customer'] != null 
          ? Customer.fromJson(json['customer'] as Map<String, dynamic>)
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
      'customer_id': customerId,
      'vehicle_id': vehicleId,
      'selling_price': sellingPrice,
      'payment_method': paymentMethod,
      'notes': notes,
      'transfer_proof_path': transferProofPath,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'customer': customer?.toJson(),
      'vehicle': vehicle?.toJson(),
    };
  }
}

class CreateSalesRequest {
  final int customerId;
  final int vehicleId;
  final double sellingPrice;
  final String paymentMethod;
  final String? notes;
  
  CreateSalesRequest({
    required this.customerId,
    required this.vehicleId,
    required this.sellingPrice,
    required this.paymentMethod,
    this.notes,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'customer_id': customerId,
      'vehicle_id': vehicleId,
      'selling_price': sellingPrice,
      'payment_method': paymentMethod,
      'notes': notes,
    };
  }
}