import 'package:flutter/material.dart';

class AppTheme {
  static const Color lightCream = Color(0xFFCAD2C5);
  static const Color lightGreen = Color(0xFF84A98C);
  static const Color mediumGreen = Color(0xFF52796F);
  static const Color darkGreen = Color(0xFF354F52);
  static const Color darkestGreen = Color(0xFF2F3E46);

  // light mode section
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: mediumGreen,
        onPrimary: Colors.white,
        secondary: lightGreen,
        onSecondary: darkestGreen,
        tertiary: darkGreen,
        onTertiary: Colors.white,
        error: Colors.red,
        onError: Colors.white,
        background: lightCream,
        onBackground: darkestGreen,
        surface: lightCream,
        onSurface: darkestGreen,
      ),
      scaffoldBackgroundColor: lightCream,
      appBarTheme: const AppBarTheme(
        backgroundColor: mediumGreen,
        foregroundColor: Colors.white,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: lightCream,
        indicatorColor: lightGreen,
        labelTextStyle: MaterialStateProperty.all(
          const TextStyle(
              fontSize: 12, fontWeight: FontWeight.w500, color: darkestGreen),
        ),
        iconTheme: MaterialStateProperty.all(
          const IconThemeData(color: darkGreen),
        ),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: lightCream,
        indicatorColor: lightGreen,
        selectedIconTheme: const IconThemeData(color: darkGreen),
        unselectedIconTheme: IconThemeData(color: darkGreen.withOpacity(0.7)),
        selectedLabelTextStyle: const TextStyle(color: darkestGreen),
        unselectedLabelTextStyle:
            TextStyle(color: darkestGreen.withOpacity(0.7)),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: Colors.white,
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }

  // dark mode sction
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: lightGreen,
        onPrimary: darkestGreen,
        secondary: mediumGreen,
        onSecondary: Colors.white,
        tertiary: lightCream,
        onTertiary: darkestGreen,
        error: Colors.redAccent,
        onError: Colors.white,
        background: darkestGreen,
        onBackground: lightCream,
        surface: darkGreen,
        onSurface: lightCream,
      ),
      scaffoldBackgroundColor: darkestGreen,
      appBarTheme: const AppBarTheme(
        backgroundColor: darkGreen,
        foregroundColor: lightCream,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: darkGreen,
        indicatorColor: mediumGreen,
        labelTextStyle: MaterialStateProperty.all(
          const TextStyle(
              fontSize: 12, fontWeight: FontWeight.w500, color: lightCream),
        ),
        iconTheme: MaterialStateProperty.all(
          const IconThemeData(color: lightGreen),
        ),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: darkGreen,
        indicatorColor: mediumGreen,
        selectedIconTheme: const IconThemeData(color: lightGreen),
        unselectedIconTheme: IconThemeData(color: lightGreen.withOpacity(0.7)),
        selectedLabelTextStyle: const TextStyle(color: lightCream),
        unselectedLabelTextStyle: TextStyle(color: lightCream.withOpacity(0.7)),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: lightCream,
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }
}
