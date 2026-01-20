import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/booking.dart';

class BillDetailsScreen extends StatefulWidget {
  final Booking booking;

  const BillDetailsScreen({super.key, required this.booking});

  @override
  State<BillDetailsScreen> createState() => _BillDetailsScreenState();
}

class _BillDetailsScreenState extends State<BillDetailsScreen> {
  final Color _primaryColor = const Color(0xFF1a472a);
  final Color _backgroundColor = const Color(0xFFFBFAF7);

  bool _isLoading = true;
  List<Map<String, dynamic>> _serviceItems = [];
  double _servicesTotal = 0.0;

  // Utility function to format price as PKR (with cents for itemized bills)
  String _formatPKR(double amount) {
    return 'PKR ${amount.toStringAsFixed(2)}';
  }

  @override
  void initState() {
    super.initState();
    _fetchBillDetails();
  }

  Future<void> _fetchBillDetails() async {
    try {
      final supabase = Supabase.instance.client;

      // Fetch services linked to this booking via the join table
      // We join with 'services' table to get the name of the service
      final response = await supabase
          .from('booking_services')
          .select('*, services(service_name)')
          .eq('booking_id', widget.booking.id);

      final List<Map<String, dynamic>> items = [];
      double total = 0.0;

      for (var record in response) {
        final String name = record['services'] != null
            ? record['services']['service_name']
            : 'Unknown Service';
        final double price = (record['price_at_time'] as num).toDouble();
        final int quantity = record['quantity'] as int;
        final double itemTotal = price * quantity;

        total += itemTotal;
        items.add({
          'name': name,
          'price': price,
          'qty': quantity,
          'total': itemTotal,
        });
      }

      if (mounted) {
        setState(() {
          _serviceItems = items;
          _servicesTotal = total;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching bill details: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not load bill details: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final double grandTotal = widget.booking.initialTotalBill + _servicesTotal;

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: _backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: _primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Booking Invoice',
          style: TextStyle(color: _primaryColor, fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: _primaryColor))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- Header Card ---
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: _primaryColor,
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          // CHANGED: Use PKR format
                          _formatPKR(grandTotal),
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: _primaryColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Total Paid',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Divider(),
                        const SizedBox(height: 16),
                        _buildInfoRow('Room', widget.booking.roomId),
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          'Check-in',
                          dateFormat.format(widget.booking.checkIn),
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          'Check-out',
                          dateFormat.format(widget.booking.checkOut),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // --- Bill Breakdown ---
                  Text(
                    "BILL BREAKDOWN",
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      children: [
                        // 1. Room Charges
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: _buildBillItem(
                            'Room Charges',
                            'Base Rate',
                            widget.booking.initialTotalBill,
                          ),
                        ),

                        if (_serviceItems.isNotEmpty) const Divider(height: 1),

                        // 2. Service Items
                        if (_serviceItems.isNotEmpty)
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _serviceItems.length,
                            padding: const EdgeInsets.all(16),
                            separatorBuilder: (ctx, i) =>
                                const SizedBox(height: 16),
                            itemBuilder: (ctx, index) {
                              final item = _serviceItems[index];
                              return _buildBillItem(
                                item['name'],
                                // CHANGED: Update subtitle to show PKR price per item
                                '${item['qty']} x PKR ${item['price'].toStringAsFixed(2)}',
                                item['total'],
                              );
                            },
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
        ),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildBillItem(String title, String subtitle, double amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
            ),
          ],
        ),
        Text(
          // CHANGED: Use PKR format
          _formatPKR(amount),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: _primaryColor,
          ),
        ),
      ],
    );
  }
}
