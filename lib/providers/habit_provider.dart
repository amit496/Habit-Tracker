import 'dart:io';

import 'package:flutter/material.dart';

import '../core/theme/brand.dart';
import '../core/utils/date_utils.dart';
import '../models/habit_log_model.dart';
import '../models/habit_model.dart';
import '../services/analytics_service.dart';
import '../services/backup_service.dart';
import '../services/export_service.dart';
import '../services/hive_service.dart';
import '../services/reminder_service.dart';
import '../services/reminder_sound_storage.dart';
import '../services/streak_service.dart';

class HabitProvider extends ChangeNotifier {
  List<HabitModel> _habits = [];
  List<HabitLogModel> _logs = [];
  bool _isDarkMode = false;
  int _weekStart = 1;
  String? _categoryFilter;
  Set<String> _frozenDateKeys = {};

  HabitProvider() {
    loadAll();
  }

  List<HabitModel> get activeHabits =>
      _habits.where((h) => !h.archived).toList();

  List<HabitModel> get archivedHabits =>
      _habits.where((h) => h.archived).toList();

  List<HabitModel> get allHabits => List.unmodifiable(_habits);
  List<HabitLogModel> get allLogs => List.unmodifiable(_logs);
  bool get isDarkMode => _isDarkMode;
  int get weekStart => _weekStart;
  String? get categoryFilter => _categoryFilter;
  Set<String> get frozenDateKeys => Set.unmodifiable(_frozenDateKeys);

  bool get hasCompletedOnboarding =>
      HiveService.getSetting('onboardingComplete', defaultValue: false) == true;

  List<HabitModel> habitsForDate(DateTime date, {bool includeRest = false}) {
    final day = DateOnly.of(date);
    var list = activeHabits.where((h) => h.isScheduledOn(day)).toList();
    if (_categoryFilter != null) {
      list = list.where((h) => h.categoryKey == _categoryFilter).toList();
    }
    return list;
  }

  List<HabitModel> restHabitsForDate(DateTime date) {
    final day = DateOnly.of(date);
    return activeHabits.where((h) => !h.isScheduledOn(day)).toList();
  }

  List<HabitModel> get activeHabitsFiltered {
    if (_categoryFilter == null) return activeHabits;
    return activeHabits.where((h) => h.categoryKey == _categoryFilter).toList();
  }

  List<HabitLogModel> logsForDate(DateTime date) {
    final key = DateOnly.key(DateOnly.of(date));
    return _logs.where((l) => l.dateKey == key).toList();
  }

  List<HabitLogModel> logsForHabit(String habitId) =>
      _logs.where((l) => l.habitId == habitId).toList()
        ..sort((a, b) => b.date.compareTo(a.date));

  HabitLogModel? logFor(HabitModel habit, DateTime date) {
    final key = DateOnly.key(DateOnly.of(date));
    try {
      return _logs.firstWhere(
        (l) => l.habitId == habit.id && l.dateKey == key,
      );
    } catch (_) {
      return null;
    }
  }

  double get todayCompletionRate => AnalyticsService.todayCompletionRate(
        habitsForDate(DateOnly.today()),
        logsForDate(DateOnly.today()),
      );

  List<double> get last7DaysRates =>
      AnalyticsService.last7DaysRates(activeHabits, _logs);

  List<double> last30DaysRatesFor(HabitModel habit) =>
      AnalyticsService.last30DaysRatesFor(habit, _logs);

  int get globalStreak => StreakService.globalCurrentStreak(
        activeHabits,
        _logs,
        frozenDateKeys: _frozenDateKeys,
      );

  int get monthCompletions => AnalyticsService.completionsThisMonth(_logs);

  List<int> get yearHeatmapLevels =>
      AnalyticsService.yearHeatmapLevels(activeHabits, _logs);

  bool isDateFrozen(DateTime date) =>
      _frozenDateKeys.contains(DateOnly.key(DateOnly.of(date)));

  List<String> get frozenDatesSorted {
    final list = _frozenDateKeys.toList()..sort();
    return list.reversed.toList();
  }

  void _migrateHabitColorsInHive() {
    for (final key in HiveService.habits.keys.toList()) {
      final raw = Map<dynamic, dynamic>.from(HiveService.habits.get(key) as Map);
      final old = (raw['colorValue'] as num?)?.toInt();
      final normalized = Brand.normalizeHabitColor(old);
      if (old != normalized) {
        raw['colorValue'] = normalized;
        HiveService.habits.put(key, raw);
      }
    }
  }

  void loadAll() {
    _migrateHabitColorsInHive();
    _habits = HiveService.habits.values
        .map((e) => HabitModel.fromMap(Map<dynamic, dynamic>.from(e as Map)))
        .toList();
    _logs = HiveService.logs.values
        .map((e) => HabitLogModel.fromMap(Map<dynamic, dynamic>.from(e as Map)))
        .toList();
    _isDarkMode = HiveService.getSetting('isDarkMode', defaultValue: false);
    _weekStart = (HiveService.getSetting('weekStart', defaultValue: 1) as num)
        .toInt();
    final rawFrozen = HiveService.getSetting('frozenDates', defaultValue: []);
    _frozenDateKeys = rawFrozen is List
        ? rawFrozen.map((e) => e.toString()).toSet()
        : {};
    _syncReminders();
    notifyListeners();
  }

  void _syncReminders() {
    if (ReminderService.isReady) {
      ReminderService.rescheduleAll(activeHabits);
    }
  }

  Future<void> completeOnboarding() async {
    await HiveService.setSetting('onboardingComplete', true);
    notifyListeners();
  }

  void setCategoryFilter(String? key) {
    _categoryFilter = key;
    notifyListeners();
  }

  Future<void> addHabit(HabitModel habit) async {
    await HiveService.habits.put(habit.id, habit.toMap());
    loadAll();
  }

  Future<void> updateHabit(HabitModel habit) async {
    await HiveService.habits.put(habit.id, habit.toMap());
    loadAll();
  }

  Future<void> deleteHabit(String id) async {
    await HiveService.habits.delete(id);
    final toRemove =
        _logs.where((l) => l.habitId == id).map((l) => l.id).toList();
    for (final lid in toRemove) {
      await HiveService.logs.delete(lid);
    }
    loadAll();
  }

  Future<void> toggleToday(HabitModel habit) async {
    await _setCompletion(habit, DateOnly.today(), toggle: true);
  }

  Future<void> setCompletion(
    HabitModel habit,
    DateTime date, {
    required bool completed,
    int? count,
  }) async {
    await _setCompletion(
      habit,
      DateOnly.of(date),
      completed: completed,
      count: count,
    );
  }

  Future<void> _setCompletion(
    HabitModel habit,
    DateTime date, {
    bool toggle = false,
    bool? completed,
    int? count,
  }) async {
    final key = DateOnly.key(date);
    final existing = logFor(habit, date);
    HabitLogModel next;

    final keepNote = existing?.note ?? '';

    if (habit.hasTarget && count != null) {
      final done = count >= (habit.targetCount ?? 1);
      next = HabitLogModel(
        id: existing?.id ?? '${habit.id}_$key',
        habitId: habit.id,
        date: date,
        completed: done,
        count: count,
        note: keepNote,
      );
    } else if (toggle) {
      final wasDone = existing != null &&
          (existing.completed ||
              (habit.hasTarget &&
                  existing.count >= (habit.targetCount ?? 1)));
      next = HabitLogModel(
        id: existing?.id ?? '${habit.id}_$key',
        habitId: habit.id,
        date: date,
        completed: !wasDone,
        count: !wasDone ? 1 : 0,
        note: keepNote,
      );
    } else {
      next = HabitLogModel(
        id: existing?.id ?? '${habit.id}_$key',
        habitId: habit.id,
        date: date,
        completed: completed ?? false,
        count: count ?? (completed == true ? 1 : 0),
        note: keepNote,
      );
    }

    await HiveService.logs.put(next.id, next.toMap());
    loadAll();
  }

  int streakFor(HabitModel habit) => StreakService.currentStreakForHabit(
        habit,
        _logsForHabit(habit.id),
        frozenDateKeys: _frozenDateKeys,
      );

  int bestStreakFor(HabitModel habit) => StreakService.bestStreakForHabit(
        habit,
        _logsForHabit(habit.id),
        frozenDateKeys: _frozenDateKeys,
      );

  Future<void> freezeDate(DateTime date) async {
    final day = DateOnly.of(date);
    if (day.isAfter(DateOnly.today())) return;
    _frozenDateKeys.add(DateOnly.key(day));
    await HiveService.setSetting('frozenDates', _frozenDateKeys.toList()..sort());
    notifyListeners();
  }

  Future<void> unfreezeDate(DateTime date) async {
    _frozenDateKeys.remove(DateOnly.key(DateOnly.of(date)));
    await HiveService.setSetting('frozenDates', _frozenDateKeys.toList()..sort());
    notifyListeners();
  }

  Future<void> toggleFreezeDate(DateTime date) async {
    if (isDateFrozen(date)) {
      await unfreezeDate(date);
    } else {
      await freezeDate(date);
    }
  }

  Future<HabitModel> duplicateHabit(HabitModel habit) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    var customPath = '';
    if (habit.reminderCustomSoundPath.isNotEmpty) {
      final source = File(habit.reminderCustomSoundPath);
      if (await source.exists()) {
        customPath = await ReminderSoundStorage.copyCustomSound(source, id);
      }
    }
    final copy = HabitModel(
      id: id,
      name: '${habit.name} (copy)',
      iconKey: habit.iconKey,
      colorValue: habit.colorValue,
      targetCount: habit.targetCount,
      createdAt: DateTime.now(),
      reminderHour: habit.reminderHour,
      reminderMinute: habit.reminderMinute,
      reminderSoundKey: habit.reminderSoundKey,
      reminderCustomSoundPath: customPath,
      categoryKey: habit.categoryKey,
      scheduleDays: habit.scheduleDays,
    );
    await addHabit(copy);
    return copy;
  }

  List<HabitLogModel> _logsForHabit(String habitId) =>
      _logs.where((l) => l.habitId == habitId).toList();

  int dayCompletionCount(DateTime date) {
    final scheduled = habitsForDate(date);
    final logs = logsForDate(date);
    var done = 0;
    for (final h in scheduled) {
      final log = logs.where((l) => l.habitId == h.id).firstOrNull;
      if (log == null) continue;
      if (h.hasTarget) {
        if (log.count >= (h.targetCount ?? 1)) done++;
      } else if (log.completed) {
        done++;
      }
    }
    return done;
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    await HiveService.setSetting('isDarkMode', _isDarkMode);
    notifyListeners();
  }

  Future<void> setWeekStart(int value) async {
    _weekStart = value;
    await HiveService.setSetting('weekStart', value);
    notifyListeners();
  }

  Future<void> setArchived(HabitModel habit, bool archived) async {
    await updateHabit(habit.copyWith(archived: archived));
  }

  Future<void> updateLogNote(
    HabitModel habit,
    DateTime date,
    String note,
  ) async {
    final existing = logFor(habit, date);
    final key = DateOnly.key(DateOnly.of(date));
    final next = HabitLogModel(
      id: existing?.id ?? '${habit.id}_$key',
      habitId: habit.id,
      date: DateOnly.of(date),
      completed: existing?.completed ?? false,
      count: existing?.count ?? 0,
      note: note.trim(),
    );
    await HiveService.logs.put(next.id, next.toMap());
    loadAll();
  }

  Future<void> exportAndShareCsv() async {
    final csv = ExportService.buildCsv(habits: _habits, logs: _logs);
    await ExportService.shareCsv(csv);
  }

  Future<void> exportAndShareBackup() async {
    final json = BackupService.buildJson(
      habits: _habits,
      logs: _logs,
      isDarkMode: _isDarkMode,
      weekStart: _weekStart,
      frozenDates: _frozenDateKeys.toList()..sort(),
    );
    await BackupService.shareJson(json);
  }

  Future<void> restoreFromBackup(String raw) async {
    final result = BackupService.parse(raw);
    await HiveService.habits.clear();
    await HiveService.logs.clear();
    for (final h in result.habits) {
      await HiveService.habits.put(h.id, h.toMap());
    }
    for (final l in result.logs) {
      await HiveService.logs.put(l.id, l.toMap());
    }
    _isDarkMode = result.isDarkMode;
    _weekStart = result.weekStart;
    await HiveService.setSetting('isDarkMode', _isDarkMode);
    await HiveService.setSetting('weekStart', _weekStart);
    await HiveService.setSetting('frozenDates', result.frozenDates);
    loadAll();
  }
}

extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull {
    final it = iterator;
    if (!it.moveNext()) return null;
    return it.current;
  }
}
