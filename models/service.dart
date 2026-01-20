// lib/models/service.dart
import 'enum.dart';

class Service {
  final String id;
  final String name;
  final String description;
  final ServiceType type;
  final double price;
  final DateTime? createdAt;

  Service({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.price,
    this.createdAt,
  });

  factory Service.fromMap(Map<String, dynamic> json) {
    final rawType = (json['service_type'] ?? 'meal')
        .toString()
        .toLowerCase()
        .trim();

    ServiceType serviceType = ServiceType.meal;

    // PROPER MAPPING — Supports "housekeeping", "Housekeeping", "HOUSEKEEPING", etc.
    switch (rawType) {
      case 'housekeeping':
      case 'house keeping':
      case 'cleaning':
      case 'room cleaning':
        serviceType = ServiceType.housekeeping;
        break;
      case 'laundry':
      case 'dry cleaning':
        serviceType = ServiceType.laundry;
        break;
      case 'spa':
      case 'massage':
        serviceType = ServiceType.spa;
        break;
      case 'meal':
      case 'food':
      case 'room service':
      default:
        serviceType = ServiceType.meal;
    }

    return Service(
      id:
          json['id']?.toString() ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      name: (json['service_name'] ?? 'Unnamed Service').toString(),
      description: (json['description'] ?? '').toString(),
      type: serviceType,
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'service_name': name,
    'description': description,
    'service_type': type.name, // Saves as "housekeeping"
    'price': price,
  };
}
