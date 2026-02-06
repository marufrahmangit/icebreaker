import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../models/ice_user.dart';
import '../utils/status.dart';

/* ============================================================
   LEGEND PILL
   - Status color legend at the bottom of the map
   - Integrated visibility toggle (CupertinoSwitch)
   ============================================================ */
class LegendPill extends StatelessWidget {
  final StatusType myStatus;
  final bool isVisible;
  final ValueChanged<bool> onVisibilityChanged;

  const LegendPill({
    super.key,
    required this.myStatus,
    required this.isVisible,
    required this.onVisibilityChanged,
  });

  @override
  Widget build(BuildContext context) {
    Widget dot(Color c, {bool me = false, bool glow = false}) {
      return Container(
        width: 18,
        height: 18,
        decoration: BoxDecoration(
          color: c,
          shape: BoxShape.circle,
          border: me ? Border.all(color: Colors.white, width: 2) : null,
          boxShadow: glow
              ? [
                  BoxShadow(color: c.withOpacity(0.50), blurRadius: 6, spreadRadius: 1),
                  BoxShadow(color: c.withOpacity(0.25), blurRadius: 10, spreadRadius: 2),
                ]
              : null,
        ),
      );
    }

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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Status legend row
          Wrap(
            spacing: 14,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            alignment: WrapAlignment.center,
            children: [
              Row(mainAxisSize: MainAxisSize.min, children: [
                dot(const Color(0xFF7C3AED), me: true),
                const SizedBox(width: 6),
                Text('Me (Username) • ${statusLabel(myStatus)}', style: t),
              ]),
              Row(mainAxisSize: MainAxisSize.min, children: [
                dot(const Color(0xFF10B981), glow: true),
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
            ],
          ),

          // Divider
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Container(
              height: 1,
              color: const Color(0xFFE2E8F0).withOpacity(0.6),
            ),
          ),

          // Visibility toggle row
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isVisible ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                size: 18,
                color: isVisible ? const Color(0xFF10B981) : const Color(0xFFEF4444),
              ),
              const SizedBox(width: 8),
              Text(
                isVisible ? 'Visible to others' : 'Hidden from others',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isVisible ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                height: 28,
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: CupertinoSwitch(
                    value: isVisible,
                    activeTrackColor: const Color(0xFF10B981),
                    onChanged: onVisibilityChanged,
                  ),
                ),
              ),
              const SizedBox(width: 14),
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
        ],
      ),
    );
  }
}