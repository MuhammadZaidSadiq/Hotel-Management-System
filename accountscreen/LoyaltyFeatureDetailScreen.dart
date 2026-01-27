import 'package:flutter/material.dart';

class LoyaltyFeatureDetailScreen extends StatefulWidget {
  final String featureName;
  final IconData icon;
  final Color color;

  const LoyaltyFeatureDetailScreen({
    super.key,
    required this.featureName,
    required this.icon,
    required this.color,
  });

  @override
  State<LoyaltyFeatureDetailScreen> createState() =>
      _LoyaltyFeatureDetailScreenState();
}

class _LoyaltyFeatureDetailScreenState extends State<LoyaltyFeatureDetailScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Map<String, Map<String, dynamic>> _getFeatureDetails() {
    return {
      'Complimentary Wi-Fi': {
        'description': 'Stay connected during your visit',
        'details':
            'High-speed internet access across all hotel properties. Perfect for business travelers and leisure guests who want to stay connected with family and friends.',
      },
      'Quick Service': {
        'description': 'Expedited service at your fingertips',
        'details':
            'Skip the lines and enjoy express check-in/check-out, priority concierge service, and fast-tracked requests. Your time is valuable.',
      },

      'Exclusive Rates': {
        'description': 'Access exclusive member pricing',
        'details':
            'Enjoy special member-only rates on room bookings that are not available to the general public. Save more with every reservation.',
      },

      'Welcome Gift': {
        'description': 'Complimentary welcome amenities',
        'details':
            'Receive a curated welcome gift upon arrival at your favorite property. From welcome beverages to luxury amenities, we appreciate your loyalty.',
      },
      'Premium Service': {
        'description': 'Elevated service experience',
        'details':
            'Enjoy enhanced room service, priority restaurant reservations, and dedicated staff attention. Experience hospitality at its finest.',
      },

      'Elite Support': {
        'description': 'Dedicated elite support line',
        'details':
            'Access a dedicated support team available 24/7 for any assistance. Premium support for our most valued members.',
      },
      'Lounge Access': {
        'description': 'Access exclusive lounges',
        'details':
            'Enjoy complimentary access to premium lounges with refreshments, comfortable seating, and business facilities. Relax in style.',
      },

      'Room Guarantee': {
        'description': 'Guaranteed room availability',
        'details':
            'We guarantee room availability for your reservations. Never worry about your booking being cancelled due to overbooking.',
      },
      'SINT STATUS': {
        'description': 'Premium rental car status',
        'details':
            'Complimentary elite status with our preferred car rental partners. Enjoy premium treatment at every rental location.',
      },

      'Personal Ambassador': {
        'description': 'Dedicated personal ambassador',
        'details':
            'A dedicated personal travel concierge who knows your preferences and handles all your requests. VIP treatment for VIP members.',
      },
    };
  }

  void _closeBottomSheet() async {
    await _animationController.reverse();
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final details = _getFeatureDetails()[widget.featureName] ?? {};
    final description = details['description'] ?? '';
    final detailText = details['details'] ?? '';

    return SlideTransition(
      position: _slideAnimation,
      child: GestureDetector(
        onVerticalDragEnd: (details) {
          if (details.primaryVelocity! > 0) {
            _closeBottomSheet();
          }
        },
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.5,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              widget.featureName,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: _closeBottomSheet,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.black,
                                size: 24,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Column(
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: widget.color.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  widget.icon,
                                  color: widget.color,
                                  size: 40,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                description,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'About this benefit',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          detailText,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                            height: 1.6,
                          ),
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
