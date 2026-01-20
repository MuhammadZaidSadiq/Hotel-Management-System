import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '/models/service.dart';
import '/models/enum.dart';

class ServiceOrderingScreen extends StatefulWidget {
  final String bookingId;

  const ServiceOrderingScreen({super.key, required this.bookingId});

  @override
  State<ServiceOrderingScreen> createState() => _ServiceOrderingScreenState();
}

class _ServiceOrderingScreenState extends State<ServiceOrderingScreen> {
  final Color _primaryColor = const Color(0xFF1a472a);
  final Color _accentColor = const Color(0xFF2d6a4f);
  final Color _backgroundColor = const Color(0xFFFBFAF7);
  final Color _cardColor = Colors.white;

  bool _isLoading = true;
  List<Service> _availableServices = [];
  Map<ServiceType, List<Service>> _groupedServices = {};

  ServiceType? _selectedCategory;
  Service? _selectedService;
  int _currentQuantity = 1;
  final Map<String, int> _confirmedOrderQuantities = {};

  // Utility function to format price as PKR (with cents)
  String _formatPKR(double amount) {
    return 'PKR ${amount.toStringAsFixed(2)}';
  }

  @override
  void initState() {
    super.initState();
    _fetchServices();
  }

  Future<void> _fetchServices() async {
    try {
      final supabase = Supabase.instance.client;

      final response = await supabase
          .from('services')
          .select('id, service_name, description, service_type, price')
          .order('service_name', ascending: true);

      final List<Service> services = (response as List).map((data) {
        final mappedData = {
          'id': data['id'],
          'service_name': data['service_name'],
          'description': data['description'],
          'service_type': data['service_type'],
          'price': data['price'],
        };
        return Service.fromMap(mappedData);
      }).toList();

      if (mounted) {
        setState(() {
          _availableServices = services;
          _groupServicesByCategory(services);
          if (_groupedServices.keys.isNotEmpty) {
            _selectedCategory = _groupedServices.keys.first;
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching services: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _groupServicesByCategory(List<Service> services) {
    _groupedServices = {};
    for (var type in ServiceType.values) {
      _groupedServices[type] = services.where((s) => s.type == type).toList();
    }
    _groupedServices.removeWhere((key, list) => list.isEmpty);
  }

  void _addServiceToOrder() {
    if (_selectedService == null || _currentQuantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a service and quantity.')),
      );
      return;
    }

    setState(() {
      _confirmedOrderQuantities[_selectedService!.id] = _currentQuantity;
      _currentQuantity = 1;
      _selectedService = null;
    });
  }

  void _removeServiceFromOrder(String serviceId) {
    setState(() {
      _confirmedOrderQuantities.remove(serviceId);
    });
  }

  double get _subtotal {
    double total = 0.0;
    _confirmedOrderQuantities.forEach((serviceId, quantity) {
      final service = _availableServices.firstWhere((s) => s.id == serviceId);
      total += service.price * quantity;
    });
    return total;
  }

  Future<void> _submitOrder() async {
    if (_confirmedOrderQuantities.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Order list is empty.')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final supabase = Supabase.instance.client;
      final List<Map<String, dynamic>> servicesToInsert = [];

      for (var entry in _confirmedOrderQuantities.entries) {
        final serviceId = entry.key;
        final quantity = entry.value;
        final service = _availableServices.firstWhere((s) => s.id == serviceId);

        servicesToInsert.add({
          'booking_id': widget.bookingId,
          'service_id': serviceId,
          'quantity': quantity,
          'price_at_time': service.price,
        });
      }

      await supabase.from('booking_services').insert(servicesToInsert);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            // CHANGED: Use PKR format in success message
            content: Text('Order submitted! Total: ${_formatPKR(_subtotal)}'),
            backgroundColor: _primaryColor,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to submit order: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildThemedDropdown<T>({
    required String hint,
    T? value,
    required List<DropdownMenuItem<T>> items,
    required Function(T?) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _accentColor.withOpacity(0.15), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: _primaryColor.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonFormField<T>(
        initialValue: value,
        items: items,
        onChanged: onChanged,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 16,
          ),
          hintText: hint,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: _primaryColor, width: 2),
          ),
        ),
        style: TextStyle(
          color: _primaryColor,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
        dropdownColor: _cardColor,
        icon: Icon(Icons.expand_more, color: _accentColor, size: 24),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Service> servicesForCategory = _selectedCategory != null
        ? _groupedServices[_selectedCategory!] ?? []
        : [];

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: _backgroundColor,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _cardColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8),
            ],
          ),
          child: IconButton(
            icon: Icon(Icons.arrow_back, color: _primaryColor),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: Text(
          'Room Services',
          style: TextStyle(
            color: _primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
            letterSpacing: 0.3,
          ),
        ),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: _primaryColor,
                strokeWidth: 2.5,
              ),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Add Services",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _primaryColor,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Browse and add services to your order",
                        style: TextStyle(
                          fontSize: 13,
                          color: _accentColor.withOpacity(0.6),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 18),
                      _buildThemedDropdown<ServiceType>(
                        hint: 'Select Category',
                        value: _selectedCategory,
                        items: ServiceType.values
                            .where((type) => _groupedServices.containsKey(type))
                            .map(
                              (type) => DropdownMenuItem(
                                value: type,
                                child: Text(type.name.toUpperCase()),
                              ),
                            )
                            .toList(),
                        onChanged: (ServiceType? newValue) {
                          setState(() {
                            _selectedCategory = newValue;
                            _selectedService = null;
                          });
                        },
                      ),
                      const SizedBox(height: 14),
                      _buildThemedDropdown<Service>(
                        hint: 'Select Specific Service',
                        value: _selectedService,
                        items: servicesForCategory
                            .map(
                              (service) => DropdownMenuItem(
                                value: service,
                                child: Text(
                                  // CHANGED: Use PKR format in dropdown
                                  '${service.name} (${_formatPKR(service.price)})',
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (Service? newValue) {
                          setState(() {
                            _selectedService = newValue;
                          });
                        },
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: _primaryColor.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: _primaryColor.withOpacity(0.15),
                              ),
                            ),
                            child: Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    if (_currentQuantity > 1) {
                                      setState(() => _currentQuantity--);
                                    }
                                  },
                                  child: Icon(
                                    Icons.remove,
                                    color: _primaryColor,
                                    size: 20,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 18,
                                  ),
                                  child: Text(
                                    _currentQuantity.toString(),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: _primaryColor,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    setState(() => _currentQuantity++);
                                  },
                                  child: Icon(
                                    Icons.add,
                                    color: _primaryColor,
                                    size: 20,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed:
                                  _selectedService != null &&
                                      _currentQuantity > 0
                                  ? _addServiceToOrder
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _primaryColor,
                                disabledBackgroundColor: Colors.grey.shade300,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                elevation: 3,
                                shadowColor: _primaryColor.withOpacity(0.3),
                              ),
                              child: const Text(
                                'Add to Order',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                Divider(
                  height: 28,
                  color: _accentColor.withOpacity(0.1),
                  thickness: 1.5,
                ),

                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      Text(
                        "Order Summary",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _primaryColor,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 14),
                      if (_confirmedOrderQuantities.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 32),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.shopping_bag_outlined,
                                  size: 48,
                                  color: _accentColor.withOpacity(0.3),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  "No items added yet.",
                                  style: TextStyle(
                                    color: _accentColor.withOpacity(0.5),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        ..._confirmedOrderQuantities.entries.map((entry) {
                          final serviceId = entry.key;
                          final quantity = entry.value;
                          final service = _availableServices.firstWhere(
                            (s) => s.id == serviceId,
                          );
                          return _buildOrderItem(service, quantity);
                        }),
                    ],
                  ),
                ),

                _buildOrderFooter(),
              ],
            ),
    );
  }

  Widget _buildOrderItem(Service service, int quantity) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _accentColor.withOpacity(0.1), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: _primaryColor.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$quantity x ${service.name}',
                  style: TextStyle(
                    color: _primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  // CHANGED: Use PKR format
                  '${_formatPKR(service.price)} each',
                  style: TextStyle(
                    color: _accentColor.withOpacity(0.6),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Text(
            // CHANGED: Use PKR format
            _formatPKR(service.price * quantity),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: _primaryColor,
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, size: 20, color: Colors.red.shade400),
            onPressed: () => _removeServiceFromOrder(service.id),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderFooter() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardColor,
        border: Border(
          top: BorderSide(color: _accentColor.withOpacity(0.1), width: 1.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Subtotal',
                style: TextStyle(
                  fontSize: 14,
                  color: _accentColor.withOpacity(0.7),
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                // CHANGED: Use PKR format
                _formatPKR(_subtotal),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: _confirmedOrderQuantities.isNotEmpty && !_isLoading
                  ? _submitOrder
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryColor,
                disabledBackgroundColor: Colors.grey.shade300,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 4,
                shadowColor: _primaryColor.withOpacity(0.3),
              ),
              child: const Text(
                'Confirm & Place Order',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
