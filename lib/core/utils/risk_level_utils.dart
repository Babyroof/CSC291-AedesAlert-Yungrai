import 'package:flutter/material.dart';
import 'package:aedes_alert_yungrai/core/themes/app_colors.dart';

abstract class RiskLevelUtils {
  static Color colorForLevel(String level) {
    switch (level) {
      case 'critical':
        return AppColors.riskCritical;
      case 'high':
        return AppColors.riskHigh;
      case 'medium':
        return AppColors.riskMedium;
      case 'low':
      default:
        return AppColors.riskLow;
    }
  }

  static Color bgColorForLevel(String level) {
    switch (level) {
      case 'critical':
        return AppColors.riskCriticalBg;
      case 'high':
        return AppColors.riskHighBg;
      case 'medium':
        return AppColors.riskMediumBg;
      case 'low':
      default:
        return AppColors.riskLowBg;
    }
  }

  static int severityIndex(String level) {
    switch (level) {
      case 'critical':
        return 3;
      case 'high':
        return 2;
      case 'medium':
        return 1;
      case 'low':
      default:
        return 0;
    }
  }
}
