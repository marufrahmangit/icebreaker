import 'dart:math';

/// Haversine distance in meters between two lat/lng points.
double distanceMeters(double lat1, double lng1, double lat2, double lng2) {
  const R = 6378137.0;
  final dLat = _toRad(lat2 - lat1);
  final dLng = _toRad(lng2 - lng1);
  final a1 = _toRad(lat1);
  final a2 = _toRad(lat2);

  final sinLat = sin(dLat / 2);
  final sinLng = sin(dLng / 2);
  final h = sinLat * sinLat + cos(a1) * cos(a2) * sinLng * sinLng;
  return 2 * R * atan2(sqrt(h), sqrt(1 - h));
}

double _toRad(double d) => d * pi / 180.0;

String prettyDistance(double meters) {
  if (meters < 1000) return "${meters.toStringAsFixed(0)} m away";
  return "~${(meters / 1000).toStringAsFixed(2)} km away";
}