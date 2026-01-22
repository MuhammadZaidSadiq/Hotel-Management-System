import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'loginandsignup/LoginScreen.dart';
import 'loginandsignup/RegistrationScreen.dart';
import 'home.dart';
import 'LandingPage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://stiohhvkrooiveygsytw.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InN0aW9oaHZrcm9vaXZleWdzeXR3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjUyNzg1ODAsImV4cCI6MjA4MDg1NDU4MH0.tn40o-MFfURykalwS0eRSg_KFT7w9pO6fS4PYQx_RdQ',
  );

  runApp(const HotelApp());
}

class HotelApp extends StatelessWidget {
  const HotelApp({super.key});

  @override
  Widget build(BuildContext context) {  
    return MaterialApp(
      title: 'Hotel Booking UI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1a472a), // Deep forest green
          brightness: Brightness.light,
          primary: const Color(0xFF1a472a),
          secondary: const Color(0xFFd4af37), // Luxe gold accent
        ),
        fontFamily: 'Inter',
        scaffoldBackgroundColor: const Color(
          0xFFFBFAF7,
        ), // Warm cream background
        // Global Bottom Navigation Theme
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF1a472a),
          unselectedItemColor: Colors.grey.shade400,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
            color: Color(0xFF1a472a),
          ),
          unselectedLabelStyle: TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 11,
            color: Colors.grey.shade500,
          ),
          type: BottomNavigationBarType.fixed,
          elevation: 12.0,
        ),

        // Global Elevated Button Theme
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1a472a),
            foregroundColor: Colors.white,
            elevation: 4,
            shadowColor: const Color(0xFF1a472a).withOpacity(0.3),
          ),
        ),

        // Global Input Decoration Theme
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[50],
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF1a472a)),
          ),
          hintStyle: TextStyle(color: Colors.grey[400]),
        ),
      ),

      // --- ROUTE DEFINITIONS ---
      // Check for existing session to decide initial route
      home: const AuthGate(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegistrationScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}

// Widget to handle initial auth state redirection
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final session = Supabase.instance.client.auth.currentSession;
    if (session != null) {
      return const HomeScreen();
    } else {
      return const BonvoyLandingPage();
    }
  }
}
