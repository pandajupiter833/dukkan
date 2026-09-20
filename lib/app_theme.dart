import 'package:flutter/material.dart';

class AppColors {
  static const pomegranate = Color(0xFFB92535);
  static const berry = Color(0xFF7E1E31);
  static const coral = Color(0xFFE96B5F);
  static const leaf = Color(0xFF2F7D5A);
  static const ink = Color(0xFF1F2933);
  static const muted = Color(0xFF6B7280);
  static const cream = Color(0xFFFFFBF7);
  static const mist = Color(0xFFF4F6F8);
}

class AppTheme {
  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.pomegranate,
      primary: AppColors.pomegranate,
      secondary: AppColors.leaf,
      surface: Colors.white,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.mist,
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.ink,
        titleTextStyle: TextStyle(
          color: AppColors.ink,
          fontSize: 22,
          fontWeight: FontWeight.w800,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white,
        surfaceTintColor: Colors.white,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: Colors.black.withValues(alpha: 0.06)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.08)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.08)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.pomegranate, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.pomegranate,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.pomegranate,
          side: const BorderSide(color: AppColors.pomegranate),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.pomegranate,
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.pomegranate.withValues(alpha: 0.08),
        selectedColor: AppColors.pomegranate.withValues(alpha: 0.16),
        labelStyle: const TextStyle(
          color: AppColors.berry,
          fontWeight: FontWeight.w700,
        ),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.pomegranate,
        unselectedItemColor: AppColors.muted,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.w800),
        type: BottomNavigationBarType.fixed,
        elevation: 12,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

BoxDecoration softPanelDecoration({Color color = Colors.white}) {
  return BoxDecoration(
    color: color,
    borderRadius: BorderRadius.circular(8),
    border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.05),
        blurRadius: 18,
        offset: const Offset(0, 8),
      ),
    ],
  );
}
