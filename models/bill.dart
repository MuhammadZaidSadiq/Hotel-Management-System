// lib/models/bill.dart
import 'service.dart';
import 'enum.dart';

class Bill {
  final String id;
  final String clientId;
  final String roomId;
  final int numberOfDays;
  final double roomCharge;

  /// Each service now properly carries its ORIGINAL service ID from the database
  final List<ServiceWithId> servicesUsed;

  final double servicesTotal;
  final double totalBill;
  final DateTime generatedAt;

  Bill({
    required this.id,
    required this.clientId,
    required this.roomId,
    required this.numberOfDays,
    required this.roomCharge,
    required this.servicesUsed,
    required this.servicesTotal,
    required this.totalBill,
    required this.generatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clientId': clientId,
      'roomId': roomId,
      'numberOfDays': numberOfDays,
      'roomCharge': roomCharge,
      'servicesUsed': servicesUsed.map((s) => s.toMap()).toList(),
      'servicesTotal': servicesTotal,
      'totalBill': totalBill,
      'generatedAt': generatedAt.toIso8601String(),
    };
  }

  factory Bill.fromJson(Map<String, dynamic> json) {
    final List<dynamic>? rawServices = json['servicesUsed'] as List?;

    return Bill(
      id: json['id'] as String,
      clientId: json['clientId'] as String,
      roomId: json['roomId'] as String,
      numberOfDays: json['numberOfDays'] as int,
      roomCharge: (json['roomCharge'] as num).toDouble(),
      servicesUsed:
          rawServices
              ?.map(
                (item) =>
                    ServiceWithId.fromMap(Map<String, dynamic>.from(item)),
              )
              .toList() ??
          [],
      servicesTotal: (json['servicesTotal'] as num).toDouble(),
      totalBill: (json['totalBill'] as num).toDouble(),
      generatedAt: DateTime.parse(json['generatedAt'] as String),
    );
  }
}

/// Properly preserves the original Service ID + full service data
class ServiceWithId {
  /// This is the actual ID from the 'services' table (e.g., "svc_001")
  final String serviceId;

  final String name;
  final String description;
  final ServiceType type;
  final double price;
  final int quantity; // Optional: how many times used (default 1)

  ServiceWithId({
    required this.serviceId,
    required this.name,
    required this.description,
    required this.type,
    required this.price,
    this.quantity = 1,
  });

  /// Create from a Service object (most common use case)
  factory ServiceWithId.fromService(Service service, {int quantity = 1}) {
    return ServiceWithId(
      serviceId: service.id, // ← This is the key: grabs service.id
      name: service.name,
      description: service.description,
      type: service.type,
      price: service.price,
      quantity: quantity,
    );
  }

  /// Create from JSON/map (when loading saved bill)
  factory ServiceWithId.fromMap(Map<String, dynamic> map) {
    return ServiceWithId(
      serviceId: (map['serviceId'] ?? map['id'] ?? 'unknown').toString(),
      name: (map['service_name'] ?? map['name'] ?? 'Unknown').toString(),
      description: (map['description'] ?? '').toString(),
      type: _parseType(map['service_type'] ?? 'meal'),
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      quantity: (map['quantity'] as int?) ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'serviceId': serviceId,
      'service_name': name,
      'description': description,
      'service_type': type.name,
      'price': price,
      'quantity': quantity,
    };
  }

  static ServiceType _parseType(String type) {
    return ServiceType.values.firstWhere(
      (e) => e.name == type.toLowerCase(),
      orElse: () => ServiceType.meal,
    );
  }

  /// Convert back to full Service object if needed
  Service toService() => Service(
    id: serviceId,
    name: name,
    description: description,
    type: type,
    price: price,
  );
}
