import 'package:flutter/material.dart';

class LegendPill extends StatelessWidget {
  final String meName;

  const LegendPill({
    super.key,
    required this.meName,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomPadding > 0 ? 6 : 0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          margin: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.92),
            borderRadius: BorderRadius.circular(999),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),

          // ✅ THIS is the fix: allow horizontal scroll instead of Row overflow.
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _chip(
                  color: Colors.purple,
                  label: 'You ($meName)',
                  bold: true,
                ),
                const SizedBox(width: 10),
                _chip(color: Colors.green, label: 'Open'),
                const SizedBox(width: 10),
                _chip(color: Colors.amber, label: 'Shy'),
                const SizedBox(width: 10),
                _chip(color: Colors.blue, label: 'Curious'),
                const SizedBox(width: 10),
                _chip(color: Colors.red, label: 'Busy'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _chip({
    required Color color,
    required String label,
    bool bold = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
              color: Colors.black.withOpacity(0.85),
            ),
          ),
        ],
      ),
    );
  }
}
