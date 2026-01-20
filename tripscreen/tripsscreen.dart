import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/booking.dart';
import '../models/enum.dart';
import 'ServiceOrderingScreen.dart';

class TripsScreen extends StatefulWidget {
  const TripsScreen({super.key});

  @override
  State<TripsScreen> createState() => _TripsScreenState();
}

class _TripsScreenState extends State<TripsScreen> {
  final Color _primaryColor = const Color(0xFF1a472a);
  final Color _backgroundColor = const Color(0xFFFBFAF7);

  bool _isLoading = true;
  List<Booking> _allBookings = [];
  final Map<String, String> _bookingRequestStatuses = {};

  // Utility function to format price as PKR
  String _formatPKR(double amount) {
    // Using simple concatenation for display consistency across the app
    return 'PKR ${amount.toStringAsFixed(0)}';
  }

  // Utility function to format price as PKR (with cents for itemized bills)
  String _formatPKRWithCents(double amount) {
    return 'PKR ${amount.toStringAsFixed(2)}';
  }

  @override
  void initState() {
    super.initState();
    _fetchBookings();
  }

  Future<void> _fetchBookings() async {
    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id;

      if (userId == null) {
        setState(() => _isLoading = false);
        return;
      }

      final response = await supabase
          .from('bookings')
          .select('*, rooms(name), requeststatus')
          .eq('client_id', userId)
          .order('check_in', ascending: false);

      final List<Booking> loadedBookings = [];
      final Map<String, String> requestStatuses = {};

      for (var data in response) {
        final Map<String, dynamic> mappedData = {
          'id': data['id'],
          'clientId': data['client_id'],
          'roomId': data['rooms'] != null
              ? data['rooms']['name']
              : 'Unknown Room',
          'checkIn': data['check_in'],
          'checkOut': data['check_out'],
          'status': 'BookingStatus.${data['status']}',
          'initialTotalBill': data['initial_total_bill'],
          'finalCashPaid': data['final_cash_paid'],
          'pointsRedeemed': data['points_redeemed'],
          'tierOnCheckin': data['tier_on_checkin'],
          'servicesUsed': [],
        };

        requestStatuses[data['id']] = data['requeststatus'] ?? 'pending';
        loadedBookings.add(Booking.fromMap(mappedData));
      }

      if (mounted) {
        setState(() {
          _allBookings = loadedBookings;
          _bookingRequestStatuses.addAll(requestStatuses);
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching bookings: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _cancelBooking(String bookingId) async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Cancel Booking',
          style: TextStyle(color: _primaryColor, fontWeight: FontWeight.bold),
        ),
        content: const Text('Are you sure you want to cancel this trip?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('No', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _processCancellation(bookingId);
            },
            child: const Text(
              'Yes, Cancel',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _processCancellation(String bookingId) async {
    try {
      await Supabase.instance.client
          .from('bookings')
          .update({'status': 'cancelled'})
          .eq('id', bookingId);
      await _fetchBookings();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Booking Cancelled'),
            backgroundColor: _primaryColor,
          ),
        );
      }
    } catch (e) {
      // Handle error
    }
  }

  List<Booking> _getBookingsByStatus(BookingStatus status) {
    return _allBookings.where((b) => b.status == status).toList();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: _backgroundColor,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: _backgroundColor,
          elevation: 0,
          title: Text(
            'My Trips',
            style: TextStyle(
              color: _primaryColor,
              fontWeight: FontWeight.w700,
              fontSize: 24,
              letterSpacing: -0.5,
            ),
          ),
          bottom: TabBar(
            labelColor: _primaryColor,
            unselectedLabelColor: Colors.grey.shade500,
            indicatorColor: _primaryColor,
            indicatorWeight: 3,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
            tabs: const [
              Tab(text: 'Current'),
              Tab(text: 'Completed'),
              Tab(text: 'Cancelled'),
            ],
          ),
        ),
        body: _isLoading
            ? Center(child: CircularProgressIndicator(color: _primaryColor))
            : TabBarView(
                children: [
                  _buildList(
                    _getBookingsByStatus(BookingStatus.active),
                    isCurrent: true,
                  ),
                  _buildList(
                    _getBookingsByStatus(BookingStatus.completed),
                    isCompleted: true,
                  ),
                  _buildList(_getBookingsByStatus(BookingStatus.cancelled)),
                ],
              ),
      ),
    );
  }

  Widget _buildList(
    List<Booking> bookings, {
    bool isCurrent = false,
    bool isCompleted = false,
  }) {
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.luggage_outlined, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'No trips found',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: bookings.length,
      separatorBuilder: (ctx, index) => const SizedBox(height: 16),
      itemBuilder: (ctx, index) {
        final booking = bookings[index];

        // If it's the Completed tab, use the new Expandable Card
        if (isCompleted) {
          // Pass the PKR formatters to the history card
          return BookingHistoryCard(
            booking: booking,
            formatPKR: _formatPKRWithCents,
          );
        }

        // Otherwise use the standard card for Active/Cancelled
        return _buildStandardCard(booking, isCurrent: isCurrent);
      },
    );
  }

  // Original Card for Current/Cancelled
  Widget _buildStandardCard(Booking booking, {bool isCurrent = false}) {
    final dateRange =
        '${DateFormat('d MMM').format(booking.checkIn)} - ${DateFormat('d MMM yyyy').format(booking.checkOut)}';
    final reqStatus = _bookingRequestStatuses[booking.id] ?? 'pending';

    final bool isCheckedIn = reqStatus.toLowerCase() == 'active';
    final bool showServiceButton = isCurrent && isCheckedIn;
    final bool showCancelButton = isCurrent && !isCheckedIn;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: _primaryColor.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.roomId,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey.shade900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dateRange,
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  // CHANGED: Use PKR format
                  _formatPKR(booking.initialTotalBill),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: _primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Divider(color: Colors.grey.shade100, height: 1),
            const SizedBox(height: 16),
            // Use SingleChildScrollView to prevent overflow if the label+buttons are too wide
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      // MODIFIED: Hide the main status chip if isCurrent is true
                      if (!isCurrent) _buildStatusChip(booking.status),

                      if (isCurrent) ...[
                        // Removed the SizedBox(width: 12) here as this is now the first element
                        Text(
                          "Check-in Status:",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(width: 6),
                        _buildReqStatusChip(reqStatus),
                      ],
                    ],
                  ),
                  const SizedBox(width: 16), // Spacer between status and action
                  if (showServiceButton)
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ServiceOrderingScreen(bookingId: booking.id),
                          ),
                        );
                      },
                      child: Text(
                        'Order Service',
                        style: TextStyle(
                          color: _primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  if (showCancelButton)
                    TextButton(
                      onPressed: () => _cancelBooking(booking.id),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(BookingStatus status) {
    Color color;
    IconData icon;
    switch (status) {
      case BookingStatus.active:
        color = _primaryColor;
        icon = Icons.check_circle_outline;
        break;
      case BookingStatus.completed:
        color = Colors.blueGrey;
        icon = Icons.done_all;
        break;
      case BookingStatus.cancelled:
        color = Colors.redAccent;
        icon = Icons.cancel_outlined;
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            status.name.toUpperCase(),
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReqStatusChip(String status) {
    Color color = status == 'approved' ? Colors.green : Colors.orange;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class BookingHistoryCard extends StatefulWidget {
  final Booking booking;
  // Added required function to format PKR
  final String Function(double) formatPKR;

  const BookingHistoryCard({
    super.key,
    required this.booking,
    required this.formatPKR,
  });

  @override
  State<BookingHistoryCard> createState() => _BookingHistoryCardState();
}

class _BookingHistoryCardState extends State<BookingHistoryCard> {
  bool _isExpanded = false;
  bool _isLoadingDetails = false;
  List<Map<String, dynamic>> _services = [];
  double _servicesTotal = 0.0;
  final Color _primaryColor = const Color(0xFF1a472a);

  Future<void> _fetchBillDetails() async {
    if (_services.isNotEmpty) return; // Already fetched

    setState(() => _isLoadingDetails = true);

    try {
      final supabase = Supabase.instance.client;

      // Fetch services linked to this booking
      final response = await supabase
          .from('booking_services')
          .select('*, services(service_name)')
          .eq('booking_id', widget.booking.id);

      double total = 0.0;
      final List<Map<String, dynamic>> fetchedServices = [];

      for (var item in response) {
        final price = item['price_at_time'] as num;
        final qty = item['quantity'] as int;
        final cost = price * qty;
        total += cost;

        fetchedServices.add({
          'name': item['services']['service_name'],
          'qty': qty,
          'price': price,
          'total': cost,
        });
      }

      if (mounted) {
        setState(() {
          _services = fetchedServices;
          _servicesTotal = total;
          _isLoadingDetails = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching bill details: $e');
      if (mounted) setState(() => _isLoadingDetails = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateRange =
        '${DateFormat('d MMM yyyy').format(widget.booking.checkIn)} - ${DateFormat('d MMM yyyy').format(widget.booking.checkOut)}';
    final grandTotal = widget.booking.initialTotalBill + _servicesTotal;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isExpanded
              ? _primaryColor.withOpacity(0.3)
              : Colors.grey.shade100,
        ),
        boxShadow: [
          BoxShadow(
            color: _primaryColor.withOpacity(_isExpanded ? 0.1 : 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // --- Main Header (Click to Expand) ---
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
              if (_isExpanded) {
                _fetchBillDetails();
              }
            },
            borderRadius: BorderRadius.vertical(
              top: const Radius.circular(16),
              bottom: Radius.circular(_isExpanded ? 0 : 16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.booking.roomId,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey.shade900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          dateRange,
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blueGrey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'COMPLETED',
                          style: TextStyle(
                            color: Colors.blueGrey,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        _isExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // --- Expanded Bill Details ---
          if (_isExpanded)
            Container(
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey.shade100)),
                color: const Color(0xFFFBFAF7).withOpacity(0.5),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(16),
                ),
              ),
              padding: const EdgeInsets.all(20),
              child: _isLoadingDetails
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: CircularProgressIndicator(
                          color: _primaryColor,
                          strokeWidth: 2,
                        ),
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "BILL DETAILS",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Room Charge
                        _buildBillRow(
                          "Room Charge",
                          // CHANGED: Use passed-in formatPKR
                          widget.formatPKR(widget.booking.initialTotalBill),
                        ),

                        // Services List
                        if (_services.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          const Divider(),
                          const SizedBox(height: 8),
                          ..._services.map(
                            (s) => _buildBillRow(
                              "${s['qty']}x ${s['name']}",
                              // CHANGED: Use passed-in formatPKR
                              widget.formatPKR((s['total'] as num).toDouble()),
                              isSubItem: true,
                            ),
                          ),
                        ],

                        const SizedBox(height: 16),
                        const Divider(thickness: 1),
                        const SizedBox(height: 8),

                        // Grand Total
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Grand Total",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: _primaryColor,
                              ),
                            ),
                            Text(
                              // CHANGED: Use passed-in formatPKR
                              widget.formatPKR(grandTotal),
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: _primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
            ),
        ],
      ),
    );
  }

  Widget _buildBillRow(String label, String amount, {bool isSubItem = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isSubItem ? 13 : 14,
              color: isSubItem ? Colors.grey.shade700 : Colors.black87,
              fontWeight: isSubItem ? FontWeight.normal : FontWeight.w500,
            ),
          ),
          Text(
            amount,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
