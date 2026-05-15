import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../core/constants/reminder_sounds.dart';
import '../models/habit_model.dart';

class ReminderService {
  ReminderService._();

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static bool _ready = false;
  static const int _idBase = 2000;
  static const int _previewId = 9999;

  static bool get isReady => _ready;

  static Future<void> init() async {
    if (_ready) return;
    try {
      tz_data.initializeTimeZones();
      try {
        final name = await FlutterTimezone.getLocalTimezone();
        tz.setLocalLocation(tz.getLocation(name));
      } catch (_) {
        tz.setLocalLocation(tz.getLocation('UTC'));
      }

      const android = AndroidInitializationSettings('@mipmap/ic_launcher');
      await _plugin.initialize(
        const InitializationSettings(
          android: android,
          iOS: DarwinInitializationSettings(),
        ),
      );

      if (Platform.isAndroid) {
        await _createAndroidChannels();
        await _plugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.requestNotificationsPermission();
      }

      _ready = true;
    } on MissingPluginException catch (e) {
      debugPrint('ReminderService: plugin not linked ($e). Run full restart.');
      _ready = false;
    } catch (e) {
      debugPrint('ReminderService init failed: $e');
      _ready = false;
    }
  }

  static Future<void> _createAndroidChannels() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android == null) return;

    for (final sound in ReminderSounds.builtIn) {
      final raw = sound.rawName;
      if (raw == null) continue;
      await android.createNotificationChannel(
        AndroidNotificationChannel(
          _channelId(sound.key),
          'Habit reminders · ${sound.label}',
          description: 'Reminder tone: ${sound.label}',
          importance: Importance.high,
          playSound: true,
          sound: RawResourceAndroidNotificationSound(raw),
        ),
      );
    }

    await android.createNotificationChannel(
      const AndroidNotificationChannel(
        'habit_reminders_custom',
        'Habit reminders · Custom',
        description: 'Your own reminder audio file',
        importance: Importance.high,
        playSound: true,
      ),
    );
  }

  static String _channelId(String soundKey) => 'habit_reminders_$soundKey';

  static AndroidNotificationSound? _androidSound(HabitModel habit) {
    if (habit.reminderSoundKey == ReminderSounds.customKey) {
      final path = habit.reminderCustomSoundPath;
      if (path.isEmpty || !File(path).existsSync()) return null;
      return UriAndroidNotificationSound(Uri.file(path).toString());
    }
    final raw = ReminderSounds.optionFor(habit.reminderSoundKey).rawName;
    if (raw == null) return null;
    return RawResourceAndroidNotificationSound(raw);
  }

  static NotificationDetails _detailsFor(HabitModel habit) {
    final isCustom = habit.reminderSoundKey == ReminderSounds.customKey;
    final channelId = isCustom
        ? 'habit_reminders_custom'
        : _channelId(
            ReminderSounds.builtIn
                    .any((s) => s.key == habit.reminderSoundKey)
                ? habit.reminderSoundKey
                : ReminderSounds.defaultKey,
          );

    final sound = _androidSound(habit);

    return NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        'Habit reminders',
        channelDescription: 'Daily habit reminders',
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        sound: sound,
      ),
      iOS: const DarwinNotificationDetails(
        presentSound: true,
      ),
    );
  }

  static Future<void> rescheduleAll(List<HabitModel> habits) async {
    if (!_ready) return;
    await _plugin.cancelAll();
    var offset = 0;
    for (final h in habits) {
      if (h.archived || !h.hasReminder) continue;
      await _scheduleDaily(h, _idBase + offset);
      offset++;
    }
  }

  static Future<void> _scheduleDaily(HabitModel habit, int notificationId) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      habit.reminderHour,
      habit.reminderMinute,
    );
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      notificationId,
      'HabitFlow',
      'Time for: ${habit.name}',
      scheduled,
      _detailsFor(habit),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.wallClockTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// Play a one-shot preview (habit form "Test sound").
  static Future<void> previewSound(HabitModel habit) async {
    if (!_ready) return;
    await _plugin.show(
      _previewId,
      'HabitFlow preview',
      'Sound: ${ReminderSounds.labelFor(habit.reminderSoundKey)}',
      _detailsFor(habit),
    );
    Future.delayed(const Duration(seconds: 2), () {
      _plugin.cancel(_previewId);
    });
  }
}
