import 'package:flutter_test/flutter_test.dart';
import 'package:habit_flow/services/analytics_service.dart';
import 'package:habit_flow/models/habit_model.dart';
import 'package:habit_flow/models/habit_log_model.dart';
import 'package:habit_flow/core/utils/date_utils.dart';

void main() {
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
