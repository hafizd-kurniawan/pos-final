class Customer {
  final int id;
  final String customerCode;
  final String name;
  final String? ktpNumber;
  final String? phone;
  final String? email;
  final String? address;
  final DateTime createdAt;
  final DateTime? updatedAt;
  
  Customer({
    required this.id,
    required this.customerCode,
    required this.name,
    this.ktpNumber,
    this.phone,
    this.email,
    this.address,
    required this.createdAt,
    this.updatedAt,
  });
  
  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'] as int,
      customerCode: json['customer_code'] as String,
      name: json['name'] as String,
      ktpNumber: json['ktp_number'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      address: json['address'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_code': customerCode,
      'name': name,
      'ktp_number': ktpNumber,
      'phone': phone,
      'email': email,
      'address': address,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
  
  Customer copyWith({
    int? id,
    String? customerCode,
    String? name,
    String? ktpNumber,
    String? phone,
    String? email,
    String? address,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Customer(
      id: id ?? this.id,
      customerCode: customerCode ?? this.customerCode,
      name: name ?? this.name,
      ktpNumber: ktpNumber ?? this.ktpNumber,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
  
  @override
  String toString() {
    return 'Customer(id: $id, name: $name, code: $customerCode)';
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Customer && other.id == id;
  }
  
  @override
  int get hashCode => id.hashCode;
}

class CreateCustomerRequest {
  final String name;
  final String? ktpNumber;
  final String? phone;
  final String? email;
  final String? address;
  
  CreateCustomerRequest({
    required this.name,
    this.ktpNumber,
    this.phone,
    this.email,
    this.address,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'ktp_number': ktpNumber,
      'phone': phone,
      'email': email,
      'address': address,
    };
  }
}