import 'package:flutter_test/flutter_test.dart';
import 'package:aedes_alert_yungrai/features/home/domain/entities/weather_forecast_model.dart';

void main() {
  Map<String, dynamic> validJson() => {
    'daily': {
      'time': ['2024-06-01', '2024-06-02', '2024-06-03'],
      'temperature_2m_max': [35.0, 36.5, 34.0],
      'temperature_2m_min': [26.0, 27.0, 25.5],
      'precipitation_sum': [0.0, 5.2, 12.0],
    },
  };

  test('fromJson parses 3 daily forecasts', () {
    final model = WeatherForecastModel.fromJson(validJson());
    expect(model.days.length, 3);
    expect(model.days[0].date, DateTime(2024, 6, 1));
    expect(model.days[0].tempMax, 35.0);
    expect(model.days[0].tempMin, 26.0);
    expect(model.days[0].precipitationSum, 0.0);
  });

  test('null precipitation_sum entry defaults to 0.0', () {
    final json = <String, dynamic>{
      'daily': <String, dynamic>{
        'time': ['2024-06-01', '2024-06-02', '2024-06-03'],
        'temperature_2m_max': [35.0, 36.0, 34.0],
        'temperature_2m_min': [26.0, 27.0, 25.0],
        'precipitation_sum': <Object?>[null, 5.2, null],
      },
    };
    final model = WeatherForecastModel.fromJson(json);
    expect(model.days[0].precipitationSum, 0.0);
    expect(model.days[1].precipitationSum, 5.2);
    expect(model.days[2].precipitationSum, 0.0);
  });

  test('empty days list does not crash', () {
    final json = {
      'daily': {
        'time': <String>[],
        'temperature_2m_max': <double>[],
        'temperature_2m_min': <double>[],
        'precipitation_sum': <double>[],
      },
    };
    final model = WeatherForecastModel.fromJson(json);
    expect(model.days, isEmpty);
  });
}
