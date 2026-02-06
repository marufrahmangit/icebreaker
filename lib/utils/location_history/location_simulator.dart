import 'dart:math';
import 'location_history.dart';

/// Generates realistic simulated location history for testing
class LocationHistorySimulator {
  LocationHistorySimulator({Random? random})
      : _random = random ?? Random();

  final Random _random;

  /// Generate simulated location history for multiple users over a time period
  List<LocationSample> generateLocationHistory({
    required List<UserBaseLocation> users,
    required DateTime startTime,
    required Duration duration,
    int samplesPerHour = 12, // One sample every 5 minutes
  }) {
    final samples = <LocationSample>[];
    final totalHours = duration.inHours;

    for (final user in users) {
      final userSamples = _generateUserPath(
        userId: user.userId,
        baseLat: user.lat,
        baseLng: user.lng,
        startTime: startTime,
        hours: totalHours,
        samplesPerHour: samplesPerHour,
        movementRadius: user.movementRadius,
        activityLevel: user.activityLevel,
      );

      samples.addAll(userSamples);
    }

    return samples..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  List<LocationSample> _generateUserPath({
    required int userId,
    required double baseLat,
    required double baseLng,
    required DateTime startTime,
    required int hours,
    required int samplesPerHour,
    required double movementRadius,
    required double activityLevel,
  }) {
    final samples = <LocationSample>[];
    final totalSamples = hours * samplesPerHour;

    var currentLat = baseLat;
    var currentLng = baseLng;

    for (var i = 0; i < totalSamples; i++) {
      final timestamp = startTime.add(
        Duration(minutes: i * (60 ~/ samplesPerHour)),
      );

      if (_random.nextDouble() > activityLevel) continue;

      final drift = _calculateDrift(movementRadius);
      currentLat += drift.latDelta;
      currentLng += drift.lngDelta;

      final distanceFromBase = _haversineDistance(
        baseLat, baseLng, currentLat, currentLng,
      );

      if (distanceFromBase > movementRadius) {
        final factor = movementRadius / distanceFromBase;
        currentLat = baseLat + (currentLat - baseLat) * factor;
        currentLng = baseLng + (currentLng - baseLng) * factor;
      }

      samples.add(
        LocationSample(
          userId: userId,
          lat: currentLat,
          lng: currentLng,
          timestamp: timestamp,
          accuracy: 5.0 + _random.nextDouble() * 15.0,
        ),
      );
    }

    return samples;
  }

  _DriftResult _calculateDrift(double maxRadius) {
    final maxDegrees = maxRadius / 111000.0 * 0.1;
    final angle = _random.nextDouble() * 2 * pi;
    final distance = _random.nextDouble() * maxDegrees;

    return _DriftResult(
      latDelta: cos(angle) * distance,
      lngDelta: sin(angle) * distance,
    );
  }

  double _haversineDistance(double lat1, double lng1, double lat2, double lng2) {
    const earthRadiusMeters = 6378137.0;
    final dLat = _toRadians(lat2 - lat1);
    final dLng = _toRadians(lng2 - lng1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLng / 2) *
            sin(dLng / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadiusMeters * c;
  }

  double _toRadians(double degrees) => degrees * pi / 180.0;

  /// Create crossing events between specific users (for demo)
  List<LocationSample> injectCrossings({
    required List<UserCrossingConfig> crossings,
    required DateTime baseTime,
  }) {
    final samples = <LocationSample>[];

    for (final crossing in crossings) {
      final crossingTime = baseTime.add(crossing.timeOffset);
      final numSamples = 3 + _random.nextInt(3);

      for (var i = 0; i < numSamples; i++) {
        final timeOffset = Duration(minutes: -5 + i * 2);
        final latVariation = (_random.nextDouble() - 0.5) * 0.00002;
        final lngVariation = (_random.nextDouble() - 0.5) * 0.00002;

        samples.add(
          LocationSample(
            userId: crossing.userId1,
            lat: crossing.lat + latVariation,
            lng: crossing.lng + lngVariation,
            timestamp: crossingTime.add(timeOffset),
            accuracy: 5.0 + _random.nextDouble() * 5.0,
          ),
        );

        samples.add(
          LocationSample(
            userId: crossing.userId2,
            lat: crossing.lat + latVariation + (_random.nextDouble() - 0.5) * 0.00001,
            lng: crossing.lng + lngVariation + (_random.nextDouble() - 0.5) * 0.00001,
            timestamp: crossingTime.add(timeOffset).add(
              Duration(seconds: _random.nextInt(60)),
            ),
            accuracy: 5.0 + _random.nextDouble() * 5.0,
          ),
        );
      }
    }

    return samples;
  }
}

class UserBaseLocation {
  const UserBaseLocation({
    required this.userId,
    required this.lat,
    required this.lng,
    this.movementRadius = 500.0,
    this.activityLevel = 0.8,
  });

  final int userId;
  final double lat;
  final double lng;
  final double movementRadius;
  final double activityLevel;
}

class UserCrossingConfig {
  const UserCrossingConfig({
    required this.userId1,
    required this.userId2,
    required this.lat,
    required this.lng,
    required this.timeOffset,
  });

  final int userId1;
  final int userId2;
  final double lat;
  final double lng;
  final Duration timeOffset;
}

class _DriftResult {
  const _DriftResult({
    required this.latDelta,
    required this.lngDelta,
  });

  final double latDelta;
  final double lngDelta;
}