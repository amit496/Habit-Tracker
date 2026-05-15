import 'package:flutter/material.dart';

class ReminderSoundOption {
  final String key;
  final String label;
  final IconData icon;
  /// Android `res/raw` resource name (without extension).
  final String? rawName;

  const ReminderSoundOption({
    required this.key,
    required this.label,
    required this.icon,
    this.rawName,
  });
}

class ReminderSounds {
  ReminderSounds._();

  static const customKey = 'custom';
  static const defaultKey = 'chime';

  static const List<ReminderSoundOption> builtIn = [
    ReminderSoundOption(
      key: 'chime',
      label: 'Chime',
      icon: Icons.music_note_rounded,
      rawName: 'reminder_chime',
    ),
    ReminderSoundOption(
      key: 'bell',
      label: 'Bell',
      icon: Icons.notifications_active_rounded,
      rawName: 'reminder_bell',
    ),
    ReminderSoundOption(
      key: 'pulse',
      label: 'Pulse',
      icon: Icons.graphic_eq_rounded,
      rawName: 'reminder_pulse',
    ),
    ReminderSoundOption(
      key: 'soft',
      label: 'Soft',
      icon: Icons.nights_stay_rounded,
      rawName: 'reminder_soft',
    ),
    ReminderSoundOption(
      key: 'alert',
      label: 'Alert',
      icon: Icons.campaign_rounded,
      rawName: 'reminder_alert',
    ),
  ];

  static ReminderSoundOption optionFor(String key) {
    return builtIn.firstWhere(
      (o) => o.key == key,
      orElse: () => builtIn.first,
    );
  }

  static String labelFor(String key, {String? customFileName}) {
    if (key == customKey && customFileName != null && customFileName.isNotEmpty) {
      return 'Custom: $customFileName';
    }
    if (key == customKey) return 'Custom sound';
    return optionFor(key).label;
  }
}
