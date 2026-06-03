import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aedes_alert_yungrai/features/ranking/data/repositories/ranking_repository_impl.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late RankingRepositoryImpl repository;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    repository = RankingRepositoryImpl(fakeFirestore);
  });

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  Future<void> addRankingDoc(
    String docId, {
    required int rank,
    double riskScore = 50.0,
    String riskLevel = 'medium',
  }) async {
    await fakeFirestore.collection('ranking').doc(docId).set({
      'areaId': docId,
      'subDistrict': 'Sub',
      'district': 'Dist',
      'province': 'Prov',
      'riskScore': riskScore,
      'riskLevel': riskLevel,
      'rank': rank,
      'updatedAt': Timestamp.fromDate(DateTime(2024, 6, 1)),
    });
  }

  // ---------------------------------------------------------------------------
  // watchRankedAreas
  // ---------------------------------------------------------------------------

  group('watchRankedAreas', () {
    test('returns a Stream (not null)', () {
      final stream = repository.watchRankedAreas();
      expect(stream, isA<Stream>());
    });

    test('stream emits areas ordered by rank ascending', () async {
      await addRankingDoc('area-3', rank: 3, riskScore: 30.0);
      await addRankingDoc('area-1', rank: 1, riskScore: 90.0);
      await addRankingDoc('area-2', rank: 2, riskScore: 60.0);

      final result = await repository.watchRankedAreas().first;

      expect(result.length, 3);
      expect(result[0].rank, 1);
      expect(result[1].rank, 2);
      expect(result[2].rank, 3);
    });

    test(
      'returns empty list when ranking collection is empty (no crash)',
      () async {
        final result = await repository.watchRankedAreas().first;
        expect(result, isEmpty);
      },
    );

    test('limit parameter caps the number of returned documents', () async {
      for (int i = 1; i <= 10; i++) {
        await addRankingDoc('area-$i', rank: i, riskScore: (10 - i) * 10.0);
      }

      final result = await repository.watchRankedAreas(limit: 5).first;
      expect(result.length, 5);
    });

    test(
      'each document maps to a RankingAreaEntity with correct fields',
      () async {
        await addRankingDoc(
          'area-x',
          rank: 1,
          riskScore: 75.5,
          riskLevel: 'high',
        );

        final result = await repository.watchRankedAreas().first;

        expect(result.length, 1);
        final entity = result.first;
        expect(entity.id, 'area-x');
        expect(entity.rank, 1);
        expect(entity.riskScore, 75.5);
        expect(entity.riskLevel, 'high');
      },
    );

    test(
      '500+ docs batch: 502 docs, limit 502, no crash, length == 502',
      () async {
        // Seed 502 documents with sequential rank values.
        for (int i = 1; i <= 502; i++) {
          await addRankingDoc('area-$i', rank: i, riskScore: i.toDouble());
        }

        final result = await repository.watchRankedAreas(limit: 502).first;
        expect(result.length, 502);
      },
    );
  });
}
