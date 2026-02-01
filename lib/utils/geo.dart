import 'dart:math';

/// Haversine distance in meters.
double distanceMeters({
  required double lat1,
  required double lng1,
  required double lat2,
  required double lng2,
}) {
  double toRad(double x) => x * pi / 180.0;
  const r = 6378137.0;
  final dLat = toRad(lat2 - lat1);
  final dLng = toRad(lng2 - lng1);
  final a = sin(dLat / 2) * sin(dLat / 2) +
      cos(toRad(lat1)) * cos(toRad(lat2)) * sin(dLng / 2) * sin(dLng / 2);
  final c = 2 * atan2(sqrt(a), sqrt(1 - a));
  return r * c;
}

String prettyDistance(double meters) {
  if (meters < 1000) return '${meters.toStringAsFixed(0)} m';
  return '~${(meters / 1000).toStringAsFixed(2)} km';
}
