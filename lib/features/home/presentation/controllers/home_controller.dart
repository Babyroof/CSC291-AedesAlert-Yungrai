import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aedes_alert_yungrai/features/home/data/models/area_model.dart';
import 'package:aedes_alert_yungrai/features/home/presentation/controllers/home_state.dart';
import 'package:aedes_alert_yungrai/features/home/domain/use_cases/get_nearest_area_use_case.dart';
import 'package:aedes_alert_yungrai/features/home/domain/use_cases/get_latest_notification_use_case.dart';
import 'package:aedes_alert_yungrai/features/home/domain/use_cases/get_weather_forecast_use_case.dart';
import 'package:aedes_alert_yungrai/features/home/domain/use_cases/get_latest_area_for_district_use_case.dart';

class HomeController extends StateNotifier<HomeState> {
  HomeController({
    required GetNearestAreaUseCase getNearestArea,
    required GetLatestNotificationUseCase getLatestNotification,
    required GetWeatherForecastUseCase getWeatherForecast,
    required GetLatestAreaForDistrictUseCase getLatestAreaForDistrict,
  }) : _getNearestArea = getNearestArea,
       _getLatestNotification = getLatestNotification,
       _getWeatherForecast = getWeatherForecast,
       _getLatestAreaForDistrict = getLatestAreaForDistrict,
       super(HomeState.initial());

  final GetNearestAreaUseCase _getNearestArea;
  final GetLatestNotificationUseCase _getLatestNotification;
  final GetWeatherForecastUseCase _getWeatherForecast;
  final GetLatestAreaForDistrictUseCase _getLatestAreaForDistrict;

  Future<void> loadHomeData(GeoPoint userLocation) async {
    state = HomeState.initial();

    // Step 1: resolve the nearest area (already filtered to isLatest == true
    // by AreaRepositoryImpl.getNearestArea).
    AreaModel? area;
    try {
      area = await _getNearestArea.execute(userLocation);
      state = state.copyWith(nearestArea: AsyncValue.data(area));
    } catch (e, st) {
      state = state.copyWith(
        nearestArea: AsyncValue.error(e, st),
        latestNotification: const AsyncValue.data(null),
        weatherForecast: const AsyncValue.data(null),
        latestDistrictArea: const AsyncValue.data(null),
      );
      return;
    }

    if (area == null) {
      state = state.copyWith(
        latestNotification: const AsyncValue.data(null),
        weatherForecast: const AsyncValue.data(null),
        latestDistrictArea: const AsyncValue.data(null),
      );
      return;
    }

    // Step 2: fetch notification, weather, and latest district area in parallel.
    final district = area.district;
    await Future.wait([
      _getLatestNotification
          .execute(area.id)
          .then(
            (n) =>
                state = state.copyWith(latestNotification: AsyncValue.data(n)),
            onError: (Object e, StackTrace st) => state = state.copyWith(
              latestNotification: AsyncValue.error(e, st),
            ),
          ),
      _getWeatherForecast
          .execute(area.location)
          .then(
            (w) => state = state.copyWith(weatherForecast: AsyncValue.data(w)),
            onError: (Object e, StackTrace st) => state = state.copyWith(
              weatherForecast: AsyncValue.error(e, st),
            ),
          ),
      _getLatestAreaForDistrict
          .execute(district)
          .then(
            (a) => state =
                state.copyWith(latestDistrictArea: AsyncValue.data(a)),
            onError: (Object e, StackTrace st) => state = state.copyWith(
              latestDistrictArea: AsyncValue.error(e, st),
            ),
          ),
    ]);
  }

  Future<void> refresh(GeoPoint userLocation) => loadHomeData(userLocation);
}

final homeControllerProvider = StateNotifierProvider<HomeController, HomeState>(
  (ref) {
    return HomeController(
      getNearestArea: ref.watch(getNearestAreaUseCaseProvider),
      getLatestNotification: ref.watch(getLatestNotificationUseCaseProvider),
      getWeatherForecast: ref.watch(getWeatherForecastUseCaseProvider),
      getLatestAreaForDistrict:
          ref.watch(getLatestAreaForDistrictUseCaseProvider),
    );
  },
);