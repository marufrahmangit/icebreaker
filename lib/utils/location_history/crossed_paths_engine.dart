import 'dart:math' as math;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'location_history.dart';

/// Engine for detecting crossed paths between users
class CrossedPathsEngine {
  CrossedPathsEngine({
    CrossedPathsConfig? config,
  }) : config = config ?? const CrossedPathsConfig();

  final CrossedPathsConfig config;

  /// Calculate distance between two geographic points using Haversine formula
  double calculateDistance(LatLng point1, LatLng point2) {
    const earthRadiusMeters = 6378137.0;

    final lat1Rad = _degreesToRadians(point1.latitude);
    final lat2Rad = _degreesToRadians(point2.latitude);
    final deltaLatRad = _degreesToRadians(point2.latitude - point1.latitude);
    final deltaLngRad = _degreesToRadians(point2.longitude - point1.longitude);

    final a = math.sin(deltaLatRad / 2) * math.sin(deltaLatRad / 2) +
        math.cos(lat1Rad) *
            math.cos(lat2Rad) *
            math.sin(deltaLngRad / 2) *
            math.sin(deltaLngRad / 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadiusMeters * c;
  }

  double _degreesToRadians(double degrees) => degrees * math.pi / 180.0;

  /// Detect all crossed paths for a given user against all other users
  /// 
  /// Algorithm:
  /// 1. For each location sample from the target user
  /// 2. Find all location samples from other users within the time window
  /// 3. Calculate distance and check if within proximity radius
  /// 4. Deduplicate and sort by timestamp
  List<CrossedPath> detectCrossedPaths({
    required int targetUserId,
    required List<LocationSample> allLocationSamples,
  }) {
    // Separate target user's samples from others
    final targetSamples = allLocationSamples
        .where((sample) => sample.userId == targetUserId)
        .toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    final otherSamples = allLocationSamples
        .where((sample) => sample.userId != targetUserId)
        .toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    if (targetSamples.isEmpty || otherSamples.isEmpty) {
      return [];
    }

    final crossedPaths = <CrossedPath>[];
    final processedPairs = <String>{};

    // For each target location sample
    for (final targetSample in targetSamples) {
      // Find other user samples within time window
      final candidateSamples = _getSamplesInTimeWindow(
        targetSample.timestamp,
        otherSamples,
      );

      // Check proximity for each candidate
      for (final otherSample in candidateSamples) {
        final distance = calculateDistance(
          targetSample.position,
          otherSample.position,
        );

        // If within proximity radius, record the crossed path
        if (distance <= config.proximityRadius) {
          // Create unique key to avoid duplicates
          final pairKey = _createPairKey(
            targetUserId,
            otherSample.userId,
            targetSample.timestamp,
          );

          if (!processedPairs.contains(pairKey)) {
            crossedPaths.add(
              CrossedPath(
                otherUserId: otherSample.userId,
                timestamp: targetSample.timestamp,
                distance: distance,
                myLocation: targetSample.position,
                theirLocation: otherSample.position,
              ),
            );
            processedPairs.add(pairKey);
          }
        }
      }
    }

    // Sort by timestamp (most recent first)
    crossedPaths.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return crossedPaths;
  }

  /// Get location samples within the time window of a reference timestamp
  List<LocationSample> _getSamplesInTimeWindow(
    DateTime referenceTime,
    List<LocationSample> samples,
  ) {
    final windowStart = referenceTime.subtract(config.timeWindow);
    final windowEnd = referenceTime.add(config.timeWindow);

    return samples.where((sample) {
      return sample.timestamp.isAfter(windowStart) &&
          sample.timestamp.isBefore(windowEnd);
    }).toList();
  }

  /// Create a unique key for a user pair at a specific time
  /// This prevents duplicate entries for the same crossing event
  String _createPairKey(int userId1, int userId2, DateTime timestamp) {
    final sortedIds = [userId1, userId2]..sort();
    final timeKey = timestamp.millisecondsSinceEpoch ~/ 60000; // Round to minute
    return '${sortedIds[0]}_${sortedIds[1]}_$timeKey';
  }

  /// Group crossed paths by user ID
  Map<int, List<CrossedPath>> groupByUser(List<CrossedPath> paths) {
    final grouped = <int, List<CrossedPath>>{};

    for (final path in paths) {
      grouped.putIfAbsent(path.otherUserId, () => []).add(path);
    }

    return grouped;
  }

  /// Get summary statistics for crossed paths
  CrossedPathsSummary getSummary(List<CrossedPath> paths) {
    if (paths.isEmpty) {
      return const CrossedPathsSummary(
        totalCrossings: 0,
        uniqueUsers: 0,
        averageDistance: 0,
        closestDistance: 0,
        mostRecentCrossing: null,
      );
    }

    final uniqueUserIds = paths.map((p) => p.otherUserId).toSet();
    final distances = paths.map((p) => p.distance).toList();
    final averageDistance = distances.reduce((a, b) => a + b) / distances.length;
    final closestDistance = distances.reduce(math.min);
    final mostRecentCrossing = paths.first.timestamp;

    return CrossedPathsSummary(
      totalCrossings: paths.length,
      uniqueUsers: uniqueUserIds.length,
      averageDistance: averageDistance,
      closestDistance: closestDistance,
      mostRecentCrossing: mostRecentCrossing,
    );
  }
}

/// Summary statistics for crossed paths
class CrossedPathsSummary {
  const CrossedPathsSummary({
    required this.totalCrossings,
    required this.uniqueUsers,
    required this.averageDistance,
    required this.closestDistance,
    required this.mostRecentCrossing,
  });

  final int totalCrossings;
  final int uniqueUsers;
  final double averageDistance;
  final double closestDistance;
  final DateTime? mostRecentCrossing;
}