import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/habit_icons.dart';
import '../core/theme/app_theme.dart';
import '../widgets/screen_header.dart';
import '../models/habit_model.dart';
import '../providers/habit_provider.dart';
import '../widgets/streak_badge.dart';
import '../widgets/week_chart.dart';
import '../widgets/year_heatmap.dart';
import 'habit_detail_screen.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HabitProvider>();
    final habits = provider.activeHabits;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    HabitModel? topHabit;
    var topStreak = 0;
    for (final h in habits) {
      final s = provider.streakFor(h);
      if (s > topStreak) {
        topStreak = s;
        topHabit = h;
      }
    }

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        children: [
          const ScreenHeader(
            subtitle: 'Your momentum',
            title: 'Stats',
          ),
          const SizedBox(height: 20),
          if (provider.globalStreak > 0) ...[
            StreakBadge(
              streak: provider.globalStreak,
              label: 'day all-habits streak',
            ),
            const SizedBox(height: 16),
          ],
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: 'This month',
                  value: '${provider.monthCompletions}',
                  subtitle: 'completions',
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  label: 'Today',
                  value: '${(provider.todayCompletionRate * 100).round()}%',
                  subtitle: 'completion',
                  isDark: isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Last 7 days',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: AppTheme.cardDecoration(context),
            child: habits.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: Text('Add habits to see charts')),
                  )
                : WeekChart(rates: provider.last7DaysRates),
          ),
          const SizedBox(height: 24),
          Text(
            'Year at a glance',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Darker = more habits completed that day',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white54 : Colors.grey,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: AppTheme.cardDecoration(context),
            child: habits.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: Text('Add habits to see activity')),
                  )
                : YearHeatmap(
                    levels: provider.yearHeatmapLevels,
                    weekStart: provider.weekStart,
                  ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Per-habit streaks',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          if (habits.isEmpty)
            Text(
              'No habits yet',
              style: TextStyle(color: isDark ? Colors.white54 : Colors.grey),
            )
          else
            ...habits.map((h) {
              final current = provider.streakFor(h);
              final best = provider.bestStreakFor(h);
              return Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => HabitDetailScreen(habit: h),
                    ),
                  ),
                  child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: AppTheme.cardDecoration(context),
                child: Row(
                  children: [
                    Icon(HabitIcons.iconFor(h.iconKey), color: h.color),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(h.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600)),
                          Text(
                            'Current: $current • Best: $best',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.white54 : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (current > 0)
                      Text('🔥 $current',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
                ),
              );
            }),
          if (topHabit != null) ...[
            const SizedBox(height: 8),
            Text(
              'Top streak: ${topHabit.name} ($topStreak days)',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.white54 : Colors.grey.shade700,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String subtitle;
  final bool isDark;

  const _StatCard({
    required this.label,
    required this.value,
    required this.subtitle,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.mutedText(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white38 : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
