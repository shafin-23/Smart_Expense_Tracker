
import 'package:flutter/material.dart';

class AppColors {
  static const background = Color(0xFF0B0F14);
  static const surface = Color(0xFF151B23);
  static const surfaceLight = Color(0xFF1D2631);

  static const primary = Color(0xFF19C37D);
  static const secondary = Color(0xFF39DFA0);

  static const income = Color(0xFF19C37D);
  static const expense = Color(0xFFFF647C);

  static const textPrimary = Color(0xFFF5F7FA);
  static const textSecondary = Color(0xFF929BA8);
  static const border = Color(0xFF29323D);
}

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,

      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surface,
        error: AppColors.expense,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: false,
      ),

      cardColor: AppColors.surface,

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceLight,
        hintStyle: const TextStyle(
          color: AppColors.textSecondary,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primary.withValues(alpha: 0.15),
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(fontSize: 11),
        ),
      ),
    );
  }
}
