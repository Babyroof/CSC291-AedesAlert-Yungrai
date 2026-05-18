import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aedes_alert_yungrai/features/home/services/area_repository_impl.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late AreaRepositoryImpl repository;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    repository = AreaRepositoryImpl(fakeFirestore);
  });

  Future<void> addArea(String id, GeoPoint location, double riskScore) async {
    await fakeFirestore.collection('areas').doc(id).set({
      'subDistrict': 'Sub',
      'district': 'Dist',
      'province': 'Prov',
      'location': location,
      'radius': 500.0,
      'riskScore': riskScore,
      'riskLevel': 'medium',
      'reportedAt': Timestamp.fromDate(DateTime(2024, 1, 1)),
      'updatedAt': Timestamp.fromDate(DateTime(2024, 6, 1)),
    });
  }

  test('empty collection returns null without crash', () async {
    final result = await repository.getNearestArea(
      const GeoPoint(13.7563, 100.5018),
    );
    expect(result, isNull);
  });

  test('area within radius is returned', () async {
    // ~0.1 km from origin
    await addArea('a1', const GeoPoint(13.7572, 100.5018), 60.0);
    final result = await repository.getNearestArea(
      const GeoPoint(13.7563, 100.5018),
      radiusKm: 5.0,
    );
    expect(result, isNotNull);
    expect(result!.id, 'a1');
  });

  test('area outside radius returns null', () async {
    // Bangkok vs Chiang Mai (~590 km apart)
    await addArea('far', const GeoPoint(18.7883, 98.9853), 40.0);
    final result = await repository.getNearestArea(
      const GeoPoint(13.7563, 100.5018),
      radiusKm: 5.0,
    );
    expect(result, isNull);
  });

  test('returns nearest when multiple areas are within radius', () async {
    await addArea('close', const GeoPoint(13.7565, 100.5018), 50.0);
    await addArea('further', const GeoPoint(13.7590, 100.5018), 80.0);
    final result = await repository.getNearestArea(
      const GeoPoint(13.7563, 100.5018),
      radiusKm: 5.0,
    );
    expect(result!.id, 'close');
  });

  test('null riskScore in Firestore does not crash', () async {
    await fakeFirestore.collection('areas').doc('nullScore').set({
      'subDistrict': 'S',
      'district': 'D',
      'province': 'P',
      'location': const GeoPoint(13.7564, 100.5018),
      'radius': 500.0,
      'riskScore': null,
      'riskLevel': 'low',
      'reportedAt': Timestamp.fromDate(DateTime(2024, 1, 1)),
      'updatedAt': Timestamp.fromDate(DateTime(2024, 6, 1)),
    });
    final result = await repository.getNearestArea(
      const GeoPoint(13.7563, 100.5018),
      radiusKm: 5.0,
    );
    expect(result, isNotNull);
    expect(result!.riskScore, 0.0);
  });
}
