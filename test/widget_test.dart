import 'package:flutter_test/flutter_test.dart';
import 'package:habit_flow/services/analytics_service.dart';
import 'package:habit_flow/services/streak_service.dart';
import 'package:habit_flow/models/habit_model.dart';
import 'package:habit_flow/models/habit_log_model.dart';
import 'package:habit_flow/core/utils/date_utils.dart';

void main() {
  test('streak freeze preserves streak', () {
    final habit = HabitModel(
      id: '1',
      name: 'Water',
      iconKey: 'water',
      colorValue: 0xFF6366F1,
      createdAt: DateTime.now(),
    );
    final today = DateOnly.today();
    final yesterday = today.subtract(const Duration(days: 1));
    final logs = [
      HabitLogModel(
        id: 'l1',
        habitId: '1',
        date: yesterday,
        completed: true,
      ),
    ];
    final frozen = {DateOnly.key(today)};
    expect(
      StreakService.currentStreakForHabit(
        habit,
        logs,
        frozenDateKeys: frozen,
      ),
      2,
    );
  });

  test('year heatmap returns 365 levels', () {
    final levels = AnalyticsService.yearHeatmapLevels([], []);
    expect(levels.length, 365);
  });

  test('today completion rate', () {
    final habits = [
      HabitModel(
        id: '1',
        name: 'Water',
        iconKey: 'water',
        colorValue: 0xFF7C3AED,
        createdAt: DateTime.now(),
      ),
    ];
    final logs = [
      HabitLogModel(
        id: 'l1',
        habitId: '1',
        date: DateOnly.today(),
        completed: true,
      ),
    ];
    expect(AnalyticsService.todayCompletionRate(habits, logs), 1.0);
  });
}
