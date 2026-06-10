import 'package:flutter/material.dart';

class AppTheme {
  // Paleta Técnica Light Mode (Wireframes)
  static const Color background = Color(0xFFF8F9FA); // Fondo gris muy claro
  static const Color surface = Colors.white;         // Fondo de las tarjetas
  static const Color primaryNavy = Color(0xFF0F172A); // Azul marino súper oscuro (Casi negro) para textos y NavBar
  static const Color borderGray = Color(0xFFCBD5E1);  // Gris sutil para bordes de las tarjetas
  
  // Colores Sobrios de Estado
  static const Color safeState = primaryNavy;          // En estado seguro, usamos el color industrial
  static const Color warningState = Color(0xFFD97706); // Naranja ocre técnico
  static const Color dangerState = Color(0xFFB91C1C);  // Rojo carmesí técnico

  static ThemeData get tacticalTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: background,
      primaryColor: primaryNavy,
      colorScheme: const ColorScheme.light(
        primary: primaryNavy,
        secondary: dangerState,
        surface: surface,
      ),
      fontFamily: 'Roboto', // Familia base, forzaremos estilos geométricos en los TextStyles
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: primaryNavy, fontWeight: FontWeight.w900, fontSize: 32, letterSpacing: -0.5),
        bodyLarge: TextStyle(color: primaryNavy, fontSize: 18, fontWeight: FontWeight.w600),
        bodyMedium: TextStyle(color: primaryNavy, fontSize: 14),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        foregroundColor: primaryNavy,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(color: primaryNavy, fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 1.0),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: primaryNavy,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
