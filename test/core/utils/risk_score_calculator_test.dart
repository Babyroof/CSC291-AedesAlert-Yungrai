import 'package:flutter_test/flutter_test.dart';
import 'package:aedes_alert_yungrai/core/utils/risk_score_calculator.dart';

void main() {
  // ─── _tempScore (via calculate with fixed h=40, r=0) ────────
  group('RiskScoreCalculator temperature factor', () {
    // h=40 → humidityScore=0, r=0 → rainfallScore=0
    // score = 0.4 * tempScore
    double scoreFromTemp(double t) =>
        RiskScoreCalculator.calculate(
          temperatureCelsius: t,
          humidityPercent: 40,
          rainfallMm: 0,
        );

    test('below 15 °C returns 0.0', () {
      expect(scoreFromTemp(10), 0.0);
      expect(scoreFromTemp(14.9), 0.0);
    });

    test('at 15 °C (lower bound) returns 0.0', () {
      expect(scoreFromTemp(15), 0.0);
    });

    test('at 20 °C returns 0.2 (midpoint of rising slope)', () {
      expect(scoreFromTemp(20), closeTo(0.2, 1e-9)); // 0.4 * 0.5
    });

    test('at 25 °C returns 0.4 (optimal low bound)', () {
      expect(scoreFromTemp(25), closeTo(0.4, 1e-9)); // 0.4 * 1.0
    });

    test('at 27.5 °C (mid-optimal) returns 0.4', () {
      expect(scoreFromTemp(27.5), closeTo(0.4, 1e-9));
    });

    test('at 30 °C returns 0.4 (optimal high bound)', () {
      expect(scoreFromTemp(30), closeTo(0.4, 1e-9));
    });

    test('at 35 °C returns 0.2 (midpoint of falling slope)', () {
      expect(scoreFromTemp(35), closeTo(0.2, 1e-9)); // 0.4 * 0.5
    });

    test('at 40 °C (upper bound) returns 0.0', () {
      expect(scoreFromTemp(40), closeTo(0.0, 1e-9));
    });

    test('above 40 °C returns 0.0', () {
      expect(scoreFromTemp(45), 0.0);
    });
  });

  // ─── _humidityScore (via calculate with t=15, r=0) ──────────
  group('RiskScoreCalculator humidity factor', () {
    // t=15 → tempScore=0, r=0 → rainfallScore=0
    // score = 0.3 * humidityScore
    double scoreFromHumidity(double h) =>
        RiskScoreCalculator.calculate(
          temperatureCelsius: 15,
          humidityPercent: h,
          rainfallMm: 0,
        );

    test('at 40 % (lower bound) returns 0.0', () {
      expect(scoreFromHumidity(40), 0.0);
    });

    test('below 40 % returns 0.0', () {
      expect(scoreFromHumidity(20), 0.0);
    });

    test('at 70 % (midpoint) returns 0.15', () {
      // humidityScore = (70-40)/60 = 0.5 → 0.3 * 0.5 = 0.15
      expect(scoreFromHumidity(70), closeTo(0.15, 1e-9));
    });

    test('at 100 % returns 0.3 (maximum humidity factor)', () {
      // humidityScore = (100-40)/60 = 1.0 → 0.3 * 1.0 = 0.3
      expect(scoreFromHumidity(100), closeTo(0.3, 1e-9));
    });

    test('above 100 % clamps to 0.3', () {
      expect(scoreFromHumidity(110), closeTo(0.3, 1e-9));
    });
  });

  // ─── _rainfallScore (via calculate with t=15, h=40) ─────────
  group('RiskScoreCalculator rainfall factor', () {
    // t=15 → tempScore=0, h=40 → humidityScore=0
    // score = 0.3 * rainfallScore
    double scoreFromRainfall(double r) =>
        RiskScoreCalculator.calculate(
          temperatureCelsius: 15,
          humidityPercent: 40,
          rainfallMm: r,
        );

    test('at 0 mm returns 0.0', () {
      expect(scoreFromRainfall(0), 0.0);
    });

    test('negative rainfall treated as 0.0', () {
      expect(scoreFromRainfall(-5), 0.0);
    });

    test('at 50 mm returns 0.15', () {
      // rainfallScore = 50/100 = 0.5 → 0.3 * 0.5 = 0.15
      expect(scoreFromRainfall(50), closeTo(0.15, 1e-9));
    });

    test('at 100 mm returns 0.3 (rainfall peak)', () {
      // rainfallScore = 1.0 → 0.3 * 1.0 = 0.3
      expect(scoreFromRainfall(100), closeTo(0.3, 1e-9));
    });

    test('at 175 mm returns 0.225 (heavy rain reduces larvae)', () {
      // rainfallScore = 1.0 - (75/150)*0.5 = 0.75 → 0.3 * 0.75 = 0.225
      expect(scoreFromRainfall(175), closeTo(0.225, 1e-9));
    });

    test('at 250 mm returns 0.15 (floor of heavy-rain zone)', () {
      // rainfallScore = 0.5 → 0.3 * 0.5 = 0.15
      expect(scoreFromRainfall(250), closeTo(0.15, 1e-9));
    });

    test('above 250 mm stays at 0.15', () {
      expect(scoreFromRainfall(300), closeTo(0.15, 1e-9));
    });
  });

  // ─── combined calculate ──────────────────────────────────────
  group('RiskScoreCalculator combined score', () {
    test('critical conditions → score ≥ 0.75', () {
      // t=28 → T=1.0, h=90 → H=0.833, r=100 → R=1.0
      // 0.4*1.0 + 0.3*0.833 + 0.3*1.0 = 0.4 + 0.25 + 0.3 = 0.95
      final score = RiskScoreCalculator.calculate(
        temperatureCelsius: 28,
        humidityPercent: 90,
        rainfallMm: 100,
      );
      expect(score, greaterThanOrEqualTo(0.75));
    });

    test('high-risk conditions → 0.50 ≤ score < 0.75', () {
      // t=27 → T=1.0, h=70 → H=0.5, r=80 → R=0.8
      // 0.4*1.0 + 0.3*0.5 + 0.3*0.8 = 0.4 + 0.15 + 0.24 = 0.79 — adjust to land in high
      // t=22 → T=0.7, h=65 → H=0.417, r=60 → R=0.6
      // 0.4*0.7 + 0.3*0.417 + 0.3*0.6 = 0.28 + 0.125 + 0.18 = 0.585
      final score = RiskScoreCalculator.calculate(
        temperatureCelsius: 22,
        humidityPercent: 65,
        rainfallMm: 60,
      );
      expect(score, greaterThanOrEqualTo(0.50));
      expect(score, lessThan(0.75));
    });

    test('medium-risk conditions → 0.25 ≤ score < 0.50', () {
      // t=18 → T=0.3, h=55 → H=0.25, r=30 → R=0.3
      // 0.4*0.3 + 0.3*0.25 + 0.3*0.3 = 0.12 + 0.075 + 0.09 = 0.285
      // Try t=20 → T=0.5, h=55 → H=0.25, r=40 → R=0.4
      // 0.4*0.5 + 0.3*0.25 + 0.3*0.4 = 0.2 + 0.075 + 0.12 = 0.395
      final score = RiskScoreCalculator.calculate(
        temperatureCelsius: 20,
        humidityPercent: 55,
        rainfallMm: 40,
      );
      expect(score, greaterThanOrEqualTo(0.25));
      expect(score, lessThan(0.50));
    });

    test('low-risk conditions → score < 0.25', () {
      // t=10 → T=0, h=30 → H=0, r=0 → R=0 → score=0
      final score = RiskScoreCalculator.calculate(
        temperatureCelsius: 10,
        humidityPercent: 30,
        rainfallMm: 0,
      );
      expect(score, lessThan(0.25));
    });

    test('score is clamped to 1.0 for extreme inputs', () {
      final score = RiskScoreCalculator.calculate(
        temperatureCelsius: 28,
        humidityPercent: 200,
        rainfallMm: 500,
      );
      expect(score, lessThanOrEqualTo(1.0));
    });

    test('score is clamped to 0.0 for zero inputs', () {
      final score = RiskScoreCalculator.calculate(
        temperatureCelsius: 0,
        humidityPercent: 0,
        rainfallMm: 0,
      );
      expect(score, 0.0);
    });
  });

  // ─── levelFromScore ──────────────────────────────────────────
  group('RiskScoreCalculator.levelFromScore', () {
    test('0.0 → low', () => expect(RiskScoreCalculator.levelFromScore(0.0), 'low'));
    test('0.24 → low', () => expect(RiskScoreCalculator.levelFromScore(0.24), 'low'));
    test('0.25 → medium', () => expect(RiskScoreCalculator.levelFromScore(0.25), 'medium'));
    test('0.49 → medium', () => expect(RiskScoreCalculator.levelFromScore(0.49), 'medium'));
    test('0.50 → high', () => expect(RiskScoreCalculator.levelFromScore(0.50), 'high'));
    test('0.74 → high', () => expect(RiskScoreCalculator.levelFromScore(0.74), 'high'));
    test('0.75 → critical', () => expect(RiskScoreCalculator.levelFromScore(0.75), 'critical'));
    test('1.0 → critical', () => expect(RiskScoreCalculator.levelFromScore(1.0), 'critical'));
  });
}
