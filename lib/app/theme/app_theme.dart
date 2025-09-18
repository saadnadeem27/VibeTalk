import 'package:flutter/material.dart';

class VibeTalkColors {
  // Primary Brand Colors
  static const Color primaryColor = Color(0xFF7C4DFF);
  static const Color primaryVariant = Color(0xFF5722CD);
  static const Color secondaryColor = Color(0xFF03DAC6);
  static const Color secondaryVariant = Color(0xFF018786);

  // Background Colors
  static const Color background = Color(0xFF121212);
  static const Color surface = Color(0xFF1E1E1E);
  static const Color cardColor = Color(0xFF2D2D2D);

  // Message Colors
  static const Color sentMessageColor = Color(0xFF7C4DFF);
  static const Color receivedMessageColor = Color(0xFF2D2D2D);
  static const Color messageTimeColor = Color(0xFF9E9E9E);

  // Text Colors
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onSecondary = Color(0xFF000000);
  static const Color onBackground = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB3B3B3);
  static const Color textHint = Color(0xFF666666);

  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFFF5252);
  static const Color online = Color(0xFF4CAF50);
  static const Color offline = Color(0xFF757575);

  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryColor, primaryVariant],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFF1A1A1A), Color(0xFF0D0D0D)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

class VibeTalkTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primarySwatch: const MaterialColor(0xFF7C4DFF, {
        50: Color(0xFFEDE7FF),
        100: Color(0xFFD1C4FF),
        200: Color(0xFFB39DFF),
        300: Color(0xFF9575FF),
        400: Color(0xFF7E57FF),
        500: VibeTalkColors.primaryColor,
        600: Color(0xFF7044FF),
        700: Color(0xFF6139FF),
        800: Color(0xFF512DFF),
        900: Color(0xFF311B92),
      }),
      primaryColor: VibeTalkColors.primaryColor,
      scaffoldBackgroundColor: VibeTalkColors.background,
      cardColor: VibeTalkColors.cardColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: VibeTalkColors.surface,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: VibeTalkColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(
          color: VibeTalkColors.textPrimary,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: VibeTalkColors.primaryColor,
          foregroundColor: VibeTalkColors.onPrimary,
          elevation: 8,
          shadowColor: VibeTalkColors.primaryColor.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: VibeTalkColors.textPrimary,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        displayMedium: TextStyle(
          color: VibeTalkColors.textPrimary,
          fontSize: 28,
          fontWeight: FontWeight.w600,
        ),
        displaySmall: TextStyle(
          color: VibeTalkColors.textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.w500,
        ),
        headlineLarge: TextStyle(
          color: VibeTalkColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        headlineMedium: TextStyle(
          color: VibeTalkColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: TextStyle(
          color: VibeTalkColors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.normal,
        ),
        bodyMedium: TextStyle(
          color: VibeTalkColors.textSecondary,
          fontSize: 14,
          fontWeight: FontWeight.normal,
        ),
        bodySmall: TextStyle(
          color: VibeTalkColors.textHint,
          fontSize: 12,
          fontWeight: FontWeight.normal,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: VibeTalkColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: const BorderSide(
            color: VibeTalkColors.primaryColor,
            width: 2,
          ),
        ),
        hintStyle: const TextStyle(
          color: VibeTalkColors.textHint,
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: VibeTalkColors.surface,
        selectedItemColor: VibeTalkColors.primaryColor,
        unselectedItemColor: VibeTalkColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 10,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: VibeTalkColors.primaryColor,
        foregroundColor: VibeTalkColors.onPrimary,
        elevation: 8,
        shape: CircleBorder(),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: VibeTalkColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        titleTextStyle: const TextStyle(
          color: VibeTalkColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        contentTextStyle: const TextStyle(
          color: VibeTalkColors.textSecondary,
          fontSize: 16,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: VibeTalkColors.surface,
        selectedColor: VibeTalkColors.primaryColor,
        disabledColor: VibeTalkColors.textHint,
        labelStyle: const TextStyle(color: VibeTalkColors.textPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}

// Animation Constants
class VibeTalkAnimations {
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration medium = Duration(milliseconds: 400);
  static const Duration slow = Duration(milliseconds: 600);

  static const Curve easeInOut = Curves.easeInOut;
  static const Curve bounceIn = Curves.bounceIn;
  static const Curve elasticOut = Curves.elasticOut;
}

// Spacing Constants
class VibeTalkSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 40.0;
}

// Border Radius Constants
class VibeTalkRadius {
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double circular = 50.0;
}
