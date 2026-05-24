import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aedes_alert_yungrai/features/home/domain/entities/location_entity.dart';
import 'package:aedes_alert_yungrai/features/home/domain/use_cases/get_user_location_use_case.dart';
import 'package:aedes_alert_yungrai/features/home/presentation/controllers/home_controller.dart';

final userLocationProvider = FutureProvider<LocationEntity>((ref) async {
  return ref.watch(getUserLocationUseCaseProvider).execute();
});

final homeAutoLoadProvider = Provider<void>((ref) {
  final locationAsync = ref.watch(userLocationProvider);
  locationAsync.whenData((loc) {
    final geoPoint = GeoPoint(loc.latitude, loc.longitude);
    ref.read(homeControllerProvider.notifier).loadHomeData(geoPoint);
  });
});
