import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Represents a single location sample with timestamp
@immutable
class LocationSample {
  const LocationSample({
    required this.userId,
    required this.lat,
    required this.lng,
    required this.timestamp,
    this.accuracy,
  });

  final int userId;
  final double lat;
  final double lng;
  final DateTime timestamp;
  final double? accuracy; // accuracy in meters

  LatLng get position => LatLng(lat, lng);

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'lat': lat,
        'lng': lng,
        'timestamp': timestamp.toIso8601String(),
        'accuracy': accuracy,
      };

  static LocationSample fromJson(Map<String, dynamic> json) {
    return LocationSample(
      userId: json['userId'] as int,
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
      accuracy: json['accuracy'] != null ? (json['accuracy'] as num).toDouble() : null,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocationSample &&
          runtimeType == other.runtimeType &&
          userId == other.userId &&
          lat == other.lat &&
          lng == other.lng &&
          timestamp == other.timestamp;

  @override
  int get hashCode => Object.hash(userId, lat, lng, timestamp);
}

/// Represents a crossed path event between two users
@immutable
class CrossedPath {
  const CrossedPath({
    required this.otherUserId,
    required this.timestamp,
    required this.distance,
    required this.myLocation,
    required this.theirLocation,
  });

  final int otherUserId;
  final DateTime timestamp;
  final double distance; // in meters
  final LatLng myLocation;
  final LatLng theirLocation;

  Map<String, dynamic> toJson() => {
        'otherUserId': otherUserId,
        'timestamp': timestamp.toIso8601String(),
        'distance': distance,
        'myLocation': {'lat': myLocation.latitude, 'lng': myLocation.longitude},
        'theirLocation': {'lat': theirLocation.latitude, 'lng': theirLocation.longitude},
      };

  static CrossedPath fromJson(Map<String, dynamic> json) {
    final myLoc = json['myLocation'] as Map<String, dynamic>;
    final theirLoc = json['theirLocation'] as Map<String, dynamic>;
    return CrossedPath(
      otherUserId: json['otherUserId'] as int,
      timestamp: DateTime.parse(json['timestamp'] as String),
      distance: (json['distance'] as num).toDouble(),
      myLocation: LatLng(
        (myLoc['lat'] as num).toDouble(),
        (myLoc['lng'] as num).toDouble(),
      ),
      theirLocation: LatLng(
        (theirLoc['lat'] as num).toDouble(),
        (theirLoc['lng'] as num).toDouble(),
      ),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CrossedPath &&
          runtimeType == other.runtimeType &&
          otherUserId == other.otherUserId &&
          timestamp == other.timestamp;

  @override
  int get hashCode => Object.hash(otherUserId, timestamp);
}

/// Configuration for crossed paths detection
class CrossedPathsConfig {
  const CrossedPathsConfig({
    this.proximityRadius = 15.0, // meters
    this.timeWindow = const Duration(minutes: 5),
    this.minLocationSamples = 2,
  });

  final double proximityRadius;
  final Duration timeWindow;
  final int minLocationSamples;

  CrossedPathsConfig copyWith({
    double? proximityRadius,
    Duration? timeWindow,
    int? minLocationSamples,
  }) {
    return CrossedPathsConfig(
      proximityRadius: proximityRadius ?? this.proximityRadius,
      timeWindow: timeWindow ?? this.timeWindow,
      minLocationSamples: minLocationSamples ?? this.minLocationSamples,
    );
  }
}