import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aedes_alert_yungrai/features/ranking/domain/entities/ranking_area_entity.dart';
import 'package:aedes_alert_yungrai/features/ranking/domain/repositories/ranking_repository.dart';
import 'package:aedes_alert_yungrai/features/ranking/data/repositories/ranking_repository_impl.dart';
import 'package:aedes_alert_yungrai/features/ranking/presentation/controllers/ranking_stream_provider.dart';

// ---------------------------------------------------------------------------
// Manual fake — no build_runner / @GenerateMocks needed.
// ---------------------------------------------------------------------------

class FakeRankingRepository implements RankingRepository {
  final Stream<List<RankingAreaEntity>> _stream;

  const FakeRankingRepository(this._stream);

  @override
  Stream<List<RankingAreaEntity>> watchRankedAreas({int limit = 20}) => _stream;

  @override
  Future<List<RankingAreaEntity>> getRankedAreas({int limit = 20}) async => [];
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

RankingAreaEntity fakeEntity(String id, {int rank = 1}) => RankingAreaEntity(
  id: id,
  subDistrict: 'S',
  district: 'D',
  province: 'P',
  riskScore: 55.0,
  riskLevel: 'medium',
  rank: rank,
  updatedAt: DateTime(2024, 6, 1),
);

ProviderContainer buildContainer(Stream<List<RankingAreaEntity>> stream) {
  final fakeRepo = FakeRankingRepository(stream);
  return ProviderContainer(
    overrides: [rankingRepositoryProvider.overrideWithValue(fakeRepo)],
  );
}

/// Subscribe to [provider] on [container] so it becomes active, then pump
/// the microtask / event queue until the stream has had a chance to emit.
Future<void> activateAndSettle(
  ProviderContainer container,
  ProviderListenable provider,
) async {
  container.listen(provider, (_, _) {});
  // Two rounds of the event loop are sufficient for a synchronous stream
  // (Stream.value / Stream.error) to deliver its event through Riverpod.
  await Future<void>.delayed(Duration.zero);
  await Future<void>.delayed(Duration.zero);
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('rankedAreasStreamProvider', () {
    test('emits AsyncData when repository returns areas', () async {
      final areas = [fakeEntity('a1', rank: 1), fakeEntity('a2', rank: 2)];
      final container = buildContainer(Stream.value(areas));
      addTearDown(container.dispose);

      await activateAndSettle(container, rankedAreasStreamProvider);

      final state = container.read(rankedAreasStreamProvider);
      expect(state, isA<AsyncData<List<RankingAreaEntity>>>());
      expect(state.value?.length, 2);
      expect(state.value?.first.id, 'a1');
    });

    test('emits AsyncLoading before the stream produces a value', () {
      // Use a StreamController that never emits so the provider stays loading.
      final ctrl = StreamController<List<RankingAreaEntity>>();
      final container = buildContainer(ctrl.stream);
      addTearDown(() {
        container.dispose();
        ctrl.close();
      });

      // Subscribe to activate; do NOT pump so no event is delivered yet.
      container.listen(rankedAreasStreamProvider, (_, _) {});

      final state = container.read(rankedAreasStreamProvider);
      expect(state, isA<AsyncLoading<List<RankingAreaEntity>>>());
    });

    test('emits AsyncError when repository stream throws', () async {
      final stream = Stream<List<RankingAreaEntity>>.error(
        Exception('Firestore unavailable'),
      );
      final container = buildContainer(stream);
      addTearDown(container.dispose);

      await activateAndSettle(container, rankedAreasStreamProvider);

      final state = container.read(rankedAreasStreamProvider);
      expect(state, isA<AsyncError<List<RankingAreaEntity>>>());
    });

    test(
      'emits AsyncData with empty list when repository returns empty stream',
      () async {
        final container = buildContainer(Stream.value([]));
        addTearDown(container.dispose);

        await activateAndSettle(container, rankedAreasStreamProvider);

        final state = container.read(rankedAreasStreamProvider);
        expect(state, isA<AsyncData<List<RankingAreaEntity>>>());
        expect(state.value, isEmpty);
      },
    );

    test('emits multiple updates as stream produces new values', () async {
      final ctrl = StreamController<List<RankingAreaEntity>>();
      final container = buildContainer(ctrl.stream);
      addTearDown(() {
        container.dispose();
        ctrl.close();
      });

      // Subscribe to activate the provider.
      container.listen(rankedAreasStreamProvider, (_, _) {});

      // First emission.
      ctrl.add([fakeEntity('a1')]);
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);
      expect(container.read(rankedAreasStreamProvider).value?.first.id, 'a1');

      // Second emission.
      ctrl.add([fakeEntity('a1'), fakeEntity('a2')]);
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);
      expect(container.read(rankedAreasStreamProvider).value?.length, 2);
    });
  });
}
