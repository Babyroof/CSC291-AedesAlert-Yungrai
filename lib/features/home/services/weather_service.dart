import 'package:aedes_alert_yungrai/features/home/models/weather_forecast_model.dart';

abstract class WeatherService {
  Future<WeatherForecastModel> getForecast(double latitude, double longitude);
}
