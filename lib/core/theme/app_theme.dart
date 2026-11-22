import 'package:material_ui/material_ui.dart';

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
    return _buildTheme(
      brightness: Brightness.dark,
      background: AppColors.background,
      surface: AppColors.surface,
      surfaceLight: AppColors.surfaceLight,
      text: AppColors.textPrimary,
      secondaryText: AppColors.textSecondary,
    );
  }

  static ThemeData get lightTheme {
    return _buildTheme(
      brightness: Brightness.light,
      background: const Color(0xFFF5F7FA),
      surface: Colors.white,
      surfaceLight: const Color(0xFFEDF1F5),
      text: const Color(0xFF17202A),
      secondaryText: const Color(0xFF687482),
    );
  }

  static ThemeData _buildTheme({
    required Brightness brightness,
    required Color background,
    required Color surface,
    required Color surfaceLight,
    required Color text,
    required Color secondaryText,
  }) {
    final isDark = brightness == Brightness.dark;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: background,

      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: brightness,
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: surface,
        error: AppColors.expense,
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: text,
        elevation: 0,
        centerTitle: false,
      ),

      cardColor: surface,

      dividerColor: isDark ? AppColors.border : const Color(0xFFE1E6EC),

      textTheme: ThemeData(brightness: brightness).textTheme
          .apply(bodyColor: text, displayColor: text),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceLight,
        hintStyle: TextStyle(color: secondaryText),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: AppColors.primary.withValues(alpha: 0.15),
        labelTextStyle: WidgetStateProperty.all(
          TextStyle(fontSize: 11, color: text),
        ),
      ),
    );
  }
}
