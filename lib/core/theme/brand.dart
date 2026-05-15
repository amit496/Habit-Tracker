import 'package:flutter/material.dart';

/// One accent color (indigo) — clean light & dark. No blue/green gradient clash.
class Brand {
  Brand._();

  static const accent = Color(0xFF6366F1);
  static const accentDark = Color(0xFF818CF8);
  static const accentDeep = Color(0xFF4F46E5);

  static Color accentFor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? accentDark
        : accent;
  }

  /// Splash / branding — single-hue wash (not blue+green).
  static const splashGradient = LinearGradient(
    colors: [Color(0xFF4F46E5), Color(0xFF6366F1)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const splashGradientDark = LinearGradient(
    colors: [Color(0xFF1E1B4B), Color(0xFF312E81)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static LinearGradient splashFor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? splashGradientDark
        : splashGradient;
  }

  /// Harmonious habit colors (indigo / violet / slate family only).
  static const habitColorValues = [
    0xFF6366F1,
    0xFF8B5CF6,
    0xFF4F46E5,
    0xFF7C3AED,
    0xFF0EA5E9,
    0xFF64748B,
    0xFF475569,
    0xFF94A3B8,
  ];

  static int normalizeHabitColor(int? value) {
    if (value == null) return habitColorValues.first;
    if (habitColorValues.contains(value)) return value;
    return _legacyMap[value] ?? habitColorValues.first;
  }

  static const Map<int, int> _legacyMap = {
    0xFF2563EB: 0xFF6366F1,
    0xFF059669: 0xFF6366F1,
    0xFFE85D75: 0xFF8B5CF6,
    0xFF7C3AED: 0xFF7C3AED,
    0xFF3D5A80: 0xFF4F46E5,
    0xFFF4A261: 0xFF8B5CF6,
    0xFFEF4444: 0xFF6366F1,
    0xFFEC4899: 0xFF8B5CF6,
    0xFF14B8A6: 0xFF0EA5E9,
    0xFF10B981: 0xFF6366F1,
    0xFFF59E0B: 0xFF8B5CF6,
  };
}
