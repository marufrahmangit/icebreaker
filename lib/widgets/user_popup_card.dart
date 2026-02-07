import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../models/ice_user.dart';
import '../utils/status.dart';
import '../utils/geo.dart';

/* ============================================================
   USER POPUP CARD (Glass + small Block corner)
   ============================================================ */
class UserPopupCard extends StatelessWidget {
  final IceUser user;
  final double distanceMeters;

  final bool waved;
  final bool chatUnlocked;
  final bool directionsUnlocked;

  // ✅ NEW: Crossed paths info
  final int crossedPathsCount;

  final VoidCallback onClose;
  final VoidCallback onWave;
  final VoidCallback onChat;
  final VoidCallback onDirections;
  final VoidCallback onBlock;

  const UserPopupCard({
    super.key,
    required this.user,
    required this.distanceMeters,
    required this.waved,
    required this.chatUnlocked,
    required this.directionsUnlocked,
    this.crossedPathsCount = 0,
    required this.onClose,
    required this.onWave,
    required this.onChat,
    required this.onDirections,
    required this.onBlock,
  });

  @override
  Widget build(BuildContext context) {
    final canInteract = distanceMeters <= 1000;

    return Material(
      color: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF6F9FE).withOpacity(0.75),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFFB0E6B6).withOpacity(0.45), width: 1.6),
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

                // ✅ NEW: Crossed paths banner
                if (crossedPathsCount > 0) ...[
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF8F4EED), Color(0xFF6A84F7)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF7C3AED).withOpacity(0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.route, color: Colors.white, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            crossedPathsCount == 1
                                ? 'You crossed paths with ${user.name} once'
                                : 'You crossed paths with ${user.name} $crossedPathsCount times',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 10),
                Text(
                  user.interests.map((i) => "#$i").join(' '),
                  style: const TextStyle(color: Color(0xFF1688E8), fontSize: 13.5, fontWeight: FontWeight.w600),
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
                Text(prettyDistance(distanceMeters), style: const TextStyle(color: Color(0xFF888888), fontSize: 13)),
                const SizedBox(height: 12),

                // ✅ Keep Wave / Chat / Meet on ONE line
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
                            (canInteract && directionsUnlocked) ? "Meet" : "Meet 🔒",
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
                    child: Text("Wave is only available within 1 km.",
                        style: TextStyle(color: Color(0xFF6B7280), fontSize: 12.5)),
                  ),
                if (canInteract && !chatUnlocked)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text("Wave 👋 — if they wave back, Chat & Meet unlock.",
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