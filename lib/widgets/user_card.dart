import 'package:flutter/material.dart';
import '../models/ice_user.dart';
import '../utils/geo.dart';
import '../utils/status.dart';

class UserCard extends StatelessWidget {
  const UserCard({
    super.key,
    required this.user,
    required this.distanceM,
    required this.canSayHi,
    required this.onSayHi,
    required this.onAccept,
    required this.onClose,
  });

  final IceUser user;
  final double distanceM;
  final bool canSayHi;
  final VoidCallback onSayHi;
  final VoidCallback onAccept;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final badgeColor = statusColor(user.statusType);

    return Material(
      color: Colors.transparent,
      child: Container(
        width: 320,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFFF6F9FE).withOpacity(0.99),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFB0E6B6), width: 2),
          boxShadow: [BoxShadow(blurRadius: 24, color: Colors.black.withOpacity(0.06), offset: const Offset(0, 4))],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    user.name,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                ),
                IconButton(
                  onPressed: onClose,
                  icon: const Icon(Icons.close, color: Color(0xFF7C3AED)),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: user.interests.map((i) => Text('#$i', style: const TextStyle(color: Color(0xFF1688E8), fontSize: 14))).toList(),
            ),
            const SizedBox(height: 8),
            Text('Spark Points: ${user.sparkPoints}', style: const TextStyle(color: Color(0xFFE6B800), fontSize: 13)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(color: badgeColor, borderRadius: BorderRadius.circular(9)),
              child: Text(statusLabel(user.statusType), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
            ),
            const SizedBox(height: 8),
            Text(user.bio, style: const TextStyle(color: Color(0xFF6B7280), fontSize: 14)),
            const SizedBox(height: 8),
            Text('${prettyDistance(distanceM)} away', style: const TextStyle(color: Color(0xFF888888), fontSize: 14)),
            const SizedBox(height: 12),
            Row(
              children: [
                if (canSayHi)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onSayHi,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Say Hi 👋', style: TextStyle(fontWeight: FontWeight.w800)),
                    ),
                  ),
                if (canSayHi) const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onAccept,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFBBF24),
                      foregroundColor: const Color(0xFF222222),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Accept', style: TextStyle(fontWeight: FontWeight.w800)),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
