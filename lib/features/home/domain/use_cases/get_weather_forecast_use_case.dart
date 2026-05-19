import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aedes_alert_yungrai/features/home/domain/entities/weather_forecast_model.dart';
import 'package:aedes_alert_yungrai/features/home/domain/repositories/weather_service.dart';
import 'package:aedes_alert_yungrai/features/home/data/data_sources/weather_service_impl.dart';

class GetWeatherForecastUseCase {
  const GetWeatherForecastUseCase(this._service);

  final WeatherService _service;

  Future<WeatherForecastModel> execute(GeoPoint location) =>
      _service.getForecast(location.latitude, location.longitude);
}

final getWeatherForecastUseCaseProvider =
    Provider<GetWeatherForecastUseCase>((ref) {
  return GetWeatherForecastUseCase(ref.watch(weatherServiceProvider));
});
