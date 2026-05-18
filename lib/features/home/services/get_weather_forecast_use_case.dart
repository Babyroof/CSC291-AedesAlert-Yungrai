import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aedes_alert_yungrai/features/home/models/weather_forecast_model.dart';
import 'package:aedes_alert_yungrai/features/home/services/weather_service.dart';
import 'package:aedes_alert_yungrai/features/home/services/weather_service_impl.dart';

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
