import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aedes_alert_yungrai/core/constants/app_constants.dart';
import 'package:aedes_alert_yungrai/core/services/dio_provider.dart';
import 'package:aedes_alert_yungrai/features/home/models/weather_forecast_model.dart';
import 'package:aedes_alert_yungrai/features/home/services/weather_service.dart';

class WeatherServiceImpl implements WeatherService {
  const WeatherServiceImpl(this._dio);

  final Dio _dio;

  @override
  Future<WeatherForecastModel> getForecast(
    double latitude,
    double longitude,
  ) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/forecast',
      queryParameters: {
        'latitude': latitude,
        'longitude': longitude,
        'daily': 'temperature_2m_max,temperature_2m_min,precipitation_sum',
        'forecast_days': AppConstants.weatherForecastDays,
        'timezone': 'auto',
      },
    );

    if (response.data == null) {
      throw const WeatherServiceException('Empty response from Open-Meteo');
    }

    return WeatherForecastModel.fromJson(response.data!);
  }
}

class WeatherServiceException implements Exception {
  const WeatherServiceException(this.message);

  final String message;

  @override
  String toString() => 'WeatherServiceException: $message';
}

final weatherServiceProvider = Provider<WeatherService>((ref) {
  return WeatherServiceImpl(ref.watch(dioProvider));
});
