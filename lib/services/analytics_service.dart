import '../core/utils/date_utils.dart';
import '../models/habit_log_model.dart';
import '../models/habit_model.dart';

class AnalyticsService {
  static double todayCompletionRate(
    List<HabitModel> habits,
    List<HabitLogModel> todayLogs,
  ) {
    if (habits.isEmpty) return 0;
    var done = 0;
    for (final h in habits) {
      final log = todayLogs.where((l) => l.habitId == h.id).firstOrNull;
      if (log != null && _isDone(h, log)) done++;
    }
    return done / habits.length;
  }

  static bool _isDone(HabitModel habit, HabitLogModel log) {
    if (habit.hasTarget) return log.count >= (habit.targetCount ?? 1);
    return log.completed;
  }

  static List<double> last7DaysRates(
    List<HabitModel> habits,
    List<HabitLogModel> allLogs,
  ) {
    final rates = <double>[];
    final today = DateOnly.today();
    for (var i = 6; i >= 0; i--) {
      rates.add(_rateForDay(habits, allLogs, today.subtract(Duration(days: i))));
    }
    return rates;
  }

  static List<double> last30DaysRatesFor(
    HabitModel habit,
    List<HabitLogModel> allLogs,
  ) {
    final rates = <double>[];
    final today = DateOnly.today();
    for (var i = 29; i >= 0; i--) {
      final day = today.subtract(Duration(days: i));
      if (!habit.isScheduledOn(day)) {
        rates.add(-1);
        continue;
      }
      final key = DateOnly.key(day);
      final log = allLogs
          .where((l) => l.habitId == habit.id && l.dateKey == key)
          .firstOrNull;
      rates.add(log != null && _isDone(habit, log) ? 1.0 : 0.0);
    }
    return rates;
  }

  static double _rateForDay(
    List<HabitModel> habits,
    List<HabitLogModel> allLogs,
    DateTime day,
  ) {
    final scheduled = habits.where((h) => h.isScheduledOn(day)).toList();
    if (scheduled.isEmpty) return 0;
    final key = DateOnly.key(day);
    final dayLogs = allLogs.where((l) => l.dateKey == key).toList();
    var done = 0;
    for (final h in scheduled) {
      final log = dayLogs.where((l) => l.habitId == h.id).firstOrNull;
      if (log != null && _isDone(h, log)) done++;
    }
    return done / scheduled.length;
  }

  static int completionsThisMonth(List<HabitLogModel> logs) {
    final now = DateTime.now();
    return logs.where((l) {
      return l.date.year == now.year &&
          l.date.month == now.month &&
          l.completed;
    }).length;
  }
}

extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull {
    final it = iterator;
    if (!it.moveNext()) return null;
    return it.current;
  }
}
