import 'enum.dart';

class Room {
  final String id;
  final String name;
  RoomType type;
  double pricePerNight;
  bool isAvailable;

  Room({
    required this.id,
    required this.name,
    required this.type,
    required this.pricePerNight,
    this.isAvailable = true,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    // Fix: Store just the name 'standard', 'deluxe' etc.
    'type': type.name,
    'price_per_night': pricePerNight, // Match DB column name
    'is_available': isAvailable, // Match DB column name
  };

  factory Room.fromMap(Map<String, dynamic> json) => Room(
    id: json['id']?.toString() ?? '',
    name: json['name']?.toString() ?? '',
    // Fix: Compare e.name ('standard') with json['type'] ('standard')
    type: RoomType.values.firstWhere(
      (e) =>
          e.name.toLowerCase() ==
          (json['type']?.toString().toLowerCase() ?? ''),
      orElse: () => RoomType.standard,
    ),
    // Map from 'price_per_night' (DB) to 'pricePerNight' (Dart)
    pricePerNight: (json['price_per_night'] as num?)?.toDouble() ?? 0.0,
    isAvailable: json['is_available'] ?? true,
  );
}
