import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';

abstract class GeoUtils {
  static GeoFirePoint toGeoFirePoint(GeoPoint geoPoint) =>
      GeoFirePoint(geoPoint);

  static double distanceInKm(GeoPoint a, GeoPoint b) {
    const double earthRadius = 6371.0;
    final double lat1 = a.latitude * pi / 180;
    final double lat2 = b.latitude * pi / 180;
    final double deltaLat = (b.latitude - a.latitude) * pi / 180;
    final double deltaLon = (b.longitude - a.longitude) * pi / 180;
    final double sinDLat = sin(deltaLat / 2);
    final double sinDLon = sin(deltaLon / 2);
    final double h =
        sinDLat * sinDLat + cos(lat1) * cos(lat2) * sinDLon * sinDLon;
    return earthRadius * 2 * atan2(sqrt(h), sqrt(1 - h));
  }

  static int nearestIndex(GeoPoint origin, List<GeoPoint> points) {
    if (points.isEmpty) return -1;
    int nearest = 0;
    double minDist = distanceInKm(origin, points[0]);
    for (int i = 1; i < points.length; i++) {
      final double dist = distanceInKm(origin, points[i]);
      if (dist < minDist) {
        minDist = dist;
        nearest = i;
      }
    }
    return nearest;
  }
}
