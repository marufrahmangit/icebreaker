import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/ice_user.dart';
import '../data/mock_users.dart';
import '../utils/status.dart';
import '../utils/geo.dart';
import '../utils/avatar_marker_factory.dart';

import '../utils/location_history/location_history.dart';
import '../utils/location_history/crossed_paths_engine.dart';
import '../utils/location_history/location_simulator.dart';
import '../utils/location_history/crossed_paths_screen.dart';

import '../widgets/emergency_button.dart';
import '../widgets/my_status_button.dart';
import '../widgets/status_selector_sheet.dart';
import '../widgets/legend_pill.dart';
import '../widgets/user_popup_card.dart';
import '../widgets/crossed_paths_button.dart';
import '../widgets/chat_dialog.dart';

/* ============================================================
   MAP SCREEN
   - locationSharingEnabled: initial state from consent popup
   - Visibility toggle on the map (top-left, below emergency)
   - When OFF: other users invisible, no interaction possible
   ============================================================ */
class MapScreen extends StatefulWidget {
  final Filters filters;
  final bool locationSharingEnabled;

  const MapScreen({
    super.key,
    required this.filters,
    required this.locationSharingEnabled,
  });

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

  // Meet request system
  final Map<int, bool> _meetRequestSent = {};
  final Map<int, bool> _locationShared = {};

  // Custom avatar marker factory (with glow for open users)
  final AvatarMarkerFactory _avatarMarkers = AvatarMarkerFactory();

  // Crossed paths feature
  late final List<LocationSample> _locationHistory;
  late final CrossedPathsEngine _pathsEngine;
  List<CrossedPath> _myCrossedPaths = [];

  // ✅ NEW: Pre-computed crossed paths grouped by user for quick lookup
  Map<int, List<CrossedPath>> _crossedPathsByUser = {};

  // Location sharing / visibility toggle
  late bool _locationSharingOn;

  // Banner control
  bool _showInvisibleBanner = false;

  @override
  void initState() {
    super.initState();
    _locationSharingOn = widget.locationSharingEnabled;
    _users = buildMockUsers();
    _myStatus = _me.statusType;

    // Initialize crossed paths feature
    _pathsEngine = CrossedPathsEngine(
      config: const CrossedPathsConfig(
        proximityRadius: 15.0,
        timeWindow: Duration(minutes: 5),
      ),
    );
    _locationHistory = _generateSimulatedHistory();
    _myCrossedPaths = _pathsEngine.detectCrossedPaths(
      targetUserId: _me.id,
      allLocationSamples: _locationHistory,
    );

    // ✅ NEW: Pre-group crossed paths by user ID for O(1) lookup
    _crossedPathsByUser = _pathsEngine.groupByUser(_myCrossedPaths);

    // Build markers async
    Future.microtask(() async {
      await _buildMarkers();
      if (mounted) setState(() {});
    });
  }
  
  

  IceUser get _me => _users.firstWhere((u) => u.me);

  // ✅ NEW: Get crossed paths count for a specific user
  int _getCrossedPathsCount(int userId) {
    return _crossedPathsByUser[userId]?.length ?? 0;
  }

  List<LocationSample> _generateSimulatedHistory() {
    final simulator = LocationHistorySimulator();
    final now = DateTime.now();
    final startTime = now.subtract(const Duration(days: 7));

    final baseLocations = _users.map((u) {
      return UserBaseLocation(
        userId: u.id,
        lat: u.lat,
        lng: u.lng,
        movementRadius: 1000.0,
        activityLevel: u.me ? 0.9 : 0.3 + Random(u.id).nextDouble() * 0.5,
      );
    }).toList();

    final history = simulator.generateLocationHistory(
      users: baseLocations,
      startTime: startTime,
      duration: const Duration(days: 7),
      samplesPerHour: 12,
    );

    final crossings = [
      UserCrossingConfig(userId1: 0, userId2: 1, lat: -33.8568, lng: 151.2153, timeOffset: Duration(days: 2, hours: 14)),
      UserCrossingConfig(userId1: 0, userId2: 2, lat: -33.8614, lng: 151.2106, timeOffset: Duration(days: 1, hours: 18, minutes: 30)),
      UserCrossingConfig(userId1: 0, userId2: 3, lat: -33.8736, lng: 151.2007, timeOffset: Duration(days: 3, hours: 12)),
      UserCrossingConfig(userId1: 0, userId2: 5, lat: -33.8679, lng: 151.2131, timeOffset: Duration(hours: 8)),
      UserCrossingConfig(userId1: 0, userId2: 6, lat: -33.8702, lng: 151.2110, timeOffset: Duration(hours: 5)),
    ];

    final crossingSamples = simulator.injectCrossings(
      crossings: crossings,
      baseTime: startTime,
    );

    return [...history, ...crossingSamples]..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  // ✅ Build custom avatar markers (with glow for "open" users)
  Future<void> _buildMarkers() async {
    _markers.clear();

    for (final u in _users) {
      if (_blockedIds.contains(u.id)) continue;
      if (!widget.filters.matches(u)) continue;

      // If location sharing is OFF, only show "me" marker
      if (!_locationSharingOn && !u.me) continue;

      final isOpen = u.statusType == StatusType.open;
      final ring = u.me ? const Color(0xFF7C3AED) : statusColor(u.statusType);
      final icon = await _avatarMarkers.iconForUser(
        user: u,
        ringColor: ring,
        isMe: u.me,
        isOpen: isOpen && !u.me, // Glow for non-me open users
      );

      _markers.add(
        Marker(
          markerId: MarkerId('u_${u.id}'),
          position: u.pos,
          icon: icon,
          onTap: () {
            if (!_locationSharingOn && !u.me) return; // Cannot interact when off
            _setSelectedUser(u.me ? null : u);
          },
          anchor: const Offset(0.5, 0.5),
        ),
      );
    }
  }

  Future<void> _rebuildMarkersSafely() async {
    await _buildMarkers();
    if (mounted) setState(() {});
  }

  void _toggleLocationSharing(bool value) {
    setState(() {
      _locationSharingOn = value;

      if (!value) {
        // Show floating banner
        _showInvisibleBanner = true;

        // Clear selection and polylines
        _selected = null;
        _polylines.clear();

        // Hide banner after 1.5s
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) {
            setState(() {
              _showInvisibleBanner = false;
            });
          }
        });
      }
    });
    _rebuildMarkersSafely();
  }

  void _showStatusSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => StatusSelectorSheet(
        current: _myStatus,
        onSelect: (s) async {
          setState(() => _myStatus = s);
          Navigator.pop(context);
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
    return distanceMeters(a.latitude, a.longitude, b.latitude, b.longitude);
  }

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
            content: Text("${u.name} waved back 👋  Chat & Meet unlocked!"),
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("${u.name} didn't respond yet..."),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    });
  }

  Future<void> _openDirections(IceUser u) async {
    if (u.me) return;

    if (_meetRequestSent[u.id] == true) {
      if (_locationShared[u.id] == true) {
        _openMapDirections(u);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Waiting for ${u.name} to respond to your meet request..."),
            duration: const Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: const Text('Send Meet Request?', style: TextStyle(fontWeight: FontWeight.w800)),
          content: Text(
            'Send a meet request to ${u.name}? They can choose to share their exact location with you.',
            style: const TextStyle(fontSize: 15),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel', style: TextStyle(color: Color(0xFF6B7280), fontWeight: FontWeight.w700)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Send Request', style: TextStyle(fontWeight: FontWeight.w800)),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      setState(() => _meetRequestSent[u.id] = true);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Meet request sent to ${u.name} 📍"), duration: const Duration(seconds: 2)),
      );

      Future.delayed(const Duration(seconds: 2), () {
        if (!mounted) return;
        if (_blockedIds.contains(u.id)) return;

        final accepted = u.willAcceptMeet;

        if (accepted) {
          setState(() => _locationShared[u.id] = true);
          _rebuildMarkersSafely();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("${u.name} shared their location! 📍 Tap Meet again for directions."),
              duration: const Duration(seconds: 3),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("${u.name} decided to pass this time 🤷"),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      });
    }
  }

  Future<void> _openMapDirections(IceUser u) async {
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Could not open Maps")),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not open Maps")),
      );
    }
  }

  void _openChat(IceUser u) {
    setState(() => _chatOpen = true);

    final bothOpen = (_myStatus == StatusType.open && u.statusType == StatusType.open);

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.14),
      builder: (_) => ChatDialog(
        userName: u.name,
        banner: bothOpen ? "You're both Open right now 👋" : null,
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

            // Emergency button (top-left)
            Positioned(
              top: 52,
              left: 14,
              child: EmergencyButton(onTap: _showEmergencySheet),
            ),

            // Status button (top-right)
            Positioned(
              top: 52,
              right: 14,
              child: MyStatusButton(status: _myStatus, onTap: _showStatusSelector),
            ),

            // Crossed Paths button (below status button)
            Positioned(
              top: 110,
              right: 14,
              child: CrossedPathsButton(
                count: _myCrossedPaths.isEmpty
                    ? 0
                    : _crossedPathsByUser.length,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => CrossedPathsScreen(
                        crossedPaths: _myCrossedPaths,
                        getUserById: (id) {
                          try {
                            return _users.firstWhere((u) => u.id == id);
                          } catch (_) {
                            return null;
                          }
                        },
                        onUserTap: (user) {
                          Navigator.of(context).pop();
                          _setSelectedUser(user);
                        },
                      ),
                    ),
                  );
                },
              ),
            ),

            // Legend
            Positioned(
              left: 0,
              right: 0,
              bottom: 18,
              child: Center(
                child: LegendPill(
                  myStatus: _myStatus,
                  isVisible: _locationSharingOn,
                  onVisibilityChanged: _toggleLocationSharing,
                ),
              ),
            ),

            // ✅ "Location sharing off" banner when toggled off..."You are invisible" banner (slide + fade)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOut,
              top: _showInvisibleBanner ? MediaQuery.of(context).size.height * 0.4 : -100,
              left: 40,
              right: 40,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 500),
                opacity: _showInvisibleBanner ? 0.8 : 0.0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withOpacity(0.99),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: const [
                      BoxShadow(
                        blurRadius: 12,
                        color: Color(0x26000000),
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.visibility_off, color: Colors.white, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'You are invisible',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // User popup card
            if (selected != null && _locationSharingOn)
              Positioned(
                left: 14,
                right: 14,
                bottom: 90,
                child: UserPopupCard(
                  user: selected,
                  distanceMeters: _distanceMeters(mePos, selected.pos),
                  waved: _waveSent[selected.id] == true,
                  chatUnlocked: _chatUnlocked(selected),
                  directionsUnlocked: _directionsUnlocked(selected),
                  // ✅ NEW: Pass crossed paths count for this user
                  crossedPathsCount: _getCrossedPathsCount(selected.id),
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