import 'package:flutter/foundation.dart';

enum StatusType { open, shy, curious, busy }

@immutable
class IceUser {
  const IceUser({
    required this.id,
    required this.name,
    required this.lat,
    required this.lng,
    required this.interests,
    required this.sparkPoints,
    required this.statusType,
    required this.bio,
    required this.isMe,
  });

  final int id;
  final String name;
  final double lat;
  final double lng;
  final List<String> interests;
  final int sparkPoints;
  final StatusType statusType;
  final String bio;
  final bool isMe;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'lat': lat,
        'lng': lng,
        'interests': interests,
        'sparkPoints': sparkPoints,
        'statusType': statusType.name,
        'bio': bio,
        'isMe': isMe,
      };

  static IceUser fromJson(Map<String, dynamic> json) {
    final st = StatusType.values.firstWhere(
      (e) => e.name == (json['statusType'] as String),
      orElse: () => StatusType.open,
    );
    return IceUser(
      id: json['id'] as int,
      name: json['name'] as String,
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      interests: (json['interests'] as List).map((e) => e.toString()).toList(),
      sparkPoints: json['sparkPoints'] as int,
      statusType: st,
      bio: json['bio'] as String,
      isMe: json['isMe'] as bool,
    );
  }
}
