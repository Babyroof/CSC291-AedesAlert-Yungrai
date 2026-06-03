import 'dart:async';

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
       super(MapState.initial()) {
    _init();
  }

  final GetAllAreasUseCase _getAllAreas;
  final GetPlacesUseCase _getPlaces;
  StreamSubscription<dynamic>? _areasSub;

  void _init() {
    _areasSub = _getAllAreas.execute().listen(
      (areas) => state = state.copyWith(areas: AsyncValue.data(areas)),
      onError: (Object e, StackTrace st) =>
          state = state.copyWith(areas: AsyncValue.error(e, st)),
    );

    _getPlaces.execute().then(
      (places) => state = state.copyWith(places: AsyncValue.data(places)),
      onError: (Object e, StackTrace st) =>
          state = state.copyWith(places: AsyncValue.error(e, st)),
    );
  }

  Future<void> refresh() async {
    try {
      final places = await _getPlaces.execute();
      state = state.copyWith(places: AsyncValue.data(places));
    } catch (e, st) {
      state = state.copyWith(places: AsyncValue.error(e, st));
    }
  }

  void setFilter(String mode) => state = state.copyWith(filterMode: mode);
  void setSearch(String query) => state = state.copyWith(searchQuery: query);
  void setUserLocation(double lat, double lng) =>
      state = state.copyWith(userLat: lat, userLng: lng);

  @override
  void dispose() {
    _areasSub?.cancel();
    super.dispose();
  }
}

final mapControllerProvider = StateNotifierProvider<MapController, MapState>((
  ref,
) {
  return MapController(
    getAllAreas: ref.watch(getAllAreasUseCaseProvider),
    getPlaces: ref.watch(getPlacesUseCaseProvider),
  );
});
