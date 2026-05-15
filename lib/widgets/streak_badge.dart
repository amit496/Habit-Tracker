import 'package:flutter/material.dart';

import '../core/theme/brand.dart';

class StreakBadge extends StatelessWidget {
  final int streak;
  final String label;

  const StreakBadge({
    super.key,
    required this.streak,
    this.label = 'day streak',
  });

  @override
  Widget build(BuildContext context) {
    final accent = Brand.accentFor(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accent.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.local_fire_department_rounded, size: 18, color: accent),
          const SizedBox(width: 8),
          Text(
            '$streak $label',
            style: TextStyle(
              color: accent,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
