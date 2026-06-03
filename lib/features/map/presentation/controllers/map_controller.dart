import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aedes_alert_yungrai/core/services/risk_update_service.dart';
import 'package:aedes_alert_yungrai/features/map/domain/use_cases/get_all_areas_use_case.dart';
import 'package:aedes_alert_yungrai/features/map/domain/use_cases/get_places_use_case.dart';
import 'package:aedes_alert_yungrai/features/map/presentation/controllers/map_state.dart';

class MapController extends StateNotifier<MapState> {
  MapController({
    required GetAllAreasUseCase getAllAreas,
    required GetPlacesUseCase getPlaces,
    required RiskUpdateService riskUpdateService,
  }) : _getAllAreas = getAllAreas,
       _getPlaces = getPlaces,
       _riskUpdateService = riskUpdateService,
       super(MapState.initial()) {
    _init();
  }

  final GetAllAreasUseCase _getAllAreas;
  final GetPlacesUseCase _getPlaces;
  final RiskUpdateService _riskUpdateService;
  StreamSubscription<dynamic>? _areasSub;

  void _init() {
    // 1. Subscribe to Firestore stream — map updates automatically when data changes
    _areasSub = _getAllAreas.execute().listen(
      (areas) => state = state.copyWith(areas: AsyncValue.data(areas)),
      onError: (Object e, StackTrace st) =>
          state = state.copyWith(areas: AsyncValue.error(e, st)),
    );

    // 2. Recalculate risk scores from real weather in background (throttled 1×/hr)
    _riskUpdateService.updateAllAreas();

    // 3. Places are static — fetch once
    _getPlaces.execute().then(
      (places) => state = state.copyWith(places: AsyncValue.data(places)),
      onError: (Object e, StackTrace st) =>
          state = state.copyWith(places: AsyncValue.error(e, st)),
    );
  }

  // Refresh places on demand; areas stream + risk update run automatically
  Future<void> refresh() async {
    _riskUpdateService.updateAllAreas();
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
    riskUpdateService: ref.watch(riskUpdateServiceProvider),
  );
});
