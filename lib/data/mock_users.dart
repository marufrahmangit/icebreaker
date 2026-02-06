import 'dart:math';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/ice_user.dart';

/* ============================================================
   MOCK USER DATA BUILDER
   60 simulated users centered around Sydney.
   - lat/lng represent the user's real location.
   - No spoofed locations; just actual coordinates.
   ============================================================ */

const double kMeLat = -33.8688;
const double kMeLng = 151.2093;

const IceUser kMeUser = IceUser(
  id: 0,
  name: 'Username (You)',
  lat: kMeLat,
  lng: kMeLng,
  interests: ['AI', 'Clubbing', 'Tech'],
  // spark: 75,  // Spark points – commented out
  statusType: StatusType.open,
  bio: "Let's make new connections in Sydney!",
  age: 26,
  gender: 'Male',
  me: true,
  willAcceptMeet: true,
);

/// Builds a list of 60 users including the "me" user.
List<IceUser> buildMockUsers() {
  final rng = Random(42);

  final base = <IceUser>[
    kMeUser,

    // Sophie – will ACCEPT meet request
    const IceUser(
      id: 1,
      name: 'Sophie',
      lat: -33.8731,
      lng: 151.2060,
      interests: ['Yoga', 'Travel'],
      // spark: 31,
      statusType: StatusType.open,
      bio: 'Always up for coffee & deep chats!',
      age: 24,
      gender: 'Female',
      willAcceptMeet: true,
    ),

    // Liam – will DECLINE meet request
    const IceUser(
      id: 2,
      name: 'Liam',
      lat: -33.8680,
      lng: 151.2200,
      interests: ['EDM', 'Techno'],
      // spark: 12,
      statusType: StatusType.shy,
      bio: 'Love dancing. Ask me for a playlist!',
      age: 27,
      gender: 'Male',
      willAcceptMeet: false,
    ),

    // Ava – will ACCEPT
    const IceUser(
      id: 3,
      name: 'Ava',
      lat: -33.8615,
      lng: 151.2100,
      interests: ['Art', 'Clubbing'],
      // spark: 43,
      statusType: StatusType.curious,
      bio: 'Catch me at Oxford Art Factory!',
      age: 23,
      gender: 'Female',
      willAcceptMeet: true,
    ),

    // Jayden – will DECLINE
    const IceUser(
      id: 4,
      name: 'Jayden',
      lat: -33.8708,
      lng: 151.2000,
      interests: ['Gaming', 'Anime'],
      // spark: 56,
      statusType: StatusType.busy,
      bio: 'Manga, games, and memes.',
      age: 28,
      gender: 'Male',
      willAcceptMeet: false,
    ),

    // Maya – will ACCEPT
    const IceUser(
      id: 5,
      name: 'Maya',
      lat: -33.8679,
      lng: 151.2131,
      interests: ['Coffee', 'Markets'],
      // spark: 44,
      statusType: StatusType.open,
      bio: "Down for a quick hello 👋",
      age: 25,
      gender: 'Female',
      willAcceptMeet: true,
    ),

    // Ethan – will ACCEPT
    const IceUser(
      id: 6,
      name: 'Ethan',
      lat: -33.8702,
      lng: 151.2110,
      interests: ['Tech', 'Comedy'],
      // spark: 52,
      statusType: StatusType.curious,
      bio: "New to the area 👋 wave at me!",
      age: 29,
      gender: 'Male',
      willAcceptMeet: true,
    ),

    // Zara – will DECLINE
    const IceUser(
      id: 7,
      name: 'Zara',
      lat: -33.8682,
      lng: 151.2069,
      interests: ['Photography', 'Travel'],
      // spark: 36,
      statusType: StatusType.shy,
      bio: "I'm shy but friendly 🙂",
      age: 22,
      gender: 'Female',
      willAcceptMeet: false,
    ),

    // Noah – will ACCEPT
    const IceUser(
      id: 8,
      name: 'Noah',
      lat: -33.8669,
      lng: 151.2099,
      interests: ['EDM', 'Dance'],
      // spark: 61,
      statusType: StatusType.open,
      bio: "Music lover. Wave if you like EDM!",
      age: 26,
      gender: 'Male',
      willAcceptMeet: true,
    ),

    // Kai – will DECLINE
    const IceUser(
      id: 9,
      name: 'Kai',
      lat: -33.8695,
      lng: 151.2144,
      interests: ['Fitness', 'Beach'],
      // spark: 28,
      statusType: StatusType.busy,
      bio: "Busy today but open to a quick wave.",
      age: 30,
      gender: 'Non-binary',
      willAcceptMeet: false,
    ),

    // Priya – will ACCEPT
    const IceUser(
      id: 10,
      name: 'Priya',
      lat: -33.8711,
      lng: 151.2086,
      interests: ['Food', 'Movies'],
      // spark: 47,
      statusType: StatusType.curious,
      bio: "Tell me your fave movie 🎬",
      age: 27,
      gender: 'Female',
      willAcceptMeet: true,
    ),
  ];

  // ── Name / interest / gender pools for random fill ──

  final names = [
    "Ella", "Noah", "Grace", "Mason", "Ruby", "Jack", "Chloe", "Lucas",
    "Harper", "Zoe", "Oscar", "Mia", "Olivia", "Hugo", "Matilda", "Archie",
    "Willow", "Max", "Hazel", "Charlie", "Maddie", "Ethan", "Jasmine",
    "Carter", "Aaliyah", "Flynn", "Poppy", "Zac", "Georgia", "Blake",
    "Hannah", "Aiden", "Summer", "Luca", "Evie", "Jordan", "Paige",
    "Cooper", "Aria", "Xavier", "Layla", "Felix", "Lily", "Harrison",
    "Eliza", "Jake", "Joel", "Ava-Rose", "Theo", "Ivy",
  ];

  final interestsPool = [
    "Food", "Photography", "Movies", "Markets", "Running", "Beach",
    "Comedy", "Dance", "Tech", "Outdoors", "Yoga", "Travel", "EDM",
    "Gaming", "Anime", "Art", "Coffee", "Fitness",
  ];

  final gendersPool = ["Male", "Female", "Non-binary"];

  StatusType randStatus() => StatusType.values[rng.nextInt(StatusType.values.length)];

  int nextId = 11;
  while (base.length < 60) {
    final n = names[rng.nextInt(names.length)];
    final realPos = _randomLandPoint(rng);
    final i1 = interestsPool[rng.nextInt(interestsPool.length)];
    final i2 = interestsPool[rng.nextInt(interestsPool.length)];
    final age = 18 + rng.nextInt(43);
    final gender = gendersPool[rng.nextInt(gendersPool.length)];
    final willAccept = rng.nextBool();

    base.add(
      IceUser(
        id: nextId++,
        name: n,
        lat: realPos.latitude,
        lng: realPos.longitude,
        interests: {i1, i2}.toList(),
        // spark: 10 + rng.nextInt(70), // Spark points – commented out
        statusType: randStatus(),
        bio: "Wave 👋 to connect",
        age: age,
        gender: gender,
        willAcceptMeet: willAccept,
      ),
    );
  }

  return base;
}

/// Generate a random LatLng within land areas around Sydney.
LatLng _randomLandPoint(Random rng) {
  const landBoxes = [
    [-33.903, -33.865, 151.195, 151.235],
    [-33.930, -33.870, 151.115, 151.185],
    [-33.945, -33.885, 151.215, 151.275],
    [-33.840, -33.780, 151.145, 151.220],
    [-33.980, -33.920, 151.135, 151.220],
  ];

  final box = landBoxes[rng.nextInt(landBoxes.length)];
  final lat = box[0] + rng.nextDouble() * (box[1] - box[0]);
  final lng = box[2] + rng.nextDouble() * (box[3] - box[2]);
  return LatLng(lat, lng);
}