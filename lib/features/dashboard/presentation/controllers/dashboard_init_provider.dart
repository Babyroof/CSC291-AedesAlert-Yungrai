import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:aedes_alert_yungrai/features/dashboard/presentation/controllers/dashboard_controller.dart';

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

  await ref
      .read(dashboardControllerProvider.notifier)
      .loadDashboard(userLocation: location);
});
