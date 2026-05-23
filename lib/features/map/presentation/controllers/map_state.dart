import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aedes_alert_yungrai/features/map/domain/entities/map_area_entity.dart';
import 'package:aedes_alert_yungrai/features/map/domain/entities/place_entity.dart';

class MapState {
  const MapState({required this.areas, required this.places});

  final AsyncValue<List<MapAreaEntity>> areas;
  final AsyncValue<List<PlaceEntity>> places;

  factory MapState.initial() => const MapState(
        areas: AsyncValue.loading(),
        places: AsyncValue.loading(),
      );

  MapState copyWith({
    AsyncValue<List<MapAreaEntity>>? areas,
    AsyncValue<List<PlaceEntity>>? places,
  }) =>
      MapState(
        areas: areas ?? this.areas,
        places: places ?? this.places,
      );
}
