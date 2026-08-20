import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';

/// Splash screen EcoBank — tampil 2 detik lalu pindah ke HomeScreen.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();

    // Fade-in logo/teks
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) setState(() => _opacity = 1.0);
    });

    // Pindah ke HomeScreen setelah 2 detik
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryGreen,
      body: Center(
        child: AnimatedOpacity(
          opacity: _opacity,
          duration: const Duration(milliseconds: 800),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.recycling_rounded, color: Colors.white, size: 96),
              SizedBox(height: 16),
              Text(
                'EcoBank',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Sampahmu, Tabunganmu',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
