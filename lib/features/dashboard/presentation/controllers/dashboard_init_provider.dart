import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:aedes_alert_yungrai/features/dashboard/presentation/controllers/dashboard_controller.dart';
import 'package:aedes_alert_yungrai/features/home/presentation/controllers/home_controller.dart';

/// A [FutureProvider] that runs exactly once per provider lifetime.
/// Watching it inside `build()` is safe — the async work only executes the
/// first time the provider is created, not on every rebuild.
final dashboardInitProvider = FutureProvider<void>((ref) async {
  GeoPoint? location;
  try {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    final position = await Geolocator.getCurrentPosition();
    location = GeoPoint(position.latitude, position.longitude);
  } catch (_) {
    // Location unavailable — chart will show all districts (safe fallback).
  }

  // Derive the user's district from the home controller state.
  // Prefer the dedicated latestDistrictArea (most-recent isLatest record for
  // the district), falling back to the nearest area if that hasn't loaded yet.
  final homeState = ref.read(homeControllerProvider);
  final String? userDistrict =
      homeState.latestDistrictArea.valueOrNull?.district ??
      homeState.nearestArea.valueOrNull?.district;

  // Pass selectedMonthKey = null so GetDashboardSummaryUseCase auto-detects
  // the most-recent month that actually has data in Firestore.
  await ref
      .read(dashboardControllerProvider.notifier)
      .loadDashboard(userLocation: location, userDistrict: userDistrict);
});
