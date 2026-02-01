import 'package:flutter/material.dart';
import '../models/ice_user.dart';
import '../utils/status.dart';

class LegendPill extends StatelessWidget {
  const LegendPill({super.key, required this.meName});

  final String meName;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final small = w < 520;

    Widget dot(Color c, {bool bordered = false}) => Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: c,
            border: bordered ? Border.all(color: Colors.white, width: 2) : null,
          ),
        );

    return Container(
      padding: EdgeInsets.symmetric(horizontal: small ? 10 : 18, vertical: small ? 10 : 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.93),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(blurRadius: 8, color: Colors.black.withOpacity(0.06), offset: const Offset(0, 2))],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _LegendItem(icon: dot(const Color(0xFF7C3AED), bordered: true), label: 'Me ($meName)'),
          const SizedBox(width: 14),
          _LegendItem(icon: dot(statusColor(StatusType.open)), label: 'Open'),
          const SizedBox(width: 14),
          _LegendItem(icon: dot(statusColor(StatusType.shy)), label: 'Shy'),
          const SizedBox(width: 14),
          _LegendItem(icon: dot(statusColor(StatusType.curious)), label: 'Curious'),
          const SizedBox(width: 14),
          _LegendItem(icon: dot(statusColor(StatusType.busy)), label: 'Busy'),
          const SizedBox(width: 14),
          const Text('Icebreaker', style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1)),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.icon, required this.label});

  final Widget icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        icon,
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 14)),
      ],
    );
  }
}
