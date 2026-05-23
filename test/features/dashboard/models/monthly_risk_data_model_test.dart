import 'package:flutter_test/flutter_test.dart';
import 'package:aedes_alert_yungrai/features/dashboard/domain/entities/monthly_risk_data_model.dart';

void main() {
  group('MonthlyRiskDataModel.fromBucket', () {
    test('computes average correctly', () {
      final model = MonthlyRiskDataModel.fromBucket('2024-06', [60.0, 80.0]);
      expect(model.avgRiskScore, 70.0);
      expect(model.areaCount, 2);
      expect(model.monthKey, '2024-06');
      expect(model.monthLabel, 'Jun');
    });

    test('empty scores list returns avgRiskScore 0.0 without crash', () {
      final model = MonthlyRiskDataModel.fromBucket('2024-01', []);
      expect(model.avgRiskScore, 0.0);
      expect(model.areaCount, 0);
    });

    test('single score is the average', () {
      final model = MonthlyRiskDataModel.fromBucket('2024-12', [45.0]);
      expect(model.avgRiskScore, 45.0);
      expect(model.monthLabel, 'Dec');
    });

    test('month label is correct for January', () {
      final model = MonthlyRiskDataModel.fromBucket('2025-01', [50.0]);
      expect(model.monthLabel, 'Jan');
    });
  });
}
