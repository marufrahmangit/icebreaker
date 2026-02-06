import 'package:google_maps_flutter/google_maps_flutter.dart';

/* ============================================================
   USER MODEL + STATUS ENUM
   ============================================================ */

enum StatusType { open, shy, curious, busy }

class IceUser {
  final int id;
  final String name;
  final double lat;
  final double lng;
  final List<String> interests;
  // final int spark; // Spark points – commented out, not used for now
  final StatusType statusType;
  final String bio;
  final bool me;

  final int age;
  final String gender;

  // For demo: pre-determined whether this user will accept meet requests
  final bool willAcceptMeet;

  const IceUser({
    required this.id,
    required this.name,
    required this.lat,
    required this.lng,
    required this.interests,
    // required this.spark, // Spark points – commented out
    required this.statusType,
    required this.bio,
    required this.age,
    required this.gender,
    this.me = false,
    this.willAcceptMeet = true,
  });

  LatLng get pos => LatLng(lat, lng);
}

/* ============================================================
   FILTERS
   ============================================================ */

class Filters {
  final int minAge;
  final int maxAge;
  final Set<String> genders;

  const Filters({
    required this.minAge,
    required this.maxAge,
    required this.genders,
  });

  bool matches(IceUser u) {
    if (u.me) return true;
    if (u.age < minAge || u.age > maxAge) return false;
    if (genders.isEmpty) return true;
    return genders.contains(u.gender);
  }
}