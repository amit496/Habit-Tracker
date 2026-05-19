import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

import '../core/constants/reminder_sounds.dart';
import '../models/habit_model.dart';

/// Plays reminder tones in-app (foreground). Notification [show] often has no sound
/// while the app is open on Android — this uses direct audio playback instead.
class ReminderSoundPlayer {
  ReminderSoundPlayer._();

  static final AudioPlayer _player = AudioPlayer()
    ..setReleaseMode(ReleaseMode.stop);

  static Future<void> preview(HabitModel habit) async {
    await _player.stop();

    if (habit.reminderSoundKey == ReminderSounds.customKey) {
      final path = habit.reminderCustomSoundPath;
      if (path.isEmpty || !File(path).existsSync()) {
        throw StateError('Select an audio file first');
      }
      await _player.play(DeviceFileSource(path));
      return;
    }

    final raw = ReminderSounds.optionFor(habit.reminderSoundKey).rawName;
    if (raw == null) {
      throw StateError('Unknown reminder sound');
    }

    await _player.play(AssetSource('sounds/$raw.wav'));
  }

  static Future<void> stop() => _player.stop();

  static Future<void> dispose() async {
    try {
      await _player.dispose();
    } catch (e) {
      debugPrint('ReminderSoundPlayer dispose: $e');
    }
  }
}
