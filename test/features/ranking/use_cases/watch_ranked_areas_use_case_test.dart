import 'package:flutter_test/flutter_test.dart';
import 'package:aedes_alert_yungrai/features/ranking/domain/entities/ranking_area_entity.dart';
import 'package:aedes_alert_yungrai/features/ranking/domain/repositories/ranking_repository.dart';
import 'package:aedes_alert_yungrai/features/ranking/domain/use_cases/watch_ranked_areas_use_case.dart';

// ---------------------------------------------------------------------------
// Manual fake — no build_runner / @GenerateMocks needed.
// ---------------------------------------------------------------------------

class FakeRankingRepository implements RankingRepository {
  /// Stream to return from watchRankedAreas.
  Stream<List<RankingAreaEntity>>? streamToReturn;

  /// Captured limit value from the last watchRankedAreas call.
  int? capturedWatchLimit;

  @override
  Stream<List<RankingAreaEntity>> watchRankedAreas({int limit = 20}) {
    capturedWatchLimit = limit;
    return streamToReturn ?? const Stream.empty();
  }

  @override
  Future<List<RankingAreaEntity>> getRankedAreas({int limit = 20}) async => [];
}

// ---------------------------------------------------------------------------
// Helper
// ---------------------------------------------------------------------------

RankingAreaEntity fakeEntity(String id, {double riskScore = 50.0, int rank = 1}) =>
    RankingAreaEntity(
      id: id,
      subDistrict: 'S',
      district: 'D',
      province: 'P',
      riskScore: riskScore,
      riskLevel: 'medium',
      rank: rank,
      updatedAt: DateTime(2024, 6, 1),
    );

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late FakeRankingRepository fakeRepo;
  late WatchRankedAreasUseCase useCase;

  setUp(() {
    fakeRepo = FakeRankingRepository();
    useCase = WatchRankedAreasUseCase(fakeRepo);
  });

  group('WatchRankedAreasUseCase.watch', () {
    test('returns the stream from the repository', () async {
      final expectedAreas = [fakeEntity('a1', rank: 1), fakeEntity('a2', rank: 2)];
      fakeRepo.streamToReturn = Stream.value(expectedAreas);

      final result = await useCase.watch().first;

      expect(result.length, 2);
      expect(result.first.id, 'a1');
      expect(result.last.id, 'a2');
    });

    test('with limit parameter passes limit to repository', () {
      fakeRepo.streamToReturn = Stream.value([]);

      useCase.watch(limit: 10);

      expect(fakeRepo.capturedWatchLimit, 10);
    });

    test('default limit (20) is forwarded to repository', () {
      fakeRepo.streamToReturn = Stream.value([]);

      useCase.watch();

      expect(fakeRepo.capturedWatchLimit, 20);
    });

    test(
      'two areas with equal riskScore: stream emits without crashing, stable order',
      () async {
        final areas = [
          fakeEntity('a1', riskScore: 50.0, rank: 1),
          fakeEntity('a2', riskScore: 50.0, rank: 2),
        ];
        fakeRepo.streamToReturn = Stream.value(areas);

        final result = await useCase.watch().first;

        expect(result.length, 2);
        // The two areas are emitted in the original order — no crash.
        expect(result[0].id, 'a1');
        expect(result[1].id, 'a2');
        expect(result[0].riskScore, result[1].riskScore);
      },
    );

    test('empty list from repository is forwarded without crash', () async {
      fakeRepo.streamToReturn = Stream.value([]);

      final result = await useCase.watch().first;

      expect(result, isEmpty);
    });

    test('repository stream error propagates to caller', () async {
      fakeRepo.streamToReturn =
          Stream.error(Exception('Firestore unavailable'));

      expect(
        useCase.watch(),
        emitsError(isA<Exception>()),
      );
    });
  });
}