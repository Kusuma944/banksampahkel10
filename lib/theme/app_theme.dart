import 'package:flutter/material.dart';

/// Palet warna & tema terpusat untuk EcoBank.
/// Tema hijau merepresentasikan lingkungan/daur ulang.
class AppTheme {
  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color lightGreen = Color(0xFFA5D6A7);
  static const Color backgroundColor = Color(0xFFF5F7F5);

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      primaryColor: primaryGreen,
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryGreen,
        primary: primaryGreen,
        secondary: lightGreen,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
