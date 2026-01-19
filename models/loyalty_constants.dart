import 'package:flutter/material.dart';
import 'loyalty_enums.dart';

// --- TIER RULES (For Display and Logic) ---
const Map<ClientTier, Map<String, dynamic>> TIER_RULES = {
  ClientTier.MEMBER: {
    'name': 'Member',
    'nightsRequired': 0,
    'pointsMultiplier': '1.00x',
    'gradient': [Color(0xFFCE5F24), Color(0xFF883C15)],
  },
  ClientTier.SILVER_ELITE: {
    'name': 'Silver Elite',
    'nightsRequired': 10,
    'pointsMultiplier': '1.10x',
    'gradient': [Color(0xFF6A85B6), Color(0xFF425672)],
  },
  ClientTier.GOLD_ELITE: {
    'name': 'Gold Elite',
    'nightsRequired': 25,
    'pointsMultiplier': '1.25x',
    'gradient': [Color(0xFFE8C872), Color(0xFFCC9900)],
  },
  ClientTier.PLATINUM_ELITE: {
    'name': 'Platinum Elite',
    'nightsRequired': 50,
    'pointsMultiplier': '1.50x',
    'gradient': [Color(0xFF5A4A7D), Color(0xFF3B2B5D)],
  },
  ClientTier.TITANIUM_ELITE: {
    'name': 'Titanium Elite',
    'nightsRequired': 75,
    'pointsMultiplier': '1.65x',
    'gradient': [Color(0xFF4A4A4A), Color(0xFF2A2A2A)],
  },
  ClientTier.AMBASSADOR_ELITE: {
    'name': 'Ambassador Elite',
    'nightsRequired': 100,
    'pointsMultiplier': '1.75x',
    'gradient': [Color(0xFF900000), Color(0xFF600000)],
  },
};

// --- CONSOLIDATED FEATURE LIST ---
// Maps feature name to its required unlock tier and icon.
const Map<String, Map<String, dynamic>> ALL_FEATURES = {
  'Complimentary Wi-Fi': {'icon': Icons.wifi, 'unlocks': ClientTier.MEMBER},
  'Quick Service': {
    'icon': Icons.fast_forward_outlined,
    'unlocks': ClientTier.MEMBER,
  },

  '10% Bonus': {
    'icon': Icons.star_half_outlined,
    'unlocks': ClientTier.SILVER_ELITE,
  },
  'Exclusive Rates': {
    'icon': Icons.attach_money,
    'unlocks': ClientTier.SILVER_ELITE,
  },

  '25% Bonus': {
    'icon': Icons.star_half_outlined,
    'unlocks': ClientTier.GOLD_ELITE,
  },
  'Welcome Gift': {
    'icon': Icons.card_giftcard,
    'unlocks': ClientTier.GOLD_ELITE,
  },
  'Premium Service': {
    'icon': Icons.workspace_premium_outlined,
    'unlocks': ClientTier.GOLD_ELITE,
  },

  '50% Bonus': {'icon': Icons.star, 'unlocks': ClientTier.PLATINUM_ELITE},
  'Elite Support': {
    'icon': Icons.headset_mic_outlined,
    'unlocks': ClientTier.PLATINUM_ELITE,
  },
  'Lounge Access': {
    'icon': Icons.chair_outlined,
    'unlocks': ClientTier.PLATINUM_ELITE,
  },

  '65% Bonus': {
    'icon': Icons.star_rate_outlined,
    'unlocks': ClientTier.TITANIUM_ELITE,
  },
  'Room Guarantee': {
    'icon': Icons.check_box_outlined,
    'unlocks': ClientTier.TITANIUM_ELITE,
  },
  'SINT STATUS': {
    'icon': Icons.car_rental_outlined,
    'unlocks': ClientTier.TITANIUM_ELITE,
  },

  '75% Bonus': {
    'icon': Icons.star_border_purple500_outlined,
    'unlocks': ClientTier.AMBASSADOR_ELITE,
  },
  'Personal Ambassador': {
    'icon': Icons.accessibility_new_outlined,
    'unlocks': ClientTier.AMBASSADOR_ELITE,
  },
};
