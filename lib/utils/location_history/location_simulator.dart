import 'dart:math';
import 'location_history.dart';

/// Generates realistic simulated location history for testing
class LocationHistorySimulator {
  LocationHistorySimulator({Random? random})
      : _random = random ?? Random();

  final Random _random;

  /// Generate simulated location history for multiple users over a time period
  /// 
  /// This creates realistic movement patterns where users:
  /// - Move around their base location
  /// - Occasionally cross paths with others
  /// - Have varying activity levels
  List<LocationSample> generateLocationHistory({
    required List<UserBaseLocation> users,
    required DateTime startTime,
    required Duration duration,
    int samplesPerHour = 12, // One sample every 5 minutes
  }) {
    final samples = <LocationSample>[];
    final totalHours = duration.inHours;

    for (final user in users) {
      // Generate movement path for this user
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

  /// Generate a realistic movement path for a single user
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
    
    // Current position (starts at base location)
    var currentLat = baseLat;
    var currentLng = baseLng;

    for (var i = 0; i < totalSamples; i++) {
      final timestamp = startTime.add(
        Duration(minutes: i * (60 ~/ samplesPerHour)),
      );

      // Skip some samples based on activity level (simulate being offline)
      if (_random.nextDouble() > activityLevel) {
        continue;
      }

      // Add some natural drift/movement
      final drift = _calculateDrift(movementRadius);
      currentLat += drift.latDelta;
      currentLng += drift.lngDelta;

      // Keep within movement radius of base location
      final distanceFromBase = _haversineDistance(
        baseLat,
        baseLng,
        currentLat,
        currentLng,
      );

      if (distanceFromBase > movementRadius) {
        // Pull back towards base
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
          accuracy: 5.0 + _random.nextDouble() * 15.0, // 5-20m accuracy
        ),
      );
    }

    return samples;
  }

  /// Calculate random drift for movement simulation
  _DriftResult _calculateDrift(double maxRadius) {
    // Convert meters to approximate degrees
    // At equator: 1 degree lat ≈ 111km, 1 degree lng ≈ 111km
    // We want movement in meters
    final maxDegrees = maxRadius / 111000.0 * 0.1; // 10% of radius per step

    final angle = _random.nextDouble() * 2 * pi;
    final distance = _random.nextDouble() * maxDegrees;

    return _DriftResult(
      latDelta: cos(angle) * distance,
      lngDelta: sin(angle) * distance,
    );
  }

  /// Calculate distance in meters using Haversine formula
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

  /// Create crossing events between specific users
  /// This ensures some users definitely cross paths for demo purposes
  List<LocationSample> injectCrossings({
    required List<UserCrossingConfig> crossings,
    required DateTime baseTime,
  }) {
    final samples = <LocationSample>[];

    for (final crossing in crossings) {
      // Create a cluster of samples around the crossing point
      final crossingTime = baseTime.add(crossing.timeOffset);
      final numSamples = 3 + _random.nextInt(3); // 3-5 samples

      for (var i = 0; i < numSamples; i++) {
        final timeOffset = Duration(
          minutes: -5 + i * 2, // Spread over ~10 minutes
        );

        // Add slight position variation to make it realistic
        final latVariation = (_random.nextDouble() - 0.5) * 0.00002; // ~2 meters
        final lngVariation = (_random.nextDouble() - 0.5) * 0.00002;

        // User 1 sample
        samples.add(
          LocationSample(
            userId: crossing.userId1,
            lat: crossing.lat + latVariation,
            lng: crossing.lng + lngVariation,
            timestamp: crossingTime.add(timeOffset),
            accuracy: 5.0 + _random.nextDouble() * 5.0,
          ),
        );

        // User 2 sample (very close to user 1)
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

/// Configuration for a user's base location and movement pattern
class UserBaseLocation {
  const UserBaseLocation({
    required this.userId,
    required this.lat,
    required this.lng,
    this.movementRadius = 500.0, // meters
    this.activityLevel = 0.8, // 0.0 to 1.0
  });

  final int userId;
  final double lat;
  final double lng;
  final double movementRadius;
  final double activityLevel;
}

/// Configuration for an intentional crossing between two users
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

/// Result of drift calculation
class _DriftResult {
  const _DriftResult({
    required this.latDelta,
    required this.lngDelta,
  });

  final double latDelta;
  final double lngDelta;
}