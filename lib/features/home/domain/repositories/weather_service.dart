import 'package:aedes_alert_yungrai/features/home/domain/entities/weather_forecast_model.dart';

abstract class WeatherService {
  Future<WeatherForecastModel> getForecast(double latitude, double longitude);
}
