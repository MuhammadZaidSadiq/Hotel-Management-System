import 'package:flutter/material.dart';

class DevInfoScreen extends StatelessWidget {
  const DevInfoScreen({super.key});

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
          'About Developers',
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
            const Text(
              'The Team',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1a472a),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Meet the talented students behind this project.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 30),

            _buildDevCard(
              name: 'Muhammad Zaid',
              role: 'Hotel Reservation App',
              description: 'Designed the Hotel Reservation App.',
              initials: 'MZ',
            ),
            const SizedBox(height: 16),
            _buildDevCard(
              name: 'Abdullah Naeem',
              role: 'Hotel Reservation App',
              description: 'Designed the Hotel Reservation App.',
              initials: 'AN',
            ),
            const SizedBox(height: 16),
            _buildDevCard(
              name: 'Ahmed Hassan',
              role: 'Hotel Reservation App Manager',
              description: 'Designed the Admin App.',
              initials: 'AH',
            ),

            const SizedBox(height: 40),

            Center(
              child: Text(
                "University Project 2025",
                style: TextStyle(
                  color: Colors.grey.shade400,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDevCard({
    required String name,
    required String role,
    required String description,
    required String initials,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1a472a).withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: const Color(0xFF1a472a).withOpacity(0.1),
            child: Text(
              initials,
              style: const TextStyle(
                color: Color(0xFF1a472a),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C2C2C),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  role,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFD4A574), // Gold accent for role
                  ),
                ),
                const SizedBox(height: 8),
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
}
