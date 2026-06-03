import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aedes_alert_yungrai/features/ranking/data/models/ranking_model.dart';
import 'package:aedes_alert_yungrai/features/ranking/domain/entities/ranking_area_entity.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
  });

  // Helper: seed one doc and return its snapshot.
  Future<DocumentSnapshot<Map<String, dynamic>>> seedDoc(
    String docId,
    Map<String, dynamic> data,
  ) async {
    await fakeFirestore.collection('ranking').doc(docId).set(data);
    return fakeFirestore.collection('ranking').doc(docId).get();
  }

  final fixedDate = DateTime(2024, 6, 1);

  group('RankingModel.fromFirestore', () {
    test('maps all fields correctly', () async {
      final snap = await seedDoc('doc1', {
        'areaId': 'area-123',
        'subDistrict': 'Lat Phrao',
        'district': 'Lat Phrao',
        'province': 'Bangkok',
        'riskScore': 78.5,
        'riskLevel': 'high',
        'rank': 3,
        'updatedAt': Timestamp.fromDate(fixedDate),
      });

      final model = RankingModel.fromFirestore(snap);

      expect(model.areaId, 'area-123');
      expect(model.subDistrict, 'Lat Phrao');
      expect(model.district, 'Lat Phrao');
      expect(model.province, 'Bangkok');
      expect(model.riskScore, 78.5);
      expect(model.riskLevel, 'high');
      expect(model.rank, 3);
      expect(model.updatedAt, fixedDate);
    });

    test('falls back to doc.id when areaId field is absent', () async {
      final snap = await seedDoc('fallback-id', {
        'subDistrict': 'S',
        'district': 'D',
        'province': 'P',
        'riskScore': 50.0,
        'riskLevel': 'medium',
        'rank': 1,
        'updatedAt': Timestamp.fromDate(fixedDate),
        // no 'areaId' key
      });

      final model = RankingModel.fromFirestore(snap);
      expect(model.areaId, 'fallback-id');
    });

    test('handles null / missing fields with defaults', () async {
      // Empty document — every field missing.
      final snap = await seedDoc('empty-doc', {});

      final model = RankingModel.fromFirestore(snap);

      expect(model.areaId, 'empty-doc'); // falls back to doc.id
      expect(model.subDistrict, '');
      expect(model.district, '');
      expect(model.province, '');
      expect(model.riskScore, 0.0);
      expect(model.riskLevel, 'low');
      expect(model.rank, 0);
      // updatedAt defaults to DateTime.now(); just verify it's a DateTime.
      expect(model.updatedAt, isA<DateTime>());
    });

    test('handles null riskScore without crash, defaults to 0.0', () async {
      final snap = await seedDoc('null-score', {
        'areaId': 'null-score',
        'subDistrict': 'S',
        'district': 'D',
        'province': 'P',
        'riskScore': null,
        'riskLevel': 'low',
        'rank': 1,
        'updatedAt': Timestamp.fromDate(fixedDate),
      });

      final model = RankingModel.fromFirestore(snap);
      expect(model.riskScore, 0.0);
    });

    test('handles null riskLevel without crash, defaults to "low"', () async {
      final snap = await seedDoc('null-level', {
        'areaId': 'null-level',
        'subDistrict': 'S',
        'district': 'D',
        'province': 'P',
        'riskScore': 10.0,
        'riskLevel': null,
        'rank': 1,
        'updatedAt': Timestamp.fromDate(fixedDate),
      });

      final model = RankingModel.fromFirestore(snap);
      expect(model.riskLevel, 'low');
    });

    test('handles null rank without crash, defaults to 0', () async {
      final snap = await seedDoc('null-rank', {
        'areaId': 'null-rank',
        'subDistrict': 'S',
        'district': 'D',
        'province': 'P',
        'riskScore': 10.0,
        'riskLevel': 'low',
        'rank': null,
        'updatedAt': Timestamp.fromDate(fixedDate),
      });

      final model = RankingModel.fromFirestore(snap);
      expect(model.rank, 0);
    });
  });

  group('RankingModel.toEntity', () {
    test('maps every field to RankingAreaEntity correctly', () {
      final model = RankingModel(
        areaId: 'area-42',
        subDistrict: 'Bang Khen',
        district: 'Bang Khen',
        province: 'Bangkok',
        riskScore: 65.0,
        riskLevel: 'medium',
        rank: 2,
        updatedAt: fixedDate,
      );

      final entity = model.toEntity();

      expect(entity, isA<RankingAreaEntity>());
      expect(entity.id, 'area-42');
      expect(entity.subDistrict, 'Bang Khen');
      expect(entity.district, 'Bang Khen');
      expect(entity.province, 'Bangkok');
      expect(entity.riskScore, 65.0);
      expect(entity.riskLevel, 'medium');
      expect(entity.rank, 2);
      expect(entity.updatedAt, fixedDate);
    });

    test(
      'two areas with equal riskScore map to distinct entities without crash',
      () {
        final m1 = RankingModel(
          areaId: 'a1',
          subDistrict: 'S1',
          district: 'D',
          province: 'P',
          riskScore: 50.0,
          riskLevel: 'medium',
          rank: 1,
          updatedAt: fixedDate,
        );
        final m2 = RankingModel(
          areaId: 'a2',
          subDistrict: 'S2',
          district: 'D',
          province: 'P',
          riskScore: 50.0,
          riskLevel: 'medium',
          rank: 2,
          updatedAt: fixedDate,
        );

        final e1 = m1.toEntity();
        final e2 = m2.toEntity();

        expect(e1.id, 'a1');
        expect(e2.id, 'a2');
        expect(e1.riskScore, e2.riskScore);
      },
    );
  });
}
