import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:aedes_alert_yungrai/features/home/data/models/area_model.dart';
import 'package:aedes_alert_yungrai/features/home/data/models/notification_model.dart';
import 'package:aedes_alert_yungrai/features/home/domain/entities/weather_forecast_model.dart';
import 'package:aedes_alert_yungrai/features/home/domain/use_cases/get_nearest_area_use_case.dart';
import 'package:aedes_alert_yungrai/features/home/domain/use_cases/get_latest_notification_use_case.dart';
import 'package:aedes_alert_yungrai/features/home/domain/use_cases/get_weather_forecast_use_case.dart';
import 'package:aedes_alert_yungrai/features/home/presentation/controllers/home_controller.dart';

import 'home_controller_test.mocks.dart';

@GenerateMocks([
  GetNearestAreaUseCase,
  GetLatestNotificationUseCase,
  GetWeatherForecastUseCase,
])
void main() {
  late MockGetNearestAreaUseCase mockGetNearestArea;
  late MockGetLatestNotificationUseCase mockGetLatestNotification;
  late MockGetWeatherForecastUseCase mockGetWeatherForecast;
  late HomeController controller;

  const userLocation = GeoPoint(13.7563, 100.5018);

  AreaModel fakeArea() => AreaModel(
        id: 'a1',
        subDistrict: 'S',
        district: 'D',
        province: 'P',
        location: userLocation,
        radius: 500,
        riskScore: 60.0,
        riskLevel: 'medium',
        reportedAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 6, 1),
      );

  WeatherForecastModel fakeForecast() => WeatherForecastModel(days: [
        DailyForecast(
          date: DateTime(2024, 6, 1),
          tempMax: 35.0,
          tempMin: 26.0,
          precipitationSum: 0.0,
        ),
      ]);

  setUp(() {
    mockGetNearestArea = MockGetNearestAreaUseCase();
    mockGetLatestNotification = MockGetLatestNotificationUseCase();
    mockGetWeatherForecast = MockGetWeatherForecastUseCase();

    controller = HomeController(
      getNearestArea: mockGetNearestArea,
      getLatestNotification: mockGetLatestNotification,
      getWeatherForecast: mockGetWeatherForecast,
    );
  });

  test('initial state is loading', () {
    expect(controller.state.nearestArea, isA<AsyncLoading>());
    expect(controller.state.latestNotification, isA<AsyncLoading>());
    expect(controller.state.weatherForecast, isA<AsyncLoading>());
  });

  test('loadHomeData populates all three fields on success', () async {
    when(mockGetNearestArea.execute(any, radiusKm: anyNamed('radiusKm')))
        .thenAnswer((_) async => fakeArea());
    when(mockGetLatestNotification.execute(any))
        .thenAnswer((_) async => NotificationModel(
              id: 'n1',
              title: 'Alert',
              body: 'body',
              sentAt: DateTime(2024, 6, 1),
            ));
    when(mockGetWeatherForecast.execute(any))
        .thenAnswer((_) async => fakeForecast());

    await controller.loadHomeData(userLocation);

    expect(controller.state.nearestArea.value?.id, 'a1');
    expect(controller.state.latestNotification.value?.title, 'Alert');
    expect(controller.state.weatherForecast.value?.days.length, 1);
  });

  test('empty areas — nearestArea is null, downstream is data(null) not error',
      () async {
    when(mockGetNearestArea.execute(any, radiusKm: anyNamed('radiusKm')))
        .thenAnswer((_) async => null);

    await controller.loadHomeData(userLocation);

    expect(controller.state.nearestArea.value, isNull);
    expect(controller.state.latestNotification.value, isNull);
    expect(controller.state.weatherForecast.value, isNull);
  });

  test('getNearestArea failure sets nearestArea error, others data(null)',
      () async {
    when(mockGetNearestArea.execute(any, radiusKm: anyNamed('radiusKm')))
        .thenThrow(Exception('Firestore down'));

    await controller.loadHomeData(userLocation);

    expect(controller.state.nearestArea, isA<AsyncError>());
    expect(controller.state.latestNotification.value, isNull);
    expect(controller.state.weatherForecast.value, isNull);
  });

  test('weather timeout sets weatherForecast error without affecting notification',
      () async {
    when(mockGetNearestArea.execute(any, radiusKm: anyNamed('radiusKm')))
        .thenAnswer((_) async => fakeArea());
    when(mockGetLatestNotification.execute(any)).thenAnswer((_) async => null);
    when(mockGetWeatherForecast.execute(any))
        .thenAnswer((_) async => throw Exception('timeout'));

    await controller.loadHomeData(userLocation);

    expect(controller.state.weatherForecast, isA<AsyncError>());
    expect(controller.state.latestNotification.value, isNull);
  });
}
