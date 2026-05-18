import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aedes_alert_yungrai/features/dashboard/services/dashboard_repository_impl.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late DashboardRepositoryImpl repository;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    repository = DashboardRepositoryImpl(fakeFirestore);
  });

  Future<void> addArea(String id, double riskScore, String riskLevel) async {
    await fakeFirestore.collection('areas').doc(id).set({
      'subDistrict': 'S',
      'district': 'D',
      'province': 'P',
      'location': const GeoPoint(13.7563, 100.5018),
      'radius': 500.0,
      'riskScore': riskScore,
      'riskLevel': riskLevel,
      'reportedAt': Timestamp.fromDate(DateTime(2024, 1, 1)),
      'updatedAt': Timestamp.fromDate(DateTime(2024, 6, 1)),
    });
  }

  group('getAllAreas', () {
    test('empty collection returns empty list without crash', () async {
      final result = await repository.getAllAreas();
      expect(result, isEmpty);
    });

    test('returns all documents', () async {
      await addArea('a1', 50.0, 'medium');
      await addArea('a2', 80.0, 'high');
      final result = await repository.getAllAreas();
      expect(result.length, 2);
    });

    test('null riskScore in document does not crash', () async {
      await fakeFirestore.collection('areas').doc('nullScore').set({
        'subDistrict': 'S',
        'district': 'D',
        'province': 'P',
        'location': const GeoPoint(13.7563, 100.5018),
        'radius': 500.0,
        'riskScore': null,
        'riskLevel': 'low',
        'reportedAt': Timestamp.fromDate(DateTime(2024, 1, 1)),
        'updatedAt': Timestamp.fromDate(DateTime(2024, 6, 1)),
      });
      final result = await repository.getAllAreas();
      expect(result.first.riskScore, 0.0);
    });
  });

  group('getTopAreasByRisk', () {
    test('empty collection returns empty list without crash', () async {
      final result = await repository.getTopAreasByRisk(limit: 5);
      expect(result, isEmpty);
    });

    test('returns at most limit documents', () async {
      for (int i = 0; i < 7; i++) {
        await addArea('a$i', i * 10.0, 'low');
      }
      final result = await repository.getTopAreasByRisk(limit: 5);
      expect(result.length, 5);
    });

    test('returns areas ordered by riskScore descending', () async {
      await addArea('low', 20.0, 'low');
      await addArea('high', 90.0, 'high');
      await addArea('med', 55.0, 'medium');
      final result = await repository.getTopAreasByRisk(limit: 3);
      expect(result.first.riskScore, 90.0);
    });
  });
}
