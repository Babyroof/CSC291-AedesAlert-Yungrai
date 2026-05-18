import 'package:flutter/material.dart';

/// Centralized color constants for the Yungrai app
/// All colors referenced from the design and used throughout the app
class AppColors {
  AppColors._(); // Private constructor to prevent instantiation

  // Primary Colors
  static const Color primary = Color(0xFF00235B); // Dark blue - main brand color
  static const Color primaryLight = Color(0xFF1E3A8A); // Lighter blue for accents
  static const Color secondary = Color(0xFFEF4444); // Red for warnings/high risk

  // Text Colors
  static const Color textPrimary = Color(0xFF1F2937); // Dark grey for main text
  static const Color textSecondary = Color(0xFF6B7280); // Medium grey for secondary text
  static const Color textHint = Color(0xFF9CA3AF); // Light grey for hints
  static const Color textOnPrimary = Color(0xFFFFFFFF); // White text on primary

  // Neutral Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey = Color(0xFF6B7280); // Medium grey for secondary text
  static const Color lightGrey = Color(0xFFF3F4F6); // Light grey for backgrounds
  static const Color darkGrey = Color(0xFF374151); // Dark grey for primary text

  // Risk Level Colors
  static const Color lowRisk = Color(0xFF10B981); // Green
  static const Color mediumRisk = Color(0xFFFCD34D); // Yellow
  static const Color highRisk = Color(0xFFF97316); // Orange
  static const Color criticalRisk = Color(0xFFEF4444); // Red

  // Background Colors
  static const Color background = Color(0xFFF9FAFB);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF3F4F6);

  // Card & Border Colors
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE5E7EB);
  static const Color divider = Color(0xFFE5E7EB);
  static const Color shadow = Color(0x1A000000); // 10% black

  // Navigation Colors
  static const Color navActive = Color(0xFF00235B);
  static const Color navInactive = Color(0xFF9CA3AF);

  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFFCD34D);
  static const Color info = Color(0xFF3B82F6);

  // Transparent Colors
  static const Color transparent = Color(0x00000000);
  static const Color scrim = Color(0x4D000000); // Semi-transparent black overlay
}
