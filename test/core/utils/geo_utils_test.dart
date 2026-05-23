import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aedes_alert_yungrai/core/utils/geo_utils.dart';

void main() {
  group('GeoUtils.distanceInKm', () {
    test('same point returns 0', () {
      const p = GeoPoint(13.7563, 100.5018);
      expect(GeoUtils.distanceInKm(p, p), closeTo(0.0, 0.001));
    });

    test('known Bangkok–Chiang Mai distance ~590 km', () {
      const bangkok = GeoPoint(13.7563, 100.5018);
      const chiangMai = GeoPoint(18.7883, 98.9853);
      final dist = GeoUtils.distanceInKm(bangkok, chiangMai);
      expect(dist, greaterThan(580));
      expect(dist, lessThan(610));
    });

    test('points 1 km apart return roughly 1 km', () {
      const a = GeoPoint(13.7563, 100.5018);
      // ~1 km north at Bangkok latitude
      const b = GeoPoint(13.7653, 100.5018);
      final dist = GeoUtils.distanceInKm(a, b);
      expect(dist, closeTo(1.0, 0.05));
    });
  });

  group('GeoUtils.nearestIndex', () {
    test('returns -1 for empty list', () {
      const origin = GeoPoint(13.7563, 100.5018);
      expect(GeoUtils.nearestIndex(origin, []), -1);
    });

    test('returns 0 for single-element list', () {
      const origin = GeoPoint(13.7563, 100.5018);
      const p = GeoPoint(13.7600, 100.5050);
      expect(GeoUtils.nearestIndex(origin, [p]), 0);
    });

    test('returns index of closest point', () {
      const origin = GeoPoint(13.7563, 100.5018);
      const close = GeoPoint(13.7570, 100.5020);
      const far = GeoPoint(18.7883, 98.9853);
      expect(GeoUtils.nearestIndex(origin, [far, close]), 1);
    });
  });
}
