import 'package:flutter/material.dart';

class EmergencyButton extends StatelessWidget {
  final VoidCallback onTap;
  const EmergencyButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 201, 185, 7).withOpacity(0.92),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: const [
            BoxShadow(blurRadius: 16, color: Color(0x26000000), offset: Offset(0, 6)),
          ],
        ),
        child: const Center(
          child: Text(
            '?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
        ),
      ),
    );
  }
}