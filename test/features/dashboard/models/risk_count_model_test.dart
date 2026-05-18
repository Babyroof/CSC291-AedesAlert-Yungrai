import 'package:flutter_test/flutter_test.dart';
import 'package:aedes_alert_yungrai/features/dashboard/models/risk_count_model.dart';

void main() {
  group('RiskCountModel', () {
    test('totalCount sums all counts', () {
      const model = RiskCountModel(
        criticalCount: 2,
        highCount: 3,
        mediumCount: 5,
        lowCount: 10,
      );
      expect(model.totalCount, 20);
    });

    test('all zeros — totalCount is 0 without crash', () {
      const model = RiskCountModel(
        criticalCount: 0,
        highCount: 0,
        mediumCount: 0,
        lowCount: 0,
      );
      expect(model.totalCount, 0);
    });

    test('single critical — counts are correct', () {
      const model = RiskCountModel(
        criticalCount: 1,
        highCount: 0,
        mediumCount: 0,
        lowCount: 0,
      );
      expect(model.criticalCount, 1);
      expect(model.totalCount, 1);
    });
  });
}
