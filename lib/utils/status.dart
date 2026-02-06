import 'package:flutter/material.dart';
import '../models/ice_user.dart';

Color statusColor(StatusType t) {
  switch (t) {
    case StatusType.open:
      return const Color(0xFF10B981);
    case StatusType.shy:
      return const Color(0xFFFBBF24);
    case StatusType.curious:
      return const Color(0xFF38BDF8);
    case StatusType.busy:
      return const Color(0xFFEF4444);
  }
}

String statusLabel(StatusType t) {
  switch (t) {
    case StatusType.open:
      return "Open";
    case StatusType.shy:
      return "Shy";
    case StatusType.curious:
      return "Curious";
    case StatusType.busy:
      return "Busy";
  }
}