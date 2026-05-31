import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Brand / Primary (dark navy from Yungrai design)
  static const Color primary = Color(0xFF1B2B6B);
  static const Color primaryLight = Color(0xFF3949AB);
  static const Color primaryDark = Color(0xFF0D1B4A);

  // Background & Surface
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFF5F7FA);
  static const Color cardBackground = Color(0xFFFFFFFF);

  // Risk Levels
  static const Color riskCritical = Color(0xFFD32F2F);
  static const Color riskHigh = Color(0xFFF57C00);
  static const Color riskMedium = Color(0xFFFFC107);
  static const Color riskLow = Color(0xFF4CAF50);

  // Risk Level Backgrounds (light tints)
  static const Color riskCriticalBg = Color(0xFFFFEBEE);
  static const Color riskHighBg = Color(0xFFFFF3E0);
  static const Color riskMediumBg = Color(0xFFFFFDE7);
  static const Color riskLowBg = Color(0xFFE8F5E9);

  // Text
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // UI Elements
  static const Color divider = Color(0xFFEEEEEE);
  static const Color border = Color(0xFFE0E0E0);
  static const Color shadow = Color(0x1A000000);

  // Navigation
  static const Color navActive = primary;
  static const Color navInactive = Color(0xFF9E9E9E);
  static const Color navSelectedBg = Color(0xFFDEE4F5);

  // Status / Semantic
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFD32F2F);
  static const Color info = Color(0xFF2196F3);

  // Quick Service buttons (from Home screen design)
  static const Color serviceReportRisk = Color(0xFFD32F2F);
  static const Color serviceHospital = primary;
  static const Color serviceChecklist = Color(0xFF00897B);
  static const Color serviceNews = Color(0xFF37474F);
}
