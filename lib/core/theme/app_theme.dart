import 'package:flutter/material.dart';

class AppTheme {
  // Dark Theme Colors
  static const Color darkGreen = Color(0xFF0A1F1A);
  static const Color neonGreen = Color(0xFF00FF88);
  static const Color lightGreen = Color(0xFF1A3A2F);
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textGray = Color(0xFFB0B0B0);
  static const Color cardDark = Color(0xFF162A22);
  
  // Light Theme Colors - GenZ inspired
  static const Color primaryPurple = Color(0xFF6C5CE7);
  static const Color secondaryPink = Color(0xFFFF6B9D);
  static const Color accentYellow = Color(0xFFFECA57);
  static const Color lightBackground = Color(0xFFF8F9FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color darkText = Color(0xFF2D3436);
  static const Color grayText = Color(0xFF636E72);
  
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primaryPurple,
      scaffoldBackgroundColor: lightBackground,
      
      colorScheme: const ColorScheme.light(
        primary: primaryPurple,
        secondary: secondaryPink,
        tertiary: accentYellow,
        surface: lightSurface,
        background: lightBackground,
        error: Color(0xFFEE5A6F),
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: darkText,
        onBackground: darkText,
      ),

      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: lightBackground,
        foregroundColor: darkText,
        titleTextStyle: TextStyle(
          color: darkText,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: darkText),
      ),

      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: lightSurface,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryPurple,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryPurple,
        foregroundColor: Colors.white,
        elevation: 4,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryPurple, width: 2),
        ),
      ),

      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: darkText,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: darkText,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: darkText,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: grayText,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: grayText,
        ),
      ),
    );
  }
  
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: neonGreen,
      scaffoldBackgroundColor: darkGreen,
      colorScheme: const ColorScheme.dark(
        primary: neonGreen,
        secondary: neonGreen,
        surface: cardDark,
        background: darkGreen,
      ),
      
      // AppBar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: darkGreen,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: textWhite,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: textWhite),
      ),
      
      // Text Theme
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textWhite,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: textWhite,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: textWhite,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textWhite,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textWhite,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: textWhite,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: textGray,
        ),
        labelLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: darkGreen,
        ),
      ),
      
      // Card Theme
      cardTheme: CardThemeData(
        color: cardDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      
      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: neonGreen,
          foregroundColor: darkGreen,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        hintStyle: const TextStyle(color: textGray),
      ),
      
      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: cardDark,
        selectedItemColor: neonGreen,
        unselectedItemColor: textGray,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );
  }
  
  // Custom Gradients
  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF2D5A4A),
      Color(0xFF8B6B47),
    ],
  );
  
  // Border Radius
  static BorderRadius cardRadius = BorderRadius.circular(20);
  static BorderRadius buttonRadius = BorderRadius.circular(30);
  
  // Spacing
  static const double spacingXS = 4;
  static const double spacingS = 8;
  static const double spacingM = 16;
  static const double spacingL = 24;
  static const double spacingXL = 32;
}
