import 'package:flutter/material.dart';
import '../models/ice_user.dart';
import '../utils/status.dart';

class StatusSelectorSheet extends StatelessWidget {
  final StatusType current;
  final ValueChanged<StatusType> onSelect;

  const StatusSelectorSheet({super.key, required this.current, required this.onSelect});

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