import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aedes_alert_yungrai/features/ranking/data/repositories/ranking_repository_impl.dart';
import 'package:aedes_alert_yungrai/features/ranking/domain/entities/ranking_area_entity.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late RankingRepositoryImpl repository;

  // A reportedAt timestamp that falls within the current calendar month so
  // the primary query (isLatest + reportedAt range) always matches in tests.
  final Timestamp thisMonth = Timestamp.fromDate(
    DateTime(DateTime.now().year, DateTime.now().month, 15),
  );

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    repository = RankingRepositoryImpl(fakeFirestore);
  });

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Adds a document to the `areas` collection with the schema that
  /// [RankingRepositoryImpl] reads.  Each district gets a unique name so the
  /// de-duplication logic keeps all documents unless a test deliberately
  /// re-uses the same district value.
  Future<void> addAreaDoc(
    String docId, {
    required double riskScore,
    String riskLevel = 'medium',
    String? district,
  }) async {
    await fakeFirestore.collection('areas').doc(docId).set({
      'subDistrict': 'Sub-$docId',
      'district': district ?? 'District-$docId',
      'province': 'Prov',
      'riskScore': riskScore,
      'riskLevel': riskLevel,
      'updatedAt': thisMonth,
      'reportedAt': thisMonth,
      'isLatest': true,
    });
  }

  // ---------------------------------------------------------------------------
  // getRankedAreas  (the implemented method — watchRankedAreas is a TODO stub)
  // ---------------------------------------------------------------------------

  group('getRankedAreas', () {
    test('returns a Future (not null)', () {
      final future = repository.getRankedAreas();
      expect(future, isA<Future>());
    });

    test('results are ordered by riskScore descending', () async {
      await addAreaDoc('area-low', riskScore: 30.0);
      await addAreaDoc('area-high', riskScore: 90.0);
      await addAreaDoc('area-mid', riskScore: 60.0);

      final result = await repository.getRankedAreas();

      expect(result.length, 3);
      expect(result[0].riskScore, 90.0);
      expect(result[1].riskScore, 60.0);
      expect(result[2].riskScore, 30.0);
    });

    test(
      'returns empty list when areas collection is empty (no crash)',
      () async {
        final result = await repository.getRankedAreas();
        expect(result, isEmpty);
      },
    );

    test(
      'de-duplicates by district — keeps the highest riskScore per district',
      () async {
        // Two docs for the same district; only the higher-scored one survives.
        await fakeFirestore.collection('areas').doc('d1-v1').set({
          'subDistrict': 'Sub',
          'district': 'SharedDistrict',
          'province': 'Prov',
          'riskScore': 40.0,
          'riskLevel': 'low',
          'updatedAt': thisMonth,
          'reportedAt': thisMonth,
          'isLatest': true,
        });
        await fakeFirestore.collection('areas').doc('d1-v2').set({
          'subDistrict': 'Sub',
          'district': 'SharedDistrict',
          'province': 'Prov',
          'riskScore': 80.0,
          'riskLevel': 'high',
          'updatedAt': thisMonth,
          'reportedAt': thisMonth,
          'isLatest': true,
        });

        final result = await repository.getRankedAreas();

        expect(result.length, 1);
        expect(result.first.riskScore, 80.0);
      },
    );

    test(
      'each document maps to a RankingAreaEntity with correct fields',
      () async {
        await fakeFirestore.collection('areas').doc('area-x').set({
          'subDistrict': 'MySub',
          'district': 'MyDistrict',
          'province': 'MyProv',
          'riskScore': 75.5,
          'riskLevel': 'high',
          'updatedAt': thisMonth,
          'reportedAt': thisMonth,
          'isLatest': true,
        });

        final result = await repository.getRankedAreas();

        expect(result.length, 1);
        final entity = result.first;
        expect(entity, isA<RankingAreaEntity>());
        expect(entity.id, 'area-x');
        expect(entity.riskScore, 75.5);
        expect(entity.riskLevel, 'high');
        expect(entity.district, 'MyDistrict');
        expect(entity.subDistrict, 'MySub');
        expect(entity.province, 'MyProv');
      },
    );

    test(
      '20+ docs: 25 docs, all unique districts, returns 25, no crash',
      () async {
        for (int i = 1; i <= 25; i++) {
          await addAreaDoc('area-$i', riskScore: i.toDouble());
        }

        final result = await repository.getRankedAreas();
        expect(result.length, 25);
      },
    );
  });

  // ---------------------------------------------------------------------------
  // watchRankedAreas — currently unimplemented (throws UnimplementedError)
  // ---------------------------------------------------------------------------

  group('watchRankedAreas', () {
    test('throws UnimplementedError (not yet implemented)', () {
      expect(() => repository.watchRankedAreas(), throwsA(isA<UnimplementedError>()));
    });
  });
}