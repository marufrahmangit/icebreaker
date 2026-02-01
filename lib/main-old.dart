// ✅ Icebreaker main.dart (FULL FIXED + UPGRADED VERSION)
// Includes:
// - Onboarding (2 pages) ✅
// - Filters landing (Age + Gender) ✅
// - Landing screen fade into map ✅
// - Google Map with greedy gestures ✅
// - 60 simulated users (incl. 6 within ~800m of Rahul) ✅
// - Wave 👋 unlock system (Chat + Directions unlock only if they wave back) ✅
// - Emergency button ONLY on map ✅
// - Block button small in top-right of popup ✅
// - Glass popup card ✅
// - Chat modal (no emergency) ✅
// - FIX: 3 action buttons fit on same line ✅
// - ✅ NEW: Custom avatar markers (circular face + colored status ring; Me purple with white stroke) ✅

import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(const IcebreakerApp());

class IcebreakerApp extends StatelessWidget {
  const IcebreakerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Icebreaker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF7C3AED)),
        useMaterial3: true,
      ),
      home: const OnboardingScreen(),
    );
  }
}

/* ============================================================
   ONBOARDING (2 swipe pages)
   ============================================================ */
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _c = PageController();
  int index = 0;

  void _next() {
    if (index < 1) {
      _c.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const FiltersScreen()),
      );
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF8F4EED), Color(0xFF6A84F7)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: PageView(
                  controller: _c,
                  onPageChanged: (i) => setState(() => index = i),
                  children: const [
                    _OnboardPage(
                      icon: Icons.map_outlined,
                      title: "See people around you",
                      text: "Icebreaker shows people nearby on a live map.",
                    ),
                    _OnboardPage(
                      icon: Icons.chat_bubble_outline,
                      title: "Wave first, chat after",
                      text:
                      "Tap a person to see their vibe and interests. "
                          "Wave 👋 — if they wave back, Chat & Directions unlock.",
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  2,
                      (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    width: i == index ? 18 : 8,
                    height: 8,
                    margin: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: i == index ? Colors.white : Colors.white54,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _next,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF7C3AED),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    ),
                    child: Text(
                      index == 1 ? "Continue" : "Next",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardPage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String text;

  const _OnboardPage({
    required this.icon,
    required this.title,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(36),
            ),
            child: Icon(icon, color: Colors.white, size: 56),
          ),
          const SizedBox(height: 28),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 15.5,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

/* ============================================================
   FILTERS LANDING
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

class FiltersScreen extends StatefulWidget {
  const FiltersScreen({super.key});

  @override
  State<FiltersScreen> createState() => _FiltersScreenState();
}

class _FiltersScreenState extends State<FiltersScreen> {
  double _minAge = 18;
  double _maxAge = 35;

  bool male = true;
  bool female = true;
  bool nonBinary = true;

  void _start() {
    final genders = <String>{};
    if (male) genders.add('Male');
    if (female) genders.add('Female');
    if (nonBinary) genders.add('Non-binary');

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => _Root(
          filters: Filters(
            minAge: _minAge.round(),
            maxAge: _maxAge.round(),
            genders: genders,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ageLabel = "${_minAge.round()} - ${_maxAge.round()}";

    Widget chip2(String label, bool selected, VoidCallback onTap) {
      return GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF7C3AED) : Colors.white.withOpacity(0.22),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.35)),
          ),
          child: Text(
            label,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
          ),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF8F4EED), Color(0xFF6A84F7)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Filters",
                  style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 8),
                Text(
                  "Choose who you want to see nearby.",
                  style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14.5),
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: Colors.white.withOpacity(0.25)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Age range",
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        ageLabel,
                        style: const TextStyle(color: Colors.white, fontSize: 14.5, fontWeight: FontWeight.w800),
                      ),
                      RangeSlider(
                        values: RangeValues(_minAge, _maxAge),
                        min: 18,
                        max: 60,
                        divisions: 42,
                        onChanged: (v) => setState(() {
                          _minAge = v.start;
                          _maxAge = v.end;
                        }),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: Colors.white.withOpacity(0.25)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Gender",
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          chip2("Male", male, () => setState(() => male = !male)),
                          chip2("Female", female, () => setState(() => female = !female)),
                          chip2("Non-binary", nonBinary, () => setState(() => nonBinary = !nonBinary)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Tip: turn all off to show everyone.",
                        style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 12.5),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _start,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF7C3AED),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    ),
                    child: const Text(
                      "Start Icebreaker",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/* ============================================================
   ROOT (landing overlay + map)
   ============================================================ */
class _Root extends StatefulWidget {
  final Filters filters;
  const _Root({required this.filters});

  @override
  State<_Root> createState() => _RootState();
}

class _RootState extends State<_Root> {
  bool started = false;
  void _start() => setState(() => started = true);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        MapScreen(filters: widget.filters),
        AnimatedOpacity(
          opacity: started ? 0 : 1,
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeOut,
          child: IgnorePointer(
            ignoring: started,
            child: LandingScreen(onGetStarted: _start),
          ),
        ),
      ],
    );
  }
}

/* ============================================================
   LANDING
   ============================================================ */
class LandingScreen extends StatelessWidget {
  final VoidCallback onGetStarted;
  const LandingScreen({super.key, required this.onGetStarted});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF8F4EED), Color(0xFF6A84F7)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 26),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 92,
                    height: 92,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: const [
                        BoxShadow(
                          blurRadius: 28,
                          color: Color(0x335730A9),
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.ac_unit, color: Colors.white, size: 44),
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    'Icebreaker',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Meet new people nearby.\nStart real conversations.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.5,
                      height: 1.25,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 26),
                  SizedBox(
                    width: 220,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF7C3AED),
                        elevation: 6,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                      ),
                      onPressed: onGetStarted,
                      child: const Text('Get Started'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/* ============================================================
   USER MODEL + STATUS
   ============================================================ */
class IceUser {
  final int id;
  final String name;
  final double lat;
  final double lng;
  final List<String> interests;
  final int spark;
  final StatusType statusType;
  final String bio;
  final bool me;

  final int age;
  final String gender;

  const IceUser({
    required this.id,
    required this.name,
    required this.lat,
    required this.lng,
    required this.interests,
    required this.spark,
    required this.statusType,
    required this.bio,
    required this.age,
    required this.gender,
    this.me = false,
  });

  LatLng get pos => LatLng(lat, lng);
}

enum StatusType { open, shy, curious, busy }

Color statusColor(StatusType t) {
  switch (t) {
    case StatusType.open:
      return const Color(0xFF10B981);
    case StatusType.shy:
      return const Color(0xFFFBBF24);
    case StatusType.curious:
      return const Color(0xFF38BDF8);
    case StatusType.busy:
      return const Color(0xFFEF4444);
  }
}

String statusLabel(StatusType t) {
  switch (t) {
    case StatusType.open:
      return "Open";
    case StatusType.shy:
      return "Shy";
    case StatusType.curious:
      return "Curious";
    case StatusType.busy:
      return "Busy";
  }
}

/* ============================================================
   CUSTOM AVATAR MARKER FACTORY
   ============================================================ */
class _AvatarMarkerFactory {
  final Map<String, BitmapDescriptor> _cache = {};

  static const int _sizePx = 120;
  static const double _outerRing = 10;
  static const double _innerPadding = 8;

  Future<BitmapDescriptor> iconForUser({
    required IceUser user,
    required Color ringColor,
    required bool isMe,
  }) async {
    final key = '${user.id}_${ringColor.value}_${isMe ? "me" : "u"}';
    final cached = _cache[key];
    if (cached != null) return cached;

    final bytes = await _drawMarkerPng(
      initials: _initialsFromName(user.name),
      ringColor: ringColor,
      isMe: isMe,
    );

    final desc = BitmapDescriptor.fromBytes(bytes);
    _cache[key] = desc;
    return desc;
  }

  String _initialsFromName(String name) {
    final cleaned = name.replaceAll(RegExp(r'\(.*?\)'), '').trim();
    final parts = cleaned.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return "?";
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }

  Future<Uint8List> _drawMarkerPng({
    required String initials,
    required Color ringColor,
    required bool isMe,
  }) async {
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);

    final size = ui.Size(_sizePx.toDouble(), _sizePx.toDouble());
    final center = ui.Offset(size.width / 2, size.height / 2);

    // Outer ring
    final outerRadius = (size.width / 2);
    final ringPaint = ui.Paint()
      ..color = ringColor
      ..style = ui.PaintingStyle.fill
      ..isAntiAlias = true;
    canvas.drawCircle(center, outerRadius, ringPaint);

    // Inner avatar circle
    final innerRadius = outerRadius - _outerRing;

    final avatarPaint = ui.Paint()..isAntiAlias = true;

    if (isMe) {
      avatarPaint.color = const Color(0xFF7C3AED);
    } else {
      final shader = ui.Gradient.linear(
        const ui.Offset(0, 0),
        ui.Offset(size.width, size.height),
        const [
          Color(0xFFEFF6FF),
          Color(0xFFDDEAFE),
        ],
      );
      avatarPaint.shader = shader;
    }

    canvas.drawCircle(center, innerRadius, avatarPaint);

    // Me: white stroke ring
    if (isMe) {
      final strokePaint = ui.Paint()
        ..color = Colors.white
        ..style = ui.PaintingStyle.stroke
        ..strokeWidth = 6
        ..isAntiAlias = true;
      canvas.drawCircle(center, innerRadius - 2, strokePaint);
    }

    // Inner shadow (premium look)
    final shadowPaint = ui.Paint()
      ..color = Colors.black.withOpacity(0.10)
      ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 6)
      ..isAntiAlias = true;
    canvas.drawCircle(center.translate(0, 2), innerRadius - _innerPadding, shadowPaint);

    // Initials
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    textPainter.text = TextSpan(
      text: initials,
      style: TextStyle(
        fontSize: isMe ? 34 : 32,
        fontWeight: FontWeight.w900,
        color: isMe ? Colors.white : const Color(0xFF0F172A),
        letterSpacing: 1.0,
      ),
    );

    textPainter.layout(minWidth: 0, maxWidth: size.width);
    final offset = ui.Offset(
      center.dx - (textPainter.width / 2),
      center.dy - (textPainter.height / 2),
    );
    textPainter.paint(canvas, offset);

    final picture = recorder.endRecording();
    final img = await picture.toImage(_sizePx, _sizePx);
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }
}

/* ============================================================
   MAP SCREEN
   ============================================================ */
class MapScreen extends StatefulWidget {
  final Filters filters;
  const MapScreen({super.key, required this.filters});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  static const LatLng _sydney = LatLng(-33.8688, 151.2093);

  GoogleMapController? _controller;
  IceUser? _selected;
  bool _chatOpen = false;

  StatusType _myStatus = StatusType.open;

  late final List<IceUser> _users;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  final Set<int> _blockedIds = <int>{};

  final Map<int, bool> _waveSent = {};
  final Map<int, bool> _waveBack = {};

  // ✅ Custom avatar marker factory
  final _AvatarMarkerFactory _avatarMarkers = _AvatarMarkerFactory();

  @override
  void initState() {
    super.initState();
    _users = _buildUsers();
    _myStatus = _me.statusType;

    // Build markers async (because custom marker bitmaps require async work)
    Future.microtask(() async {
      await _buildMarkers();
      if (mounted) setState(() {});
    });
  }

  IceUser get _me => _users.firstWhere((u) => u.me);

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

  List<IceUser> _buildUsers() {
    const me = IceUser(
      id: 0,
      name: 'Rahul (You)',
      lat: -33.8688,
      lng: 151.2093,
      interests: ['AI', 'Clubbing', 'Tech'],
      spark: 75,
      statusType: StatusType.open,
      bio: 'Let’s make new connections in Sydney!',
      age: 26,
      gender: 'Male',
      me: true,
    );

    final base = <IceUser>[
      me,
      const IceUser(
        id: 1,
        name: 'Sophie',
        lat: -33.8731,
        lng: 151.2060,
        interests: ['Yoga', 'Travel'],
        spark: 31,
        statusType: StatusType.open,
        bio: 'Always up for coffee & deep chats!',
        age: 24,
        gender: 'Female',
      ),
      const IceUser(
        id: 2,
        name: 'Liam',
        lat: -33.8680,
        lng: 151.2200,
        interests: ['EDM', 'Techno'],
        spark: 12,
        statusType: StatusType.shy,
        bio: 'Love dancing. Ask me for a playlist!',
        age: 27,
        gender: 'Male',
      ),
      const IceUser(
        id: 3,
        name: 'Ava',
        lat: -33.8615,
        lng: 151.2100,
        interests: ['Art', 'Clubbing'],
        spark: 43,
        statusType: StatusType.curious,
        bio: 'Catch me at Oxford Art Factory!',
        age: 23,
        gender: 'Female',
      ),
      const IceUser(
        id: 4,
        name: 'Jayden',
        lat: -33.8708,
        lng: 151.2000,
        interests: ['Gaming', 'Anime'],
        spark: 56,
        statusType: StatusType.busy,
        bio: 'Manga, games, and memes.',
        age: 28,
        gender: 'Male',
      ),

      // ✅ 6 EXTRA users within ~800m of Rahul
      const IceUser(
        id: 5,
        name: 'Maya',
        lat: -33.8679,
        lng: 151.2131,
        interests: ['Coffee', 'Markets'],
        spark: 44,
        statusType: StatusType.open,
        bio: "Down for a quick hello 👋",
        age: 25,
        gender: 'Female',
      ),
      const IceUser(
        id: 6,
        name: 'Ethan',
        lat: -33.8702,
        lng: 151.2110,
        interests: ['Tech', 'Comedy'],
        spark: 52,
        statusType: StatusType.curious,
        bio: "New to the area — wave at me!",
        age: 29,
        gender: 'Male',
      ),
      const IceUser(
        id: 7,
        name: 'Zara',
        lat: -33.8682,
        lng: 151.2069,
        interests: ['Photography', 'Travel'],
        spark: 36,
        statusType: StatusType.shy,
        bio: "I’m shy but friendly 🙂",
        age: 22,
        gender: 'Female',
      ),
      const IceUser(
        id: 8,
        name: 'Noah',
        lat: -33.8669,
        lng: 151.2099,
        interests: ['EDM', 'Dance'],
        spark: 61,
        statusType: StatusType.open,
        bio: "Music lover. Wave if you like EDM!",
        age: 26,
        gender: 'Male',
      ),
      const IceUser(
        id: 9,
        name: 'Kai',
        lat: -33.8695,
        lng: 151.2144,
        interests: ['Fitness', 'Beach'],
        spark: 28,
        statusType: StatusType.busy,
        bio: "Busy today but open to a quick wave.",
        age: 30,
        gender: 'Non-binary',
      ),
      const IceUser(
        id: 10,
        name: 'Priya',
        lat: -33.8711,
        lng: 151.2086,
        interests: ['Food', 'Movies'],
        spark: 47,
        statusType: StatusType.curious,
        bio: "Tell me your fave movie 🎬",
        age: 27,
        gender: 'Female',
      ),
    ];

    final rng = Random(7);
    final names = [
      "Ella", "Noah", "Grace", "Mason", "Ruby", "Jack", "Chloe", "Lucas", "Harper", "Zoe", "Oscar", "Mia",
      "Olivia", "Hugo", "Matilda", "Archie", "Willow", "Max", "Hazel", "Charlie", "Maddie", "Ethan",
      "Jasmine", "Carter", "Aaliyah", "Flynn", "Poppy", "Zac", "Georgia", "Blake", "Hannah", "Aiden",
      "Summer", "Luca", "Evie", "Jordan", "Paige", "Cooper", "Aria", "Xavier", "Layla", "Felix", "Lily",
      "Harrison", "Eliza", "Jake", "Joel", "Ava-Rose", "Theo", "Ivy", "Kai", "Nina", "Sam", "Amir", "Priya"
    ];

    final interestsPool = [
      "Food", "Photography", "Movies", "Markets", "Running", "Beach", "Comedy", "Dance", "Tech", "Outdoors",
      "Yoga", "Travel", "EDM", "Gaming", "Anime", "Art", "Coffee", "Fitness"
    ];

    final gendersPool = ["Male", "Female", "Non-binary"];
    StatusType randStatus() => StatusType.values[rng.nextInt(StatusType.values.length)];

    int nextId = 11;
    while (base.length < 60) {
      final n = names[rng.nextInt(names.length)];
      final pos = _randomLandPoint(rng);
      final i1 = interestsPool[rng.nextInt(interestsPool.length)];
      final i2 = interestsPool[rng.nextInt(interestsPool.length)];
      final age = 18 + rng.nextInt(43);
      final gender = gendersPool[rng.nextInt(gendersPool.length)];

      base.add(
        IceUser(
          id: nextId++,
          name: n,
          lat: pos.latitude,
          lng: pos.longitude,
          interests: {i1, i2}.toList(),
          spark: 10 + rng.nextInt(70),
          statusType: randStatus(),
          bio: "Wave 👋 to connect",
          age: age,
          gender: gender,
        ),
      );
    }

    return base;
  }

  double _statusHue(StatusType t) {
    switch (t) {
      case StatusType.open:
        return BitmapDescriptor.hueGreen;
      case StatusType.shy:
        return BitmapDescriptor.hueYellow;
      case StatusType.curious:
        return BitmapDescriptor.hueAzure;
      case StatusType.busy:
        return BitmapDescriptor.hueRed;
    }
  }

  // ✅ Build custom avatar markers
  Future<void> _buildMarkers() async {
    _markers.clear();

    for (final u in _users) {
      if (_blockedIds.contains(u.id)) continue;
      if (!widget.filters.matches(u)) continue;

      final ring = u.me ? const Color(0xFF7C3AED) : statusColor(u.statusType);
      final icon = await _avatarMarkers.iconForUser(
        user: u,
        ringColor: ring,
        isMe: u.me,
      );

      _markers.add(
        Marker(
          markerId: MarkerId('u_${u.id}'),
          position: u.pos,
          icon: icon,
          onTap: () => _setSelectedUser(u.me ? null : u),
          anchor: const Offset(0.5, 0.5), // center anchor for circular marker
        ),
      );
    }
  }

  Future<void> _rebuildMarkersSafely() async {
    await _buildMarkers();
    if (mounted) setState(() {});
  }

  void _showStatusSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _StatusSelectorSheet(
        current: _myStatus,
        onSelect: (s) async {
          setState(() => _myStatus = s);
          Navigator.pop(context);
          // (Optional) if you want "Me" ring color to reflect status too, you can rebuild icons here.
          // await _rebuildMarkersSafely();
        },
      ),
    );
  }

  void _setSelectedUser(IceUser? u) {
    _polylines.clear();

    if (u == null) {
      setState(() => _selected = null);
      return;
    }
    if (_blockedIds.contains(u.id)) return;

    final me = _me;

    _polylines.add(
      Polyline(
        polylineId: const PolylineId('me_to_selected'),
        points: [me.pos, u.pos],
        width: 4,
        color: const Color(0xFF7C3AED),
        patterns: [PatternItem.dot, PatternItem.gap(10)],
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
      ),
    );

    setState(() => _selected = u);
    _zoomToFit(me.pos, u.pos);
  }

  Future<void> _zoomToFit(LatLng a, LatLng b) async {
    final c = _controller;
    if (c == null) return;

    final southWest = LatLng(min(a.latitude, b.latitude), min(a.longitude, b.longitude));
    final northEast = LatLng(max(a.latitude, b.latitude), max(a.longitude, b.longitude));
    final bounds = LatLngBounds(southwest: southWest, northeast: northEast);

    try {
      await c.animateCamera(CameraUpdate.newLatLngBounds(bounds, 90));
    } catch (_) {
      final center = LatLng((a.latitude + b.latitude) / 2, (a.longitude + b.longitude) / 2);
      await c.animateCamera(CameraUpdate.newLatLngZoom(center, 13));
    }
  }

  double _distanceMeters(LatLng a, LatLng b) {
    const R = 6378137.0;
    final dLat = _toRad(b.latitude - a.latitude);
    final dLng = _toRad(b.longitude - a.longitude);
    final lat1 = _toRad(a.latitude);
    final lat2 = _toRad(b.latitude);

    final sin1 = sin(dLat / 2);
    final sin2 = sin(dLng / 2);
    final h = sin1 * sin1 + cos(lat1) * cos(lat2) * sin2 * sin2;
    return 2 * R * atan2(sqrt(h), sqrt(1 - h));
  }

  double _toRad(double d) => d * pi / 180.0;

  bool _chatUnlocked(IceUser u) => _waveBack[u.id] == true;
  bool _directionsUnlocked(IceUser u) => _waveBack[u.id] == true;

  void _waveAt(IceUser u) {
    if (u.me) return;

    if (_waveSent[u.id] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("You already waved at ${u.name} 👋"), duration: const Duration(milliseconds: 800)),
      );
      return;
    }

    setState(() => _waveSent[u.id] = true);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("You waved at ${u.name} 👋"), duration: const Duration(milliseconds: 900)),
    );

    Future.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      if (_blockedIds.contains(u.id)) return;

      final rng = Random(u.id * 999 + DateTime.now().millisecond);
      final double chance;
      switch (u.statusType) {
        case StatusType.open:
          chance = 0.85;
          break;
        case StatusType.curious:
          chance = 0.75;
          break;
        case StatusType.shy:
          chance = 0.55;
          break;
        case StatusType.busy:
          chance = 0.35;
          break;
      }

      final wavedBack = rng.nextDouble() < chance;

      if (wavedBack) {
        setState(() => _waveBack[u.id] = true);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("${u.name} waved back 👋  Chat & Directions unlocked!"),
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("${u.name} didn’t respond yet…"),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    });
  }

  Future<void> _openDirections(IceUser u) async {
    final me = _me;

    final url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1'
          '&origin=${me.lat},${me.lng}'
          '&destination=${u.lat},${u.lng}'
          '&travelmode=walking',
    );

    try {
      final ok = await launchUrl(url, mode: LaunchMode.externalApplication);
      if (!ok && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Could not open Maps")));
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Could not open Maps")));
    }
  }

  void _openChat(IceUser u) {
    setState(() => _chatOpen = true);

    final bothOpen = (_myStatus == StatusType.open && u.statusType == StatusType.open);

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.14),
      builder: (_) => _ChatDialog(
        userName: u.name,
        banner: bothOpen ? "You’re both Open right now 👋" : null,
        onClose: () {
          Navigator.of(context).pop();
          setState(() => _chatOpen = false);
        },
      ),
    );
  }

  void _blockUser(IceUser u) async {
    if (u.me) return;

    setState(() {
      _blockedIds.add(u.id);
      if (_selected?.id == u.id) _selected = null;
      _polylines.clear();
    });

    await _rebuildMarkersSafely();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${u.name} blocked'), duration: const Duration(seconds: 2)),
    );
  }

  void _showEmergencySheet() {
    final me = _me;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.97),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
            boxShadow: const [
              BoxShadow(blurRadius: 28, color: Color(0x22000000), offset: Offset(0, -10)),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 5,
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text("Emergency", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
              ),
              const SizedBox(height: 10),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFEF4444),
                  child: Icon(Icons.phone_in_talk, color: Colors.white),
                ),
                title: const Text("Call emergency services (000)", style: TextStyle(fontWeight: FontWeight.w800)),
                subtitle: const Text("Australia emergency number"),
                onTap: () async {
                  Navigator.pop(context);
                  final uri = Uri.parse('tel:000');
                  try {
                    final ok = await launchUrl(uri);
                    if (!ok && mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open dialer')));
                    }
                  } catch (_) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open dialer')));
                  }
                },
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFF7C3AED),
                  child: Icon(Icons.copy, color: Colors.white),
                ),
                title: const Text("Copy my location", style: TextStyle(fontWeight: FontWeight.w800)),
                subtitle: Text("${me.lat.toStringAsFixed(5)}, ${me.lng.toStringAsFixed(5)}"),
                onTap: () async {
                  final text = "My location: ${me.lat.toStringAsFixed(5)}, ${me.lng.toStringAsFixed(5)}";
                  await Clipboard.setData(ClipboardData(text: text));
                  if (!mounted) return;
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location copied')));
                },
              ),
              const SizedBox(height: 6),
              const Text(
                "If you are in immediate danger, call 000.",
                style: TextStyle(color: Color(0xFF6B7280), fontSize: 12.5),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selected;
    final mePos = _me.pos;

    return Scaffold(
      body: GestureDetector(
        onTap: () {
          if (_chatOpen) return;
          if (selected != null) _setSelectedUser(null);
        },
        child: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: const CameraPosition(target: _sydney, zoom: 11.5),
              myLocationEnabled: false,
              myLocationButtonEnabled: false,
              compassEnabled: false,
              mapToolbarEnabled: false,
              zoomControlsEnabled: false,
              rotateGesturesEnabled: true,
              tiltGesturesEnabled: false,
              scrollGesturesEnabled: true,
              zoomGesturesEnabled: true,
              markers: _markers,
              polylines: _polylines,
              onMapCreated: (c) => _controller = c,
              onTap: (_) {
                if (!_chatOpen) _setSelectedUser(null);
              },
              gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                Factory<OneSequenceGestureRecognizer>(() => EagerGestureRecognizer()),
              },
            ),

            // Frost overlay
            IgnorePointer(child: Container(color: Colors.white.withOpacity(0.11))),

            // Emergency ONLY on map (top-left)
            Positioned(
              top: 52,
              left: 14,
              child: _EmergencyButton(onTap: _showEmergencySheet),
            ),

            Positioned(
              top: 52,
              right: 14,
              child: _MyStatusButton(status: _myStatus, onTap: _showStatusSelector),
            ),

            Positioned(
              left: 0,
              right: 0,
              bottom: 18,
              child: Center(child: _LegendPill(myStatus: _myStatus)),
            ),

            if (selected != null)
              Positioned(
                left: 14,
                right: 14,
                bottom: 90,
                child: _UserPopupCard(
                  user: selected,
                  distanceMeters: _distanceMeters(mePos, selected.pos),
                  waved: _waveSent[selected.id] == true,
                  chatUnlocked: _chatUnlocked(selected),
                  directionsUnlocked: _directionsUnlocked(selected),
                  onClose: () => _setSelectedUser(null),
                  onWave: () => _waveAt(selected),
                  onChat: () => _openChat(selected),
                  onDirections: () => _openDirections(selected),
                  onBlock: () => _blockUser(selected),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/* ============================================================
   EMERGENCY + STATUS UI
   ============================================================ */
class _EmergencyButton extends StatelessWidget {
  final VoidCallback onTap;
  const _EmergencyButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFEF4444).withOpacity(0.92),
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(blurRadius: 16, color: Color(0x26000000), offset: Offset(0, 6)),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.sos, color: Colors.white, size: 18),
            SizedBox(width: 6),
            Text("Emergency", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
          ],
        ),
      ),
    );
  }
}

class _MyStatusButton extends StatelessWidget {
  final StatusType status;
  final VoidCallback onTap;

  const _MyStatusButton({required this.status, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = statusColor(status);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: c.withOpacity(0.92),
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(blurRadius: 16, color: Color(0x26000000), offset: Offset(0, 6)),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.person, color: Colors.white, size: 18),
            const SizedBox(width: 6),
            Text(statusLabel(status), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
            const SizedBox(width: 2),
            const Icon(Icons.expand_more, color: Colors.white),
          ],
        ),
      ),
    );
  }
}

class _StatusSelectorSheet extends StatelessWidget {
  final StatusType current;
  final ValueChanged<StatusType> onSelect;

  const _StatusSelectorSheet({required this.current, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.96),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
        boxShadow: const [
          BoxShadow(blurRadius: 28, color: Color(0x22000000), offset: Offset(0, -10)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 5,
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(color: const Color(0xFFCBD5E1), borderRadius: BorderRadius.circular(99)),
          ),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text("Set your status", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
          ),
          const SizedBox(height: 8),
          ...StatusType.values.map((s) {
            final selected = s == current;
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: statusColor(s),
                child: selected ? const Icon(Icons.check, color: Colors.white) : null,
              ),
              title: Text(
                statusLabel(s),
                style: TextStyle(fontWeight: selected ? FontWeight.w900 : FontWeight.w700),
              ),
              onTap: () => onSelect(s),
            );
          }),
        ],
      ),
    );
  }
}

/* ============================================================
   LEGEND
   ============================================================ */
class _LegendPill extends StatelessWidget {
  final StatusType myStatus;
  const _LegendPill({required this.myStatus});

  @override
  Widget build(BuildContext context) {
    Widget dot(Color c, {bool me = false}) => Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        color: c,
        shape: BoxShape.circle,
        border: me ? Border.all(color: Colors.white, width: 2) : null,
      ),
    );

    const t = TextStyle(
      color: Color(0xFF262626),
      fontSize: 13.5,
      fontWeight: FontWeight.w600,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F9FF).withOpacity(0.93),
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(blurRadius: 8, color: Color(0x14000000), offset: Offset(0, 2)),
        ],
      ),
      child: Wrap(
        spacing: 14,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        alignment: WrapAlignment.center,
        children: [
          Row(mainAxisSize: MainAxisSize.min, children: [
            dot(const Color(0xFF7C3AED), me: true),
            const SizedBox(width: 6),
            Text('Me (Rahul) • ${statusLabel(myStatus)}', style: t),
          ]),
          Row(mainAxisSize: MainAxisSize.min, children: [
            dot(const Color(0xFF10B981)),
            const SizedBox(width: 6),
            const Text('Open', style: t),
          ]),
          Row(mainAxisSize: MainAxisSize.min, children: [
            dot(const Color(0xFFFBBF24)),
            const SizedBox(width: 6),
            const Text('Shy', style: t),
          ]),
          Row(mainAxisSize: MainAxisSize.min, children: [
            dot(const Color(0xFF38BDF8)),
            const SizedBox(width: 6),
            const Text('Curious', style: t),
          ]),
          Row(mainAxisSize: MainAxisSize.min, children: [
            dot(const Color(0xFFEF4444)),
            const SizedBox(width: 6),
            const Text('Busy', style: t),
          ]),
          const SizedBox(width: 8),
          const Text(
            'Icebreaker',
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
              color: Color(0xFF262626),
            ),
          ),
        ],
      ),
    );
  }
}

/* ============================================================
   USER POPUP CARD (Glass + small Block corner)
   ============================================================ */
class _UserPopupCard extends StatelessWidget {
  final IceUser user;
  final double distanceMeters;

  final bool waved;
  final bool chatUnlocked;
  final bool directionsUnlocked;

  final VoidCallback onClose;
  final VoidCallback onWave;
  final VoidCallback onChat;
  final VoidCallback onDirections;
  final VoidCallback onBlock;

  const _UserPopupCard({
    required this.user,
    required this.distanceMeters,
    required this.waved,
    required this.chatUnlocked,
    required this.directionsUnlocked,
    required this.onClose,
    required this.onWave,
    required this.onChat,
    required this.onDirections,
    required this.onBlock,
  });

  @override
  Widget build(BuildContext context) {
    final canInteract = distanceMeters <= 800;

    String distLabel() {
      if (distanceMeters < 1000) return "${distanceMeters.toStringAsFixed(0)} m away";
      return "~${(distanceMeters / 1000).toStringAsFixed(2)} km away";
    }

    return Material(
      color: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF6F9FE).withOpacity(0.88),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFFB0E6B6).withOpacity(0.6), width: 2),
              boxShadow: const [
                BoxShadow(blurRadius: 22, color: Color(0x14000000), offset: Offset(0, 6)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(user.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                    ),
                    SizedBox(
                      height: 32,
                      child: OutlinedButton.icon(
                        onPressed: onBlock,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          minimumSize: const Size(0, 32),
                          foregroundColor: const Color(0xFFEF4444),
                          side: const BorderSide(color: Color(0xFFEF4444), width: 1.4),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          visualDensity: const VisualDensity(horizontal: -3, vertical: -3),
                        ),
                        icon: const Icon(Icons.block, size: 16),
                        label: const Text("Block", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12.5)),
                      ),
                    ),
                    const SizedBox(width: 6),
                    IconButton(
                      onPressed: onClose,
                      icon: const Icon(Icons.close, color: Color(0xFF7C3AED)),
                      constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  user.interests.map((i) => "#$i").join(' '),
                  style: const TextStyle(color: Color(0xFF1688E8), fontSize: 13.5, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                Text(
                  "Spark Points: ${user.spark}",
                  style: const TextStyle(color: Color(0xFFE6B800), fontSize: 13, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: statusColor(user.statusType), borderRadius: BorderRadius.circular(9)),
                  child: Text(
                    statusLabel(user.statusType),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
                  ),
                ),
                const SizedBox(height: 8),
                Text(user.bio, style: const TextStyle(color: Color(0xFF6B7280), fontSize: 13.5)),
                const SizedBox(height: 4),
                Text(distLabel(), style: const TextStyle(color: Color(0xFF888888), fontSize: 13)),
                const SizedBox(height: 12),

                // ✅ FIX: keep Wave / Chat / Directions on ONE line (shrink text if needed)
                Row(
                  children: [
                    if (canInteract)
                      Expanded(
                        child: ElevatedButton(
                          onPressed: onWave,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF10B981),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            visualDensity: const VisualDensity(horizontal: -2, vertical: -2),
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              waved ? "Waved 👋" : "Wave 👋",
                              style: const TextStyle(fontWeight: FontWeight.w800),
                            ),
                          ),
                        ),
                      ),
                    if (canInteract) const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: (canInteract && chatUnlocked) ? onChat : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7C3AED),
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: const Color(0xFF7C3AED).withOpacity(0.35),
                          disabledForegroundColor: Colors.white.withOpacity(0.9),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          visualDensity: const VisualDensity(horizontal: -2, vertical: -2),
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            (canInteract && chatUnlocked) ? "Chat" : "Chat 🔒",
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: (canInteract && directionsUnlocked) ? onDirections : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFBBF24),
                          foregroundColor: const Color(0xFF222222),
                          disabledBackgroundColor: const Color(0xFFFBBF24).withOpacity(0.45),
                          disabledForegroundColor: const Color(0xFF222222).withOpacity(0.85),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          visualDensity: const VisualDensity(horizontal: -2, vertical: -2),
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            (canInteract && directionsUnlocked) ? "Directions" : "Directions 🔒",
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                if (!canInteract)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text("Wave is only available within 800 m.",
                        style: TextStyle(color: Color(0xFF6B7280), fontSize: 12.5)),
                  ),
                if (canInteract && !chatUnlocked)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text("Wave first — if they wave back, Chat & Directions unlock.",
                        style: TextStyle(color: Color(0xFF6B7280), fontSize: 12.5)),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/* ============================================================
   CHAT DIALOG (no emergency button)
   ============================================================ */
class _ChatDialog extends StatefulWidget {
  final String userName;
  final String? banner;
  final VoidCallback onClose;

  const _ChatDialog({required this.userName, required this.onClose, this.banner});

  @override
  State<_ChatDialog> createState() => _ChatDialogState();
}

class _ChatDialogState extends State<_ChatDialog> {
  final TextEditingController _controller = TextEditingController();
  final List<_Msg> _messages = <_Msg>[
    const _Msg(fromMe: false, text: "Nice to meet you! 👋"),
  ];

  void _send() {
    final txt = _controller.text.trim();
    if (txt.isEmpty) return;

    setState(() {
      _messages.add(_Msg(fromMe: true, text: txt));
      _messages.add(const _Msg(fromMe: false, text: "Nice to meet you!"));
    });

    _controller.clear();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      backgroundColor: const Color(0xFFE9F4FE),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(19)),
      child: SizedBox(
        width: 370,
        height: min(MediaQuery.of(context).size.height * 0.62, 520),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Chat with ${widget.userName}",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                  if (widget.banner != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(widget.banner!, style: const TextStyle(fontWeight: FontWeight.w800)),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _messages.length,
                      itemBuilder: (context, i) {
                        final m = _messages[i];
                        return Align(
                          alignment: m.fromMe ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            constraints: const BoxConstraints(maxWidth: 280),
                            decoration: BoxDecoration(
                              color: m.fromMe ? const Color(0xFF7C3AED) : const Color(0xFFF59E42),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: const [
                                BoxShadow(blurRadius: 4, color: Color(0x22000000), offset: Offset(0, 1)),
                              ],
                            ),
                            child: Text(
                              m.text,
                              style: TextStyle(
                                color: m.fromMe ? Colors.white : const Color(0xFF252525),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          onSubmitted: (_) => _send(),
                          decoration: InputDecoration(
                            hintText: "Type a message...",
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _send,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text("Send", style: TextStyle(fontWeight: FontWeight.w800)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              top: 8,
              right: 10,
              child: IconButton(
                onPressed: widget.onClose,
                icon: const Icon(Icons.close, color: Color(0xFF7C3AED)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Msg {
  final bool fromMe;
  final String text;
  const _Msg({required this.fromMe, required this.text});
}
