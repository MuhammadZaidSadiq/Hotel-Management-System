// ignore_for_file: unused_import

import 'service.dart';
import 'loyalty_enums.dart';

class Client {
  final String id;
  String name;
  String email;
  String
  password; // Only used locally for registration logic, NEVER stored in 'clients' table
  String contact;
  List<String> bookingIds;
  List<Service> preferences;

  // --- Loyalty Fields ---
  int bonusPointsBalance;
  int totalNightsStayed;
  String currentTier;
  List<String> pointsAwardedTiers;

  // --- Supabase Specific ---
  String? cnic;
  String? address;
  String? gender;
  DateTime? dob;

  Client({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.contact,
    this.bookingIds = const [],
    this.preferences = const [],
    this.bonusPointsBalance = 0,
    this.totalNightsStayed = 0,
    this.currentTier = 'MEMBER',
    this.pointsAwardedTiers = const [],
    this.cnic,
    this.address,
    this.gender,
    this.dob,
  });

  // Maps to Supabase 'clients' table structure
  Map<String, dynamic> toMap() => {
    'id': id,
    'full_name': name,
    'email': email,
    'phone': contact,
    'cnic': cnic,
    'address': address,
    'gender': gender,
    'dob': dob?.toIso8601String(),

    // Flatten loyalty fields if your table supports them, or use a JSONB column
    // For now, assuming standard columns
    'bonus_points': bonusPointsBalance,
    'nights_stayed': totalNightsStayed,
    'current_tier': currentTier,
    // Arrays in Supabase are often stored as Postgres arrays
    'booking_ids': bookingIds,
    // Preferences might need to be a separate table or JSONB
  };

  factory Client.fromMap(Map<String, dynamic> json) => Client(
    id: json['id'] ?? '',
    name: json['full_name'] ?? '',
    email: json['email'] ?? '',
    password: '', // Password is handled by Supabase Auth, not stored here
    contact: json['phone'] ?? '',
    cnic: json['cnic'],
    address: json['address'],
    gender: json['gender'],
    dob: json['dob'] != null ? DateTime.tryParse(json['dob']) : null,

    bonusPointsBalance: json['bonus_points'] as int? ?? 0,
    totalNightsStayed: json['nights_stayed'] as int? ?? 0,
    currentTier: json['current_tier'] as String? ?? 'MEMBER',

    bookingIds: (json['booking_ids'] as List?)?.cast<String>() ?? [],
    // Mapping complex preferences usually requires fetching from related tables
    preferences: [],
  );
}
