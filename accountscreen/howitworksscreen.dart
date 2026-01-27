import 'package:flutter/material.dart';

class HowItWorksScreen extends StatelessWidget {
  const HowItWorksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFAF7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFBFAF7),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1a472a)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'How it Works',
          style: TextStyle(
            color: Color(0xFF1a472a),
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Section
            const Text(
              'Earning Nights & Tiers',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1a472a),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Unlock exclusive benefits as you stay more with us.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 30),

            // Step 1: Book
            _buildStepCard(
              icon: Icons.calendar_month_outlined,
              title: '1. Book Your Stay',
              description:
                  'Every night you book directly through our app counts towards your elite status.',
            ),
            const SizedBox(height: 16),

            // Step 2: Stay
            _buildStepCard(
              icon: Icons.night_shelter_outlined,
              title: '2. Complete Your Stay',
              description:
                  'Once you complete your stay, the nights are automatically added to your account balance.',
            ),
            const SizedBox(height: 16),

            // Step 3: Earn
            _buildStepCard(
              icon: Icons.star_border,
              title: '3. Level Up',
              description:
                  'Reach specific milestones (10, 25, 50+ nights) to unlock new membership tiers and premium perks.',
            ),
            const SizedBox(height: 30),

            // Example Tiers Section
            const Text(
              'Membership Tiers',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1a472a),
              ),
            ),
            const SizedBox(height: 16),
            _buildTierExample(
              'Member',
              '0-9 nights',
              'Free Wi-Fi, Member Rates',
            ),
            _buildTierExample(
              'Silver Elite',
              '10-24 nights',
              '10% Bonus Points, Late Checkout',
            ),
            _buildTierExample(
              'Gold Elite',
              '25-49 nights',
              '25% Bonus Points, Room Upgrades',
            ),
            _buildTierExample(
              'Platinum Elite',
              '50+ nights',
              '50% Bonus Points, Lounge Access',
            ),

            const SizedBox(height: 40),
            Center(
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1a472a),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  "Got it",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStepCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1a472a).withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF4E6),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFFB8860B), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C2C2C),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTierExample(String tier, String nights, String benefits) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: const Color(0xFF1a472a), size: 18),
          const SizedBox(width: 10),
          Text(
            tier,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C2C2C),
            ),
          ),
          const Spacer(),
          Text(
            nights,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
