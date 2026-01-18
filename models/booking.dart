import 'service.dart';
import 'enum.dart';

class Booking {
  final String id;
  final String clientId;
  final String roomId;
  final DateTime checkIn;
  final DateTime checkOut;
  BookingStatus status;
  List<Service> servicesUsed;

  // --- Loyalty & Financial Audit Fields ---
  double initialTotalBill; // Total cost before any points/discounts
  double finalCashPaid; // Cash paid after point redemption (used for accrual)

  Booking({
    required this.id,
    required this.clientId,
    required this.roomId,
    required this.checkIn,
    required this.checkOut,
    this.status = BookingStatus.active,
    this.servicesUsed = const [],
    this.initialTotalBill = 0.0,
    this.finalCashPaid = 0.0,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'clientId': clientId,
    'roomId': roomId,
    'checkIn': checkIn.toIso8601String(),
    'checkOut': checkOut.toIso8601String(),
    'status': status.toString(),
    'servicesUsed': servicesUsed.map((s) => s.toMap()).toList(),
    'initialTotalBill': initialTotalBill,
    'finalCashPaid': finalCashPaid,
  };

  factory Booking.fromMap(Map<String, dynamic> json) => Booking(
    id: json['id'] as String? ?? '',
    clientId: json['clientId'] as String? ?? '',
    roomId: json['roomId'] as String? ?? '',
    checkIn:
        DateTime.tryParse(json['checkIn'] as String? ?? '') ?? DateTime.now(),
    checkOut:
        DateTime.tryParse(json['checkOut'] as String? ?? '') ?? DateTime.now(),
    status: BookingStatus.values.firstWhere(
      (e) => e.toString() == (json['status'] as String?),
      orElse: () => BookingStatus.active,
    ),
    servicesUsed:
        (json['servicesUsed'] as List<dynamic>?)
            ?.map((e) => Service.fromMap(Map<String, dynamic>.from(e)))
            .toList() ??
        const [],
    initialTotalBill: (json['initialTotalBill'] as num? ?? 0.0).toDouble(),
    finalCashPaid: (json['finalCashPaid'] as num? ?? 0.0).toDouble(),
  );
}
