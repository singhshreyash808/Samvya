import 'package:flutter/material.dart';

class AdminStatusBadge extends StatelessWidget {
  final String status;

  const AdminStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final cleanStatus = status.toUpperCase().replaceAll('_', ' ');
    Color bgColor;
    Color textColor;
    IconData icon;

    switch (cleanStatus) {
      case 'SUCCESS':
      case 'APPROVED':
      case 'RESOLVED':
      case 'ACTIVE':
      case 'LOW':
        bgColor = const Color(0xFF10B981).withOpacity(0.15);
        textColor = const Color(0xFF10B981);
        icon = Icons.check_circle_outline;
        break;

      case 'PENDING':
      case 'IN PROGRESS':
      case 'OPEN':
      case 'MEDIUM':
      case 'INVESTIGATING':
        bgColor = const Color(0xFFA855F7).withOpacity(0.15);
        textColor = const Color(0xFFA855F7);
        icon = Icons.hourglass_empty_rounded;
        break;

      case 'FAILED':
      case 'REJECTED':
      case 'HIGH':
      case 'CRITICAL':
      case 'SUSPENDED':
      case 'FLAGGED':
        bgColor = const Color(0xFFEF4444).withOpacity(0.15);
        textColor = const Color(0xFFEF4444);
        icon = Icons.warning_amber_rounded;
        break;

      case 'SUPER ADMIN':
        bgColor = const Color(0xFF0F9D8A).withOpacity(0.2);
        textColor = const Color(0xFF0F9D8A);
        icon = Icons.verified_user_rounded;
        break;

      default:
        bgColor = Colors.blue.withOpacity(0.15);
        textColor = Colors.blue;
        icon = Icons.info_outline;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: textColor.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: textColor),
          const SizedBox(width: 4),
          Text(
            cleanStatus,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: textColor,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
