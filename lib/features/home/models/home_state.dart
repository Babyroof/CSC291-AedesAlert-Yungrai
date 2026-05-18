import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aedes_alert_yungrai/features/home/models/area_model.dart';
import 'package:aedes_alert_yungrai/features/home/models/notification_model.dart';
import 'package:aedes_alert_yungrai/features/home/models/weather_forecast_model.dart';

class HomeState {
  const HomeState({
    required this.nearestArea,
    required this.latestNotification,
    required this.weatherForecast,
  });

  final AsyncValue<AreaModel?> nearestArea;
  final AsyncValue<NotificationModel?> latestNotification;
  final AsyncValue<WeatherForecastModel?> weatherForecast;

  factory HomeState.initial() => const HomeState(
        nearestArea: AsyncValue.loading(),
        latestNotification: AsyncValue.loading(),
        weatherForecast: AsyncValue.loading(),
      );

  HomeState copyWith({
    AsyncValue<AreaModel?>? nearestArea,
    AsyncValue<NotificationModel?>? latestNotification,
    AsyncValue<WeatherForecastModel?>? weatherForecast,
  }) {
    return HomeState(
      nearestArea: nearestArea ?? this.nearestArea,
      latestNotification: latestNotification ?? this.latestNotification,
      weatherForecast: weatherForecast ?? this.weatherForecast,
    );
  }
}
