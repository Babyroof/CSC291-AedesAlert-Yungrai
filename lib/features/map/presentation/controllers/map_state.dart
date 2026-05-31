import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aedes_alert_yungrai/features/map/domain/entities/map_area_entity.dart';
import 'package:aedes_alert_yungrai/features/map/domain/entities/place_entity.dart';

class MapState {
  const MapState({
    required this.areas,
    required this.places,
    this.filterMode = 'riskAreas',
    this.searchQuery = '',
    this.userLat,
    this.userLng,
  });

  final AsyncValue<List<MapAreaEntity>> areas;
  final AsyncValue<List<PlaceEntity>> places;
  final String filterMode; // 'riskAreas' | 'hospitals'
  final String searchQuery;
  final double? userLat;
  final double? userLng;

  factory MapState.initial() =>
      const MapState(areas: AsyncValue.loading(), places: AsyncValue.loading());

  MapState copyWith({
    AsyncValue<List<MapAreaEntity>>? areas,
    AsyncValue<List<PlaceEntity>>? places,
    String? filterMode,
    String? searchQuery,
    double? userLat,
    double? userLng,
  }) => MapState(
    areas: areas ?? this.areas,
    places: places ?? this.places,
    filterMode: filterMode ?? this.filterMode,
    searchQuery: searchQuery ?? this.searchQuery,
    userLat: userLat ?? this.userLat,
    userLng: userLng ?? this.userLng,
  );
}
