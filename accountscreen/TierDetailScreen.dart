import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// CORRECTED IMPORTS: Assuming loyalty files are in a 'models/' folder
import '/models/loyalty_enums.dart';
import '/models/loyalty_constants.dart';
import 'LoyaltyFeatureDetailScreen.dart';

class TierDetailsScreen extends StatefulWidget {
  const TierDetailsScreen({super.key});

  @override
  State<TierDetailsScreen> createState() => _TierDetailsScreenState();
}

class _TierDetailsScreenState extends State<TierDetailsScreen> {
  late int _currentPage;
  late PageController _pageController;
  ClientTier _userCurrentTier = ClientTier.MEMBER; // Default to Member
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _currentPage = 0;
    _pageController = PageController(initialPage: 0);
    _fetchUserTier();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserTier() async {
    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id;

      if (userId == null) return;

      final data = await supabase
          .from('clients')
          .select('current_tier')
          .eq('id', userId)
          .single();

      if (data['current_tier'] != null) {
        final tierString = data['current_tier'] as String;

        // FIX: Match string from DB to Enum with normalization
        // Handles "Silver Elite" (DB) vs "SILVER_ELITE" (Enum)
        final fetchedTier = ClientTier.values.firstWhere((e) {
          final enumName = e.name.toUpperCase().replaceAll('_', ' ');
          final dbName = tierString.toUpperCase().replaceAll('_', ' ');
          return enumName == dbName;
        }, orElse: () => ClientTier.MEMBER);

        if (mounted) {
          setState(() {
            _userCurrentTier = fetchedTier;
            _currentPage = ClientTier.values.indexOf(fetchedTier);
            _isLoading = false;
          });
          // Jump to the correct page once data is loaded
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_pageController.hasClients) {
              _pageController.jumpToPage(_currentPage);
            }
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching tier: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onDotTapped(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator(color: Colors.black)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Loyalty Tiers',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: TIER_RULES.length,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                if (index < 0 || index >= TIER_RULES.keys.length) {
                  return const Center(child: Text('Error loading tier data.'));
                }
                final viewedTier = TIER_RULES.keys.elementAt(index);
                return _TierPageContent(
                  key: ValueKey(viewedTier),
                  viewedTier: viewedTier,
                  userCurrentTier: _userCurrentTier, // Pass fetched tier
                );
              },
            ),
          ),
          _buildDotsIndicator(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildDotsIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(TIER_RULES.length, (index) {
        return GestureDetector(
          onTap: () => _onDotTapped(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.symmetric(horizontal: 4.0),
            height: 8.0,
            width: 8.0,
            decoration: BoxDecoration(
              color: _currentPage == index
                  ? Colors.black
                  : Colors.grey.shade300,
              shape: BoxShape.circle,
            ),
          ),
        );
      }),
    );
  }
}

class _TierPageContent extends StatefulWidget {
  final ClientTier viewedTier;
  final ClientTier userCurrentTier;

  const _TierPageContent({
    super.key,
    required this.viewedTier,
    required this.userCurrentTier,
  });

  @override
  State<_TierPageContent> createState() => _TierPageContentState();
}

class _TierPageContentState extends State<_TierPageContent> {
  double _contentOpacity = 0.0;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          _contentOpacity = 1.0;
        });
      }
    });
  }

  bool _isUnlocked(ClientTier featureTier, ClientTier viewedTier) {
    return featureTier.index <= viewedTier.index;
  }

  static const List<String> _bonusFeatures = [
    '10% Bonus',
    '25% Bonus',
    '50% Bonus',
    '65% Bonus',
    '75% Bonus',
  ];

  @override
  Widget build(BuildContext context) {
    final viewedTier = widget.viewedTier;
    final tierData = TIER_RULES[viewedTier]!;
    final List<Color> gradientColors = tierData['gradient'];

    // Determine if the user has unlocked THIS SPECIFIC tier being viewed
    final bool isUnlockedByClient =
        widget.userCurrentTier.index >= viewedTier.index;

    final List<MapEntry<String, Map<String, dynamic>>> unlockedFeatures =
        ALL_FEATURES.entries
            .where(
              (entry) =>
                  _isUnlocked(entry.value['unlocks'] as ClientTier, viewedTier),
            )
            .toList();

    // Filter to exclude bonus features completely
    final List<MapEntry<String, Map<String, dynamic>>> featuresToDisplay =
        unlockedFeatures.where((entry) {
          // If the feature is in the bonus list, exclude it
          return !_bonusFeatures.contains(entry.key);
        }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: gradientColors.first.withOpacity(0.5),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      tierData['name'] as String,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(
                      isUnlockedByClient
                          ? Icons.check_circle_outline
                          : Icons.lock_outline,
                      color: Colors.white,
                      size: 28,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  tierData['nightsRequired'] == 0
                      ? 'Welcome to the club!'
                      : 'Stay ${tierData['nightsRequired']} nights to unlock',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 15,
                  ),
                ),
                // Removed the Bonus text widget here
              ],
            ),
          ),

          const SizedBox(height: 20),

          // White Card
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(20),
            child: AnimatedOpacity(
              opacity: _contentOpacity,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeIn,
              child: GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                crossAxisSpacing: 10,
                mainAxisSpacing: 15,
                children: featuresToDisplay.map((entry) {
                  final featureName = entry.key;
                  final featureData = entry.value;

                  // Determine if this specific FEATURE is unlocked for the user
                  // It is unlocked if the user's tier is >= the tier required for the feature
                  final featureUnlockTier =
                      featureData['unlocks'] as ClientTier;
                  final bool isFeatureUnlocked =
                      widget.userCurrentTier.index >= featureUnlockTier.index;

                  return GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) {
                          return LoyaltyFeatureDetailScreen(
                            featureName: featureName,
                            icon: featureData['icon'] as IconData,
                            color: Colors.deepOrange,
                          );
                        },
                      );
                    },
                    child: _buildFeatureTile(
                      icon: featureData['icon'] as IconData,
                      label: featureName,
                      isUnlocked:
                          isFeatureUnlocked, // Color based on user status
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureTile({
    required IconData icon,
    required String label,
    required bool isUnlocked,
  }) {
    final color = isUnlocked ? Colors.deepOrange : Colors.grey.shade400;

    return Column(
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: color.withOpacity(0.7), width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.18),
                offset: const Offset(3, 4),
                blurRadius: 8,
                spreadRadius: 1,
              ),
              BoxShadow(
                color: Colors.white.withOpacity(0.9),
                offset: const Offset(-3, -3),
                blurRadius: 6,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Icon(icon, color: color, size: 30),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12, color: Colors.black),
        ),
      ],
    );
  }
}
