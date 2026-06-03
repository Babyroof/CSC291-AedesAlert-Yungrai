import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aedes_alert_yungrai/features/home/data/models/area_model.dart';
import 'package:aedes_alert_yungrai/features/home/data/models/notification_model.dart';
import 'package:aedes_alert_yungrai/features/home/domain/entities/weather_forecast_model.dart';

class HomeState {
  const HomeState({
    required this.nearestArea,
    required this.latestNotification,
    required this.weatherForecast,
    required this.latestDistrictArea,
  });

  final AsyncValue<AreaModel?> nearestArea;
  final AsyncValue<NotificationModel?> latestNotification;
  final AsyncValue<WeatherForecastModel?> weatherForecast;

  /// The single latest area record for the user's current district
  /// (`isLatest == true` or most-recent `updatedAt`).
  final AsyncValue<AreaModel?> latestDistrictArea;

  factory HomeState.initial() => const HomeState(
    nearestArea: AsyncValue.loading(),
    latestNotification: AsyncValue.loading(),
    weatherForecast: AsyncValue.loading(),
    latestDistrictArea: AsyncValue.loading(),
  );

  HomeState copyWith({
    AsyncValue<AreaModel?>? nearestArea,
    AsyncValue<NotificationModel?>? latestNotification,
    AsyncValue<WeatherForecastModel?>? weatherForecast,
    AsyncValue<AreaModel?>? latestDistrictArea,
  }) {
    return HomeState(
      nearestArea: nearestArea ?? this.nearestArea,
      latestNotification: latestNotification ?? this.latestNotification,
      weatherForecast: weatherForecast ?? this.weatherForecast,
      latestDistrictArea: latestDistrictArea ?? this.latestDistrictArea,
    );
  }
}
