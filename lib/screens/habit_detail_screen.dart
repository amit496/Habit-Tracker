import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../core/constants/habit_categories.dart';
import '../core/constants/habit_icons.dart';
import '../core/theme/app_theme.dart';
import '../models/habit_model.dart';
import '../providers/habit_provider.dart';
import 'habit_form_screen.dart';

class HabitDetailScreen extends StatelessWidget {
  final HabitModel habit;

  const HabitDetailScreen({super.key, required this.habit});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HabitProvider>();
    final logs = provider.logsForHabit(habit.id);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final current = provider.streakFor(habit);
    final best = provider.bestStreakFor(habit);
    final rates = provider.last30DaysRatesFor(habit);
    final category = HabitCategories.forKey(habit.categoryKey);
    final completedCount =
        logs.where((l) => l.completed || l.count > 0).length;

    return Scaffold(
      appBar: AppBar(
        title: Text(habit.name),
        actions: [
          IconButton(
            tooltip: 'Duplicate',
            icon: const Icon(Icons.copy_outlined),
            onPressed: () async {
              final copy = await provider.duplicateHabit(habit);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Created "${copy.name}"')),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => HabitFormScreen(habit: habit),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: habit.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  HabitIcons.iconFor(habit.iconKey),
                  color: habit.color,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(category.icon, size: 16, color: habit.color),
                        const SizedBox(width: 6),
                        Text(category.label,
                            style: TextStyle(
                              color: isDark ? Colors.white54 : Colors.grey,
                            )),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      habit.scheduleLabel,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white54 : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _StatBox(
                  label: 'Current streak',
                  value: '$current',
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatBox(
                  label: 'Best streak',
                  value: '$best',
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatBox(
                  label: 'Log entries',
                  value: '$completedCount',
                  isDark: isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Last 30 days',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            decoration: AppTheme.cardDecoration(context),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: rates.map((r) {
                if (r < 0) {
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 1),
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white12 : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  );
                }
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 1),
                    child: Container(
                      height: 28 * r + 4,
                      decoration: BoxDecoration(
                        color: r >= 1
                            ? habit.color
                            : habit.color.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'History',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          if (logs.isEmpty)
            Text(
              'No logs yet',
              style: TextStyle(color: isDark ? Colors.white54 : Colors.grey),
            )
          else
            ...logs.take(60).map((log) {
              final done = habit.hasTarget
                  ? log.count >= (habit.targetCount ?? 1)
                  : log.completed;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: AppTheme.cardDecoration(context),
                child: Row(
                  children: [
                    Icon(
                      done
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_unchecked_rounded,
                      color: done ? habit.color : Colors.grey,
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DateFormat('EEE, MMM d, yyyy').format(log.date),
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          if (habit.hasTarget)
                            Text(
                              '${log.count} / ${habit.targetCount}',
                              style: TextStyle(
                                fontSize: 12,
                                color:
                                    isDark ? Colors.white54 : Colors.grey,
                              ),
                            ),
                          if (log.note.isNotEmpty)
                            Text(
                              log.note,
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark
                                    ? Colors.white70
                                    : Colors.black54,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;

  const _StatBox({
    required this.label,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: AppTheme.cardDecoration(context),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? Colors.white54 : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
