import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aedes_alert_yungrai/features/map/domain/use_cases/get_all_areas_use_case.dart';
import 'package:aedes_alert_yungrai/features/map/domain/use_cases/get_places_use_case.dart';
import 'package:aedes_alert_yungrai/features/map/presentation/controllers/map_state.dart';

class MapController extends StateNotifier<MapState> {
  MapController({
    required GetAllAreasUseCase getAllAreas,
    required GetPlacesUseCase getPlaces,
  }) : _getAllAreas = getAllAreas,
       _getPlaces = getPlaces,
       super(MapState.initial());

  final GetAllAreasUseCase _getAllAreas;
  final GetPlacesUseCase _getPlaces;

  Future<void> loadMapData() async {
    state = MapState.initial();
    await Future.wait([
      _getAllAreas.execute().then(
        (areas) => state = state.copyWith(areas: AsyncValue.data(areas)),
        onError: (Object e, StackTrace st) =>
            state = state.copyWith(areas: AsyncValue.error(e, st)),
      ),
      _getPlaces.execute().then(
        (places) => state = state.copyWith(places: AsyncValue.data(places)),
        onError: (Object e, StackTrace st) =>
            state = state.copyWith(places: AsyncValue.error(e, st)),
      ),
    ]);
  }

  Future<void> refresh() => loadMapData();
}

final mapControllerProvider = StateNotifierProvider<MapController, MapState>((
  ref,
) {
  return MapController(
    getAllAreas: ref.watch(getAllAreasUseCaseProvider),
    getPlaces: ref.watch(getPlacesUseCaseProvider),
  );
});
