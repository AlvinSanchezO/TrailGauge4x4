import 'package:flutter/material.dart';

class AppTheme {
  // Paleta Dark Mode (Titanium & Sahara Gold)
  static const Color neutralBackground = Color(0xFF090A0C);
  static const Color secondarySurface = Color(0xFF14171C);
  static const Color primaryAccent = Color(0xFFC5A059);
  static const Color tertiaryAccent = Color(0xFF64748B);
  
  // Colores Sobrios de Estado
  static const Color safeState = primaryAccent;          // Estado normal
  static const Color warningState = Color(0xFFD97706); // Naranja ocre técnico
  static const Color dangerState = Color(0xFFB91C1C);  // Rojo carmesí técnico

  static ThemeData get tacticalTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: neutralBackground,
      cardColor: secondarySurface,
      primaryColor: primaryAccent,
      colorScheme: const ColorScheme.dark(
        primary: primaryAccent,
        secondary: dangerState,
        surface: secondarySurface,
        tertiary: tertiaryAccent,
        background: neutralBackground,
      ),
      fontFamily: 'Inter',
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 32, letterSpacing: -0.5),
        bodyLarge: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
        bodyMedium: TextStyle(color: tertiaryAccent, fontSize: 14),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: neutralBackground,
        foregroundColor: primaryAccent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 1.0),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: secondarySurface,
        selectedItemColor: primaryAccent,
        unselectedItemColor: tertiaryAccent,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
