import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'TierDetailScreen.dart';
import 'EditPersonalInformationScreen.dart';
import 'HowItWorksScreen.dart';
import 'DevInfocreen.dart';
import '/LandingPage.dart';
import 'ChatScreen.dart'; // Import the user's Chat Screen

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  // State variables for dynamic data
  String _tier = "Member";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAccountData();
  }

  // Fetch user details from Supabase
  Future<void> _fetchAccountData() async {
    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id;

      if (userId == null) return;

      // Removed 'bonus_points' from the query
      final data = await supabase
          .from('clients')
          .select('full_name, current_tier')
          .eq('id', userId)
          .single();

      if (mounted) {
        setState(() {
          _tier = data['current_tier'] ?? "Member";
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching account data: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _settingsTile(
    IconData icon,
    String title, {
    bool destructive = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: destructive ? Colors.red.shade50 : const Color(0xFFF9F8F5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: destructive ? Colors.red.shade200 : Colors.grey.shade200,
          ),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 4,
          ),
          leading: Icon(
            icon,
            color: destructive ? Colors.red.shade700 : const Color(0xFF1a472a),
            size: 20,
          ),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: destructive
                  ? Colors.red.shade700
                  : const Color(0xFF2C2C2C),
            ),
          ),
          trailing: Icon(
            Icons.arrow_forward_ios,
            size: 14,
            color: destructive ? Colors.red.shade400 : Colors.grey.shade400,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFAF7),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFFFBFAF7),
        elevation: 0,
        title: const Text(
          'Account Settings',
          style: TextStyle(
            color: Color(0xFF1a472a),
            fontWeight: FontWeight.w600,
            fontSize: 22,
            letterSpacing: 0.3,
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(
              Icons.person_outline,
              color: Color(0xFF1a472a),
              size: 26,
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF1a472a)),
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TierDetailsScreen(),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF1a472a).withOpacity(0.06),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                          border: Border.all(color: Colors.grey.shade100),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF4E6),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFFD4A574),
                                  width: 1.5,
                                ),
                              ),
                              child: const Icon(
                                Icons.emoji_events_outlined,
                                color: Color(0xFFB8860B),
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Your Level",
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Text(
                                      _tier, // Dynamic Tier
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF1a472a),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(
                                      Icons.chevron_right,
                                      size: 18,
                                      color: Colors.grey.shade400,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: SizedBox(
                      height: 270,
                      width: 270,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            height: 250,
                            width: 250,
                            child: Transform.rotate(
                              angle: 3.14,
                              child: CircularProgressIndicator(
                                value: 0.5,
                                backgroundColor: Colors.grey.shade200,
                                valueColor: const AlwaysStoppedAnimation(
                                  Color(0xFFD4A574),
                                ),
                                strokeWidth: 6,
                              ),
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.nightlight_round,
                                size: 48,
                                color: Color(0xFFB8860B),
                              ),
                              const SizedBox(height: 14),
                              Text(
                                "Book a stay to\nbegin earning nights!",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  height: 1.5,
                                  color: Colors.grey.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 18),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const HowItWorksScreen(),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1a472a),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 32,
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  elevation: 0,
                                ),
                                child: const Text(
                                  "How it Works",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Removed the independent Change Personal Details box
                  const SizedBox(height: 20),
                  // Removed Points Balance Section
                  Divider(color: Colors.grey.shade200, height: 1, thickness: 1),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Column(
                      children: [
                        // CHANGED: Notifications -> Chat, Linked to ChatScreen
                        _settingsTile(
                          Icons.chat_bubble_outline,
                          "Chat",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ChatScreen(),
                              ),
                            );
                          },
                        ),
                        // REPLACED: Privacy & Security -> Change Personal Information
                        _settingsTile(
                          Icons.person_outline,
                          "Change Personal Information",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const EditPersonalInformationScreen(),
                              ),
                            ).then(
                              (_) => _fetchAccountData(),
                            ); // Refresh on return
                          },
                        ),
                        _settingsTile(
                          Icons.info_outline,
                          "Info about devs",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const DevInfoScreen(),
                              ),
                            );
                          },
                        ),
                        _settingsTile(
                          Icons.logout,
                          "Logout",
                          destructive: true,
                          onTap: () async {
                            await Supabase.instance.client.auth.signOut();
                            if (context.mounted) {
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const BonvoyLandingPage(),
                                ),
                                (route) => false,
                              );
                            }
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
}
