import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aedes_alert_yungrai/core/constants/app_constants.dart';
import 'package:aedes_alert_yungrai/core/utils/risk_score_calculator.dart';

class _CurrentWeather {
  const _CurrentWeather({
    required this.temperatureCelsius,
    required this.humidityPercent,
    required this.rainMm,
  });

  final double temperatureCelsius;
  final double humidityPercent;
  final double rainMm;
}

/// Fetches current weather for every area and creates a new daily document
/// in the `areas` collection (instead of overwriting the existing one).
///
/// Each document has [isLatest] = true; the previous day's document is set
/// to false so map + home screen always see current data.
///
/// Throttled to once per 24 hours in-memory (resets on app restart).
class RiskUpdateService {
  RiskUpdateService({required FirebaseFirestore firestore, required Dio dio})
    : _firestore = firestore,
      _dio = dio;

  final FirebaseFirestore _firestore;
  final Dio _dio;

  static DateTime? _lastRunAt;
  static const _minInterval = Duration(hours: 1);

  bool get _shouldRun =>
      _lastRunAt == null ||
      DateTime.now().difference(_lastRunAt!) >= _minInterval;

  Future<void> updateAllAreas() async {
    if (!_shouldRun) {
      debugPrint(
        '[RiskUpdate] skipped — last run '
        '${DateTime.now().difference(_lastRunAt!).inHours}h ago',
      );
      return;
    }

    debugPrint('[RiskUpdate] starting...');
    _lastRunAt = DateTime.now();

    try {
      // Read from original seed documents (no isLatest filter — these are the
      // authoritative location/district records written by seed_data.dart)
      final seedSnapshot = await _firestore
          .collection(AppConstants.areasCollection)
          .where('isLatest', isEqualTo: true)
          .get();

      // Fallback: if no isLatest docs yet (fresh DB), read all seed docs
      final sourceDocs = seedSnapshot.docs.isNotEmpty
          ? seedSnapshot.docs
          : (await _firestore.collection(AppConstants.areasCollection).get())
                .docs;

      final batch = _firestore.batch();

      for (final doc in sourceDocs) {
        final data = doc.data();
        final location = data['location'] as GeoPoint;

        final weather = await _fetchCurrentWeather(
          location.latitude,
          location.longitude,
        );
        if (weather == null) continue;

        final score = RiskScoreCalculator.calculate(
          temperatureCelsius: weather.temperatureCelsius,
          humidityPercent: weather.humidityPercent,
          rainfallMm: weather.rainMm,
        );
        final level = RiskScoreCalculator.levelFromScore(score);

        // 1. Set previous isLatest document to false
        final oldDocs = await _firestore
            .collection(AppConstants.areasCollection)
            .where('district', isEqualTo: data['district'])
            .where('isLatest', isEqualTo: true)
            .get();
        for (final old in oldDocs.docs) {
          batch.update(old.reference, {'isLatest': false});
        }

        // 2. Create new daily document in areas
        batch.set(_firestore.collection(AppConstants.areasCollection).doc(), {
          'district': data['district'],
          'province': data['province'],
          'location': location,
          'riskScore': score * 100,
          'riskLevel': level,
          'temperature': weather.temperatureCelsius,
          'humidity': weather.humidityPercent,
          'rain': weather.rainMm,
          'isLatest': true,
          'reportedAt': Timestamp.now(),
        });
      }

      await batch.commit();
      debugPrint('[RiskUpdate] done — ${sourceDocs.length} areas');
    } catch (e) {
      debugPrint('[RiskUpdate] error: $e');
    }
  }

  Future<_CurrentWeather?> _fetchCurrentWeather(double lat, double lng) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/forecast',
        queryParameters: {
          'latitude': lat,
          'longitude': lng,
          'current': 'temperature_2m,relative_humidity_2m,rain',
          'timezone': 'Asia/Bangkok',
        },
      );
      final current = response.data?['current'] as Map<String, dynamic>?;
      if (current == null) return null;

      return _CurrentWeather(
        temperatureCelsius: (current['temperature_2m'] as num).toDouble(),
        humidityPercent: (current['relative_humidity_2m'] as num).toDouble(),
        rainMm: (current['rain'] as num).toDouble(),
      );
    } catch (e) {
      debugPrint('[RiskUpdate] weather failed ($lat,$lng): $e');
      return null;
    }
  }
}

final riskUpdateServiceProvider = Provider<RiskUpdateService>((ref) {
  return RiskUpdateService(
    firestore: FirebaseFirestore.instance,
    dio: Dio(
      BaseOptions(
        baseUrl: AppConstants.openMeteoBaseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    ),
  );
});
