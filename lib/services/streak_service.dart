import '../core/utils/date_utils.dart';
import '../models/habit_log_model.dart';
import '../models/habit_model.dart';

class StreakService {
  static bool _isDone(HabitModel habit, HabitLogModel? log) {
    if (log == null) return false;
    if (habit.hasTarget) return log.count >= (habit.targetCount ?? 1);
    return log.completed;
  }

  static int currentStreakForHabit(
    HabitModel habit,
    List<HabitLogModel> logs,
  ) {
    final byDate = {for (final l in logs) l.dateKey: l};
    var streak = 0;
    var day = DateOnly.today();
    const maxLookback = 400;

    for (var i = 0; i < maxLookback; i++) {
      if (!habit.isScheduledOn(day)) {
        day = day.subtract(const Duration(days: 1));
        continue;
      }
      final key = DateOnly.key(day);
      if (!_isDone(habit, byDate[key])) break;
      streak++;
      day = day.subtract(const Duration(days: 1));
    }
    return streak;
  }

  static int bestStreakForHabit(
    HabitModel habit,
    List<HabitLogModel> logs,
  ) {
    final doneKeys = <String>{};
    for (final l in logs) {
      if (_isDone(habit, l) && habit.isScheduledOn(l.date)) {
        doneKeys.add(l.dateKey);
      }
    }
    if (doneKeys.isEmpty) return 0;

    var best = 0;
    for (final key in doneKeys) {
      final start = DateOnly.parseKey(key);
      if (start == null) continue;
      var cursor = start;
      var run = 0;
      while (doneKeys.contains(DateOnly.key(cursor))) {
        run++;
        cursor = _previousScheduledDay(habit, cursor);
      }
      if (run > best) best = run;
    }
    return best;
  }

  static DateTime _previousScheduledDay(HabitModel habit, DateTime day) {
    var d = day.subtract(const Duration(days: 1));
    for (var i = 0; i < 14; i++) {
      if (habit.isScheduledOn(d)) return DateOnly.of(d);
      d = d.subtract(const Duration(days: 1));
    }
    return DateOnly.of(day.subtract(const Duration(days: 1)));
  }

  static int globalCurrentStreak(
    List<HabitModel> habits,
    List<HabitLogModel> allLogs,
  ) {
    if (habits.isEmpty) return 0;
    var streak = 0;
    var day = DateOnly.today();
    const maxLookback = 400;

    for (var i = 0; i < maxLookback; i++) {
      final scheduled = habits.where((h) => h.isScheduledOn(day)).toList();
      if (scheduled.isEmpty) {
        day = day.subtract(const Duration(days: 1));
        continue;
      }
      final key = DateOnly.key(day);
      final dayLogs = allLogs.where((l) => l.dateKey == key).toList();
      final allDone = scheduled.every((h) {
        HabitLogModel? log;
        for (final l in dayLogs) {
          if (l.habitId == h.id) {
            log = l;
            break;
          }
        }
        return _isDone(h, log);
      });
      if (!allDone) break;
      streak++;
      day = day.subtract(const Duration(days: 1));
    }
    return streak;
  }
}
