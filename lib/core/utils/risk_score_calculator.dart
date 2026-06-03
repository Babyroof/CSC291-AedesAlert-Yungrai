/// Dengue risk score calculator based on WHO environmental thresholds.
///
/// WHO reference: "Dengue: Guidelines for Diagnosis, Treatment, Prevention
/// and Control" (2009) and WHO vector surveillance guidelines.
///
/// Inputs  : temperature (°C), relative humidity (%), rainfall (mm/day)
/// Output  : risk score 0.0–1.0, mapped to 'low' / 'medium' / 'high' / 'critical'
abstract class RiskScoreCalculator {
  /// Calculates a composite risk score in the range [0.0, 1.0].
  ///
  /// Weights (WHO-derived):
  ///   temperature 40 % · humidity 30 % · rainfall 30 %
  static double calculate({
    required double temperatureCelsius,
    required double humidityPercent,
    required double rainfallMm,
  }) {
    final t = _tempScore(temperatureCelsius);
    final h = _humidityScore(humidityPercent);
    final r = _rainfallScore(rainfallMm);
    return (0.4 * t + 0.3 * h + 0.3 * r).clamp(0.0, 1.0);
  }

  /// Maps a 0.0–1.0 score to a risk level label.
  ///
  ///   < 0.25  → 'low'
  ///   < 0.50  → 'medium'
  ///   < 0.75  → 'high'
  ///   ≥ 0.75  → 'critical'
  static String levelFromScore(double score) {
    if (score < 0.25) return 'low';
    if (score < 0.50) return 'medium';
    if (score < 0.75) return 'high';
    return 'critical';
  }

  // ─── private sub-scores ───────────────────────────────────────

  /// WHO: Aedes aegypti thrives at 25–30 °C.
  /// Inactive below 15 °C or above 40 °C.
  ///
  ///   t < 15        → 0.0
  ///   15 ≤ t < 25   → linear 0.0 → 1.0
  ///   25 ≤ t ≤ 30   → 1.0  (optimal)
  ///   30 < t ≤ 40   → linear 1.0 → 0.0
  ///   t > 40        → 0.0
  static double _tempScore(double t) {
    if (t < 15 || t > 40) return 0.0;
    if (t >= 25 && t <= 30) return 1.0;
    if (t < 25) return (t - 15) / 10.0;
    return (40.0 - t) / 10.0;
  }

  /// WHO: Relative humidity ≥ 60 % is critical for adult mosquito survival.
  ///
  ///   h ≤ 40        → 0.0
  ///   40 < h ≤ 100  → linear 0.0 → 1.0
  static double _humidityScore(double h) {
    if (h <= 40) return 0.0;
    return ((h - 40) / 60.0).clamp(0.0, 1.0);
  }

  /// WHO: Moderate rainfall creates breeding sites; heavy rain flushes larvae.
  ///
  ///   r ≤ 0          → 0.0
  ///   0 < r ≤ 100    → linear 0.0 → 1.0
  ///   100 < r ≤ 250  → linear 1.0 → 0.5  (heavy rain reduces larvae)
  ///   r > 250        → 0.5
  static double _rainfallScore(double r) {
    if (r <= 0) return 0.0;
    if (r <= 100) return r / 100.0;
    if (r <= 250) return 1.0 - ((r - 100) / 150.0) * 0.5;
    return 0.5;
  }
}
