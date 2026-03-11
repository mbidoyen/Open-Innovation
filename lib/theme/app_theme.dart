import 'package:flutter/material.dart';

class AppColors {
  // Primary gradient
  static const Color primary = Color(0xFF7C3AED);
  static const Color primaryEnd = Color(0xFF4F46E5);

  // Backgrounds
  static const Color background = Color(0xFFFFFFFF);
  static const Color surfaceBackground = Color(0xFFF9FAFB);
  static const Color card = Color(0xFFFFFFFF);

  // Text
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textMuted = Color(0xFF9CA3AF);

  // Border
  static const Color border = Color(0xFFF3F4F6);
  static const Color borderMedium = Color(0xFFE5E7EB);

  // Semantic
  static const Color error = Color(0xFFD4183D);
  static const Color errorBg = Color(0xFFFEF2F2);
  static const Color errorBorder = Color(0xFFFECACA);
  static const Color success = Color(0xFF16A34A);
  static const Color successBg = Color(0xFFF0FDF4);
  static const Color successBorder = Color(0xFFBBF7D0);

  // Primary light
  static const Color primaryBg = Color(0xFFF5F3FF);
  static const Color primaryBorder = Color(0xFFEDE9FE);

  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF7C3AED), Color(0xFF4F46E5)],
  );

  // Avatar colors (5 cycliques)
  static const List<Map<String, Color>> avatarColors = [
    {
      'bg': Color(0xFFF3E8FF),
      'text': Color(0xFF9333EA),
      'border': Color(0xFFE9D5FF),
    },
    {
      'bg': Color(0xFFDBEAFE),
      'text': Color(0xFF2563EB),
      'border': Color(0xFFBFDBFE),
    },
    {
      'bg': Color(0xFFDCFCE7),
      'text': Color(0xFF16A34A),
      'border': Color(0xFFBBF7D0),
    },
    {
      'bg': Color(0xFFFFEDD5),
      'text': Color(0xFFEA580C),
      'border': Color(0xFFFED7AA),
    },
    {
      'bg': Color(0xFFFCE7F3),
      'text': Color(0xFFDB2777),
      'border': Color(0xFFFBCFE8),
    },
  ];

  static Map<String, Color> getAvatarColor(int index) {
    return avatarColors[index % avatarColors.length];
  }
}

class AppTheme {
  static ThemeData get theme {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        surface: AppColors.background,
      ),
      scaffoldBackgroundColor: AppColors.surfaceBackground,
      useMaterial3: true,
      fontFamily: 'Roboto',
      textTheme: const TextTheme(
        bodyMedium: TextStyle(fontSize: 16, color: AppColors.textPrimary),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.background,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textMuted,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );
  }
}

// Reusable widget helpers
class AppShadow {
  static List<BoxShadow> get card => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.06),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get elevated => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.08),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];
}
