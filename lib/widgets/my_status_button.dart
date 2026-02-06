import 'package:flutter/material.dart';
import '../models/ice_user.dart';
import '../utils/status.dart';

class MyStatusButton extends StatelessWidget {
  final StatusType status;
  final VoidCallback onTap;

  const MyStatusButton({super.key, required this.status, required this.onTap});

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