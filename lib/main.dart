import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const EcoBankApp());
}

class EcoBankApp extends StatelessWidget {
  const EcoBankApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EcoBank',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const SplashScreen(),
    );
  }
}
