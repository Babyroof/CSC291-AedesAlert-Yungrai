import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:aedes_alert_yungrai/features/home/services/weather_service_impl.dart';

import 'weather_service_impl_test.mocks.dart';

@GenerateMocks([Dio])
void main() {
  late MockDio mockDio;
  late WeatherServiceImpl service;

  setUp(() {
    mockDio = MockDio();
    service = WeatherServiceImpl(mockDio);
  });

  Map<String, dynamic> validResponseData() => {
        'daily': {
          'time': ['2024-06-01', '2024-06-02', '2024-06-03'],
          'temperature_2m_max': [35.0, 36.0, 34.0],
          'temperature_2m_min': [26.0, 27.0, 25.0],
          'precipitation_sum': [0.0, 2.0, 5.0],
        }
      };

  test('returns WeatherForecastModel on success', () async {
    when(mockDio.get<Map<String, dynamic>>(
      any,
      queryParameters: anyNamed('queryParameters'),
    )).thenAnswer((_) async => Response(
          data: validResponseData(),
          statusCode: 200,
          requestOptions: RequestOptions(path: '/forecast'),
        ));

    final result = await service.getForecast(13.7563, 100.5018);
    expect(result.days.length, 3);
    expect(result.days[0].tempMax, 35.0);
  });

  test('throws WeatherServiceException when response data is null', () async {
    when(mockDio.get<Map<String, dynamic>>(
      any,
      queryParameters: anyNamed('queryParameters'),
    )).thenAnswer((_) async => Response(
          data: null,
          statusCode: 200,
          requestOptions: RequestOptions(path: '/forecast'),
        ));

    expect(
      () => service.getForecast(13.7563, 100.5018),
      throwsA(isA<WeatherServiceException>()),
    );
  });

  test('Open-Meteo timeout propagates as DioException (not crash)', () async {
    when(mockDio.get<Map<String, dynamic>>(
      any,
      queryParameters: anyNamed('queryParameters'),
    )).thenThrow(DioException(
      type: DioExceptionType.connectionTimeout,
      requestOptions: RequestOptions(path: '/forecast'),
    ));

    expect(
      () => service.getForecast(13.7563, 100.5018),
      throwsA(isA<DioException>()),
    );
  });
}
