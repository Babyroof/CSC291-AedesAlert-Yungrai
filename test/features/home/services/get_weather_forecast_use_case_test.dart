import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:aedes_alert_yungrai/features/home/domain/entities/weather_forecast_model.dart';
import 'package:aedes_alert_yungrai/features/home/domain/repositories/weather_service.dart';
import 'package:aedes_alert_yungrai/features/home/domain/use_cases/get_weather_forecast_use_case.dart';

import 'get_weather_forecast_use_case_test.mocks.dart';

@GenerateMocks([WeatherService])
void main() {
  late MockWeatherService mockService;
  late GetWeatherForecastUseCase useCase;

  setUp(() {
    mockService = MockWeatherService();
    useCase = GetWeatherForecastUseCase(mockService);
  });

  WeatherForecastModel fakeForecast() => WeatherForecastModel(days: [
        DailyForecast(
          date: DateTime(2024, 6, 1),
          tempMax: 35.0,
          tempMin: 26.0,
          precipitationSum: 0.0,
        ),
      ]);

  test('returns forecast from service', () async {
    when(mockService.getForecast(any, any))
        .thenAnswer((_) async => fakeForecast());

    const location = GeoPoint(13.7563, 100.5018);
    final result = await useCase.execute(location);
    expect(result.days.length, 1);
    expect(result.days[0].tempMax, 35.0);
  });

  test('passes lat/lng from GeoPoint to service', () async {
    when(mockService.getForecast(any, any))
        .thenAnswer((_) async => fakeForecast());

    await useCase.execute(const GeoPoint(13.7563, 100.5018));

    verify(mockService.getForecast(13.7563, 100.5018)).called(1);
  });

  test('Open-Meteo timeout propagates as exception (not crash)', () async {
    when(mockService.getForecast(any, any))
        .thenThrow(Exception('connection timeout'));

    expect(
      () => useCase.execute(const GeoPoint(13.7563, 100.5018)),
      throwsA(isA<Exception>()),
    );
  });
}
