import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '/models/room.dart';
import '/home.dart'; // To navigate back to Trips tab

class RoomDetailsScreen extends StatefulWidget {
  final Room room;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final String imageUrl;

  const RoomDetailsScreen({
    super.key,
    required this.room,
    required this.checkInDate,
    required this.checkOutDate,
    required this.imageUrl,
  });

  @override
  State<RoomDetailsScreen> createState() => _RoomDetailsScreenState();
}

class _RoomDetailsScreenState extends State<RoomDetailsScreen> {
  bool _isBooking = false;
  final Color _primaryColor = const Color(0xFF1a472a);

  int get _totalNights {
    return widget.checkOutDate.difference(widget.checkInDate).inDays;
  }

  double get _totalPrice {
    return widget.room.pricePerNight * _totalNights;
  }

  // Utility function to format price as PKR
  String _formatPKR(double amount) {
    // You can use Intl for locale-specific formatting if needed, but for simplicity
    // and ensuring "PKR" is visible, a simple concatenation is used here.
    return 'PKR ${amount.toStringAsFixed(2)}';
  }

  Future<void> _confirmBooking() async {
    setState(() => _isBooking = true);

    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;

      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You must be logged in to book.')),
        );
        return;
      }

      // --- ADDED CHECK: Limit active bookings to 3 ---
      // fetch all bookings for this user that are either 'active' or 'pending'
      final activeBookings = await supabase
          .from('bookings')
          .select('id')
          .eq('client_id', user.id)
          .or('status.eq.active,status.eq.pending');

      // If user already has 3 or more, block the new booking
      if (activeBookings.length >= 3) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'Booking Limit Reached: You can only have 3 active trips at a time.',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              margin: const EdgeInsets.all(20),
            ),
          );
        }
        return; // EXIT FUNCTION
      }
      // ------------------------------------------------

      // Insert into Supabase
      await supabase.from('bookings').insert({
        'client_id': user.id,
        'room_id': widget.room.id,
        'check_in': widget.checkInDate.toIso8601String(),
        'check_out': widget.checkOutDate.toIso8601String(),
        // 'active' maps to the "Current" tab in TripsScreen
        'status': 'active',
        'initial_total_bill': _totalPrice,
        'final_cash_paid': 0.0, // Not paid yet
        'requeststatus':
            'pending', // Uncomment if you added this column to your DB
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Booking Confirmed!'),
            backgroundColor: _primaryColor,
          ),
        );

        // Navigate back to Home and switch to Trips tab (index 2)
        // We use pushAndRemoveUntil to reset the stack
        // You might need to adjust the path to HomeScreen if it's incorrect
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Booking Failed: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isBooking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEE, MMM d');

    // Calculate total price including 10% tax
    final double subtotal = _totalPrice;
    final double tax = subtotal * 0.1;
    final double grandTotal = subtotal + tax;

    return Scaffold(
      backgroundColor: const Color(0xFFFBFAF7),
      body: Stack(
        children: [
          // Top Image
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 300,
            child: Image.network(widget.imageUrl, fit: BoxFit.cover),
          ),
          // Back Button
          Positioned(
            top: 40,
            left: 20,
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
          // Content Sheet
          Positioned.fill(
            top: 260,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Color(0xFFFBFAF7),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.room.name,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: _primaryColor,
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            // CHANGED: Use 'PKR' instead of '$'
                            'PKR ${widget.room.pricePerNight.round()}',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: _primaryColor,
                            ),
                          ),
                          Text(
                            '/ night',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Dates Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('CHECK-IN', style: _labelStyle),
                              const SizedBox(height: 4),
                              Text(
                                dateFormat.format(widget.checkInDate),
                                style: _valueStyle,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('CHECK-OUT', style: _labelStyle),
                              const SizedBox(height: 4),
                              Text(
                                dateFormat.format(widget.checkOutDate),
                                style: _valueStyle,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Bill Breakdown
                  const Text(
                    "Price Details",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildPriceRow(
                    // CHANGED: Use _formatPKR for total price
                    "PKR ${widget.room.pricePerNight.toStringAsFixed(0)} x $_totalNights nights",
                    _formatPKR(subtotal),
                  ),
                  const SizedBox(height: 12),
                  _buildPriceRow("Taxes & Fees (10%)", _formatPKR(tax)),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(),
                  ),
                  _buildPriceRow(
                    "Total",
                    _formatPKR(grandTotal),
                    isTotal: true,
                  ),

                  const Spacer(),

                  // Book Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isBooking ? null : _confirmBooking,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: _isBooking
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              "Confirm Booking",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  TextStyle get _labelStyle => TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: Colors.grey.shade500,
    letterSpacing: 0.5,
  );

  TextStyle get _valueStyle => TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.bold,
    color: _primaryColor,
  );

  Widget _buildPriceRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? Colors.black : Colors.grey.shade700,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 18 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? _primaryColor : Colors.black,
          ),
        ),
      ],
    );
  }
}
