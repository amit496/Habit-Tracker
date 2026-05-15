import 'package:flutter/material.dart';

import '../core/constants/habit_categories.dart';
import '../core/theme/brand.dart';

class HabitModel {
  final String id;
  final String name;
  final String iconKey;
  final int colorValue;
  final int? targetCount;
  final DateTime createdAt;
  final bool archived;
  /// -1 = no reminder. Otherwise daily at [reminderHour]:[reminderMinute].
  final int reminderHour;
  final int reminderMinute;
  /// Built-in: chime, bell, pulse, soft, alert. Or [ReminderSounds.customKey].
  final String reminderSoundKey;
  /// Local file path when [reminderSoundKey] is custom.
  final String reminderCustomSoundPath;
  final String categoryKey;
  /// Weekdays 1=Mon … 7=Sun. Empty = every day.
  final List<int> scheduleDays;

  const HabitModel({
    required this.id,
    required this.name,
    required this.iconKey,
    required this.colorValue,
    this.targetCount,
    required this.createdAt,
    this.archived = false,
    this.reminderHour = -1,
    this.reminderMinute = 0,
    this.reminderSoundKey = 'chime',
    this.reminderCustomSoundPath = '',
    this.categoryKey = HabitCategories.general,
    this.scheduleDays = const [],
  });

  Color get color => Color(colorValue);

  bool get hasTarget => targetCount != null && targetCount! > 0;

  bool get hasReminder => reminderHour >= 0 && reminderMinute >= 0;

  bool get isDaily => scheduleDays.isEmpty || scheduleDays.length >= 7;

  bool isScheduledOn(DateTime date) {
    if (isDaily) return true;
    return scheduleDays.contains(DateTime(date.year, date.month, date.day).weekday);
  }

  String get scheduleLabel {
    if (isDaily) return 'Every day';
    const names = ['', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final sorted = [...scheduleDays]..sort();
    return sorted.map((d) => names[d]).join(', ');
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'iconKey': iconKey,
        'colorValue': colorValue,
        'targetCount': targetCount,
        'createdAt': createdAt.toIso8601String(),
        'archived': archived,
        'reminderHour': reminderHour,
        'reminderMinute': reminderMinute,
        'reminderSoundKey': reminderSoundKey,
        'reminderCustomSoundPath': reminderCustomSoundPath,
        'categoryKey': categoryKey,
        'scheduleDays': scheduleDays,
      };

  factory HabitModel.fromMap(Map<dynamic, dynamic> map) {
    final rawDays = map['scheduleDays'];
    List<int> days = [];
    if (rawDays is List) {
      days = rawDays
          .map((e) => (e as num).toInt())
          .where((d) => d >= 1 && d <= 7)
          .toList();
    }
    return HabitModel(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      iconKey: map['iconKey']?.toString() ?? 'star',
      colorValue: Brand.normalizeHabitColor(
        (map['colorValue'] as num?)?.toInt(),
      ),
      targetCount: (map['targetCount'] as num?)?.toInt(),
      createdAt: DateTime.tryParse(map['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      archived: map['archived'] == true,
      reminderHour: (map['reminderHour'] as num?)?.toInt() ?? -1,
      reminderMinute: (map['reminderMinute'] as num?)?.toInt() ?? 0,
      reminderSoundKey:
          map['reminderSoundKey']?.toString() ?? 'chime',
      reminderCustomSoundPath:
          map['reminderCustomSoundPath']?.toString() ?? '',
      categoryKey:
          map['categoryKey']?.toString() ?? HabitCategories.general,
      scheduleDays: days,
    );
  }

  HabitModel copyWith({
    String? name,
    String? iconKey,
    int? colorValue,
    int? targetCount,
    bool clearTarget = false,
    bool? archived,
    int? reminderHour,
    int? reminderMinute,
    bool clearReminder = false,
    String? reminderSoundKey,
    String? reminderCustomSoundPath,
    String? categoryKey,
    List<int>? scheduleDays,
    bool clearSchedule = false,
  }) {
    return HabitModel(
      id: id,
      name: name ?? this.name,
      iconKey: iconKey ?? this.iconKey,
      colorValue: colorValue ?? this.colorValue,
      targetCount: clearTarget ? null : (targetCount ?? this.targetCount),
      createdAt: createdAt,
      archived: archived ?? this.archived,
      reminderHour: clearReminder ? -1 : (reminderHour ?? this.reminderHour),
      reminderMinute:
          clearReminder ? 0 : (reminderMinute ?? this.reminderMinute),
      reminderSoundKey: reminderSoundKey ?? this.reminderSoundKey,
      reminderCustomSoundPath:
          reminderCustomSoundPath ?? this.reminderCustomSoundPath,
      categoryKey: categoryKey ?? this.categoryKey,
      scheduleDays:
          clearSchedule ? [] : (scheduleDays ?? this.scheduleDays),
    );
  }
}
