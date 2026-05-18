import 'package:flutter_test/flutter_test.dart';
import 'package:aedes_alert_yungrai/core/utils/risk_level_utils.dart';
import 'package:aedes_alert_yungrai/core/themes/app_colors.dart';

void main() {
  group('RiskLevelUtils.colorForLevel', () {
    test('critical returns riskCritical', () {
      expect(RiskLevelUtils.colorForLevel('critical'), AppColors.riskCritical);
    });

    test('high returns riskHigh', () {
      expect(RiskLevelUtils.colorForLevel('high'), AppColors.riskHigh);
    });

    test('medium returns riskMedium', () {
      expect(RiskLevelUtils.colorForLevel('medium'), AppColors.riskMedium);
    });

    test('low returns riskLow', () {
      expect(RiskLevelUtils.colorForLevel('low'), AppColors.riskLow);
    });

    test('unknown level defaults to riskLow', () {
      expect(RiskLevelUtils.colorForLevel('unknown'), AppColors.riskLow);
    });
  });

  group('RiskLevelUtils.bgColorForLevel', () {
    test('critical returns riskCriticalBg', () {
      expect(RiskLevelUtils.bgColorForLevel('critical'), AppColors.riskCriticalBg);
    });

    test('high returns riskHighBg', () {
      expect(RiskLevelUtils.bgColorForLevel('high'), AppColors.riskHighBg);
    });

    test('unknown defaults to riskLowBg', () {
      expect(RiskLevelUtils.bgColorForLevel('anything'), AppColors.riskLowBg);
    });
  });

  group('RiskLevelUtils.severityIndex', () {
    test('critical → 3', () => expect(RiskLevelUtils.severityIndex('critical'), 3));
    test('high → 2', () => expect(RiskLevelUtils.severityIndex('high'), 2));
    test('medium → 1', () => expect(RiskLevelUtils.severityIndex('medium'), 1));
    test('low → 0', () => expect(RiskLevelUtils.severityIndex('low'), 0));
    test('unknown → 0', () => expect(RiskLevelUtils.severityIndex('unknown'), 0));
  });
}
