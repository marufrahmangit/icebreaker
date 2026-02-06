import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/ice_user.dart';

/* ============================================================
   CUSTOM AVATAR MARKER FACTORY
   - Circular avatar with colored status ring
   - "Me" marker: purple circle with white stroke
   - "Open" status users: prominent triple-layer outer glow
   - Non-open users: slim ring for clear visual contrast
   ============================================================ */
class AvatarMarkerFactory {
  final Map<String, BitmapDescriptor> _cache = {};

  static const int _sizePx = 160; // Larger canvas for glow headroom
  static const double _ringOpen = 10; // Thick ring for open users
  static const double _ringDefault = 5; // Slim ring for non-open users
  static const double _ringMe = 10; // "Me" keeps thick ring
  static const double _innerPadding = 8;
  static const double _glowInset = 16; // Inset for glow users to fit 3 layers

  Future<BitmapDescriptor> iconForUser({
    required IceUser user,
    required Color ringColor,
    required bool isMe,
    required bool isOpen,
  }) async {
    final key = '${user.id}_${ringColor.value}_${isMe ? "me" : "u"}_${isOpen ? "glow" : "no"}';
    final cached = _cache[key];
    if (cached != null) return cached;

    final bytes = await _drawMarkerPng(
      initials: _initialsFromName(user.name),
      ringColor: ringColor,
      isMe: isMe,
      isOpen: isOpen,
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
    required bool isOpen,
  }) async {
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);

    final size = ui.Size(_sizePx.toDouble(), _sizePx.toDouble());
    final center = ui.Offset(size.width / 2, size.height / 2);

    // Avatar outer radius: glow users are inset to leave room for 3 glow layers
    final avatarOuterRadius = (size.width / 2) - (isOpen && !isMe ? _glowInset : 4);

    // ✅ Triple-layer glow for "open" status users (non-me)
    if (isOpen && !isMe) {
      // Layer 1 – outermost wide haze
      final glow1 = ui.Paint()
        ..color = ringColor.withOpacity(0.18)
        ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 14)
        ..style = ui.PaintingStyle.fill
        ..isAntiAlias = true;
      canvas.drawCircle(center, avatarOuterRadius + 14, glow1);

      // Layer 2 – mid glow
      final glow2 = ui.Paint()
        ..color = ringColor.withOpacity(0.32)
        ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 9)
        ..style = ui.PaintingStyle.fill
        ..isAntiAlias = true;
      canvas.drawCircle(center, avatarOuterRadius + 8, glow2);

      // Layer 3 – bright inner halo
      final glow3 = ui.Paint()
        ..color = ringColor.withOpacity(0.45)
        ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 5)
        ..style = ui.PaintingStyle.fill
        ..isAntiAlias = true;
      canvas.drawCircle(center, avatarOuterRadius + 3, glow3);
    }

    // Outer ring – thick for open/me, slim for others
    final ringPaint = ui.Paint()
      ..color = ringColor
      ..style = ui.PaintingStyle.fill
      ..isAntiAlias = true;
    canvas.drawCircle(center, avatarOuterRadius, ringPaint);

    // Ring thickness varies by type
    final double ringWidth;
    if (isMe) {
      ringWidth = _ringMe;
    } else if (isOpen) {
      ringWidth = _ringOpen;
    } else {
      ringWidth = _ringDefault;
    }
    final innerRadius = avatarOuterRadius - ringWidth;

    // Inner avatar circle
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