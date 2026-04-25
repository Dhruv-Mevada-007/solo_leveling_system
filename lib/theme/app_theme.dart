import 'package:flutter/material.dart';

class AppColors {
  // Core backgrounds
  static const Color bgDeep = Color(0xFF05050F);
  static const Color bgPrimary = Color(0xFF0A0A1A);
  static const Color bgSecondary = Color(0xFF0D0D1F);
  static const Color bgCard = Color(0xFF10102A);
  static const Color bgElevated = Color(0xFF141428);

  // Borders & dividers
  static const Color border = Color(0xFF1A1A3E);
  static const Color borderGlow = Color(0xFF2A2A5E);

  // Brand blues (system portal color)
  static const Color systemBlue = Color(0xFF4A9EFF);
  static const Color systemBlueDim = Color(0xFF1E40AF);
  static const Color systemBlueGlow = Color(0x334A9EFF);

  // Rank colors
  static const Color rankS = Color(0xFFFFD700);   // S - Gold
  static const Color rankA = Color(0xFFA855F7);   // A - Purple
  static const Color rankB = Color(0xFF4A9EFF);   // B - Blue
  static const Color rankC = Color(0xFF22C55E);   // C - Green
  static const Color rankD = Color(0xFFEF4444);   // D - Red
  static const Color rankE = Color(0xFF888888);   // E - Gray

  // Quest rarity
  static const Color rarityLegendary = Color(0xFFFFD700);
  static const Color rarityEpic = Color(0xFFA855F7);
  static const Color rarityRare = Color(0xFF4A9EFF);
  static const Color rarityCommon = Color(0xFF22C55E);
  static const Color rarityPenalty = Color(0xFFEF4444);

  // XP & Stats
  static const Color xpColor = Color(0xFF4A9EFF);
  static const Color healthColor = Color(0xFFEF4444);
  static const Color manaColor = Color(0xFF8B5CF6);
  static const Color strengthColor = Color(0xFFF97316);
  static const Color agilityColor = Color(0xFF22C55E);
  static const Color intelligenceColor = Color(0xFF06B6D4);

  // Text
  static const Color textPrimary = Color(0xFFE8E8FF);
  static const Color textSecondary = Color(0xFFAAAAAA);
  static const Color textMuted = Color(0xFF5A5A8A);
  static const Color textGlow = Color(0xFF7AB8FF);

  // Status
  static const Color success = Color(0xFF22C55E);
  static const Color danger = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
}

class AppTextStyles {
  static const TextStyle systemLabel = TextStyle(
    fontSize: 11,
    letterSpacing: 3,
    color: AppColors.systemBlue,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle heading1 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: 0.5,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    letterSpacing: 0.3,
  );

  static const TextStyle body = TextStyle(
    fontSize: 14,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 11,
    color: AppColors.textMuted,
    letterSpacing: 0.5,
  );

  static const TextStyle xpLabel = TextStyle(
    fontSize: 12,
    color: AppColors.xpColor,
    fontWeight: FontWeight.w500,
    letterSpacing: 1,
  );

  static const TextStyle rankBadge = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    letterSpacing: 2,
  );
}

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.bgDeep,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.systemBlue,
        secondary: AppColors.rankA,
        surface: AppColors.bgSecondary,
        error: AppColors.danger,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.bgDeep,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTextStyles.heading2,
        iconTheme: IconThemeData(color: AppColors.systemBlue),
      ),
      cardTheme: CardThemeData(
        color: AppColors.bgCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.bgSecondary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.systemBlue, width: 1.5),
        ),
        labelStyle: const TextStyle(color: AppColors.textMuted),
        hintStyle: const TextStyle(color: AppColors.textMuted),
        prefixIconColor: AppColors.textMuted,
        suffixIconColor: AppColors.textMuted,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.systemBlueDim,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(color: AppColors.systemBlue, width: 1),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: 1,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.systemBlue,
        ),
      ),
      iconTheme: const IconThemeData(color: AppColors.textMuted),
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.bgDeep,
        selectedItemColor: AppColors.systemBlue,
        unselectedItemColor: AppColors.textMuted,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}
