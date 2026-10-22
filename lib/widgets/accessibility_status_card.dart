import 'package:flutter/material.dart';
import 'package:power_control/models/accessibility_service_status.dart';

class AccessibilityStatusCard extends StatelessWidget {
  const AccessibilityStatusCard({
    required this.status,
    super.key,
  });

  final AccessibilityServiceStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, icon, color) = switch (status) {
      AccessibilityServiceStatus.checking => (
        'Checking accessibility status',
        Icons.hourglass_top_rounded,
        const Color(0xFFFFC857),
      ),
      AccessibilityServiceStatus.enabled => (
        'Accessibility enabled',
        Icons.check_circle_rounded,
        const Color(0xFF5CE0A0),
      ),
      AccessibilityServiceStatus.disabled => (
        'Accessibility disabled',
        Icons.info_rounded,
        const Color(0xFFFFC857),
      ),
      AccessibilityServiceStatus.unavailable => (
        'Accessibility status unavailable',
        Icons.error_rounded,
        const Color(0xFFFF7777),
      ),
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F29),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (status == AccessibilityServiceStatus.checking)
            const SizedBox.square(
              dimension: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
        ],
      ),
    );
  }
}
