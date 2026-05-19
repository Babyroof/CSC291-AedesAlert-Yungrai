import 'package:flutter_test/flutter_test.dart';
import 'package:aedes_alert_yungrai/core/utils/date_formatter.dart';

void main() {
  group('DateFormatter.toMonthKey', () {
    test('formats single-digit month with leading zero', () {
      expect(DateFormatter.toMonthKey(DateTime(2024, 3, 15)), '2024-03');
    });

    test('formats double-digit month correctly', () {
      expect(DateFormatter.toMonthKey(DateTime(2024, 11, 1)), '2024-11');
    });

    test('January is 01', () {
      expect(DateFormatter.toMonthKey(DateTime(2025, 1, 1)), '2025-01');
    });
  });

  group('DateFormatter.monthAbbreviation', () {
    test('month 1 returns Jan', () {
      expect(DateFormatter.monthAbbreviation(1), 'Jan');
    });

    test('month 12 returns Dec', () {
      expect(DateFormatter.monthAbbreviation(12), 'Dec');
    });

    test('clamps out-of-range low to Jan', () {
      expect(DateFormatter.monthAbbreviation(0), 'Jan');
    });

    test('clamps out-of-range high to Dec', () {
      expect(DateFormatter.monthAbbreviation(13), 'Dec');
    });
  });

  group('DateFormatter.toDisplayDate', () {
    test('formats date as D Mon YYYY', () {
      expect(DateFormatter.toDisplayDate(DateTime(2024, 6, 5)), '5 Jun 2024');
    });

    test('formats single-digit day without padding', () {
      expect(DateFormatter.toDisplayDate(DateTime(2025, 1, 9)), '9 Jan 2025');
    });
  });
}
