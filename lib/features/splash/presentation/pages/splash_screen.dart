import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../injection_container.dart' as di;
import '../../../../features/main_nav/presentation/pages/main_page.dart';
import '../../../../features/auth/presentation/pages/lock_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  void _navigateToNext() async {
    // Wait for animation to finish (at least 2.5 seconds)
    await Future.delayed(const Duration(milliseconds: 3000));
    
    if (!mounted) return;

    final box = di.sl<Box>(instanceName: 'settingsBox');
    final isBiometricEnabled = box.get('isBiometricEnabled', defaultValue: false);

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => isBiometricEnabled ? const LockScreen() : const MainPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212), // Deep premium dark background
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1E1E1E),
              Color(0xFF121212),
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo Animation
            Image.asset(
              'assets/logo.png',
              width: 120,
              height: 120,
            )
                .animate()
                .fadeIn(duration: 800.ms)
                .scale(
                  begin: const Offset(0.8, 0.8),
                  end: const Offset(1, 1),
                  curve: Curves.easeOutBack,
                  duration: 800.ms,
                )
                .shimmer(delay: 1.seconds, duration: 1500.ms, color: Colors.white24),
            
            const SizedBox(height: 24),
            
            // App Name Animation
            const Text(
              'budget',
              style: TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.bold,
                letterSpacing: 2.0,
                color: Colors.white,
                fontFamily: 'Inter',
              ),
            )
                .animate()
                .fadeIn(delay: 500.ms, duration: 800.ms)
                .slideY(
                  begin: 0.3,
                  end: 0,
                  curve: Curves.easeOutCubic,
                  duration: 800.ms,
                ),
                
            const SizedBox(height: 12),
            
            // Subtitle or Tagline (optional, but adds to premium feel)
            Text(
              'Simple • Smart • Secure',
              style: TextStyle(
                fontSize: 14,
                letterSpacing: 1.2,
                color: Colors.white.withOpacity(0.5),
                fontFamily: 'Inter',
              ),
            )
                .animate()
                .fadeIn(delay: 1000.ms, duration: 800.ms),
          ],
        ),
      ),
    );
  }
}
