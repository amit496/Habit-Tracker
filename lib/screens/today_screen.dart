import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../core/constants/habit_categories.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/date_utils.dart';
import '../models/habit_model.dart';
import '../providers/habit_provider.dart';
import '../widgets/habit_tile.dart';
import '../widgets/note_dialog.dart';
import '../widgets/screen_header.dart';
import '../widgets/streak_badge.dart';
import 'habit_detail_screen.dart';
import '../widgets/add_habit_sheet.dart';

class TodayScreen extends StatelessWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HabitProvider>();
    final today = DateOnly.today();
    final habits = provider.habitsForDate(today);
    final rest = provider.restHabitsForDate(today);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final rate = provider.todayCompletionRate;
    final done = (rate * habits.length).round();

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ScreenHeader(
                      subtitle: DateFormat('EEEE, MMM d').format(today),
                      title: 'Today',
                    ),
                    const SizedBox(height: 12),
                    _CategoryFilterChips(provider: provider),
                    const SizedBox(height: 12),
                    if (provider.isDateFrozen(today))
                      _FrozenDayBanner(provider: provider, date: today),
                    if (provider.globalStreak > 0) ...[
                      if (provider.isDateFrozen(today))
                        const SizedBox(height: 12),
                      StreakBadge(streak: provider.globalStreak),
                    ],
                    const SizedBox(height: 16),
                    _ProgressCard(
                      done: done,
                      total: habits.length,
                      rate: rate,
                    ),
                  ],
                ),
              ),
            ),
            if (habits.isEmpty && rest.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_task_rounded,
                          size: 64,
                          color:
                              isDark ? Colors.white24 : Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No habits yet',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap + to create your first habit',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: isDark ? Colors.white54 : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else ...[
              if (habits.isNotEmpty)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  sliver: SliverList.separated(
                    itemCount: habits.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, i) =>
                        _buildHabitTile(context, provider, habits[i], today),
                  ),
                ),
              if (rest.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                    child: Text(
                      'Rest day',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white54 : Colors.grey,
                      ),
                    ),
                  ),
                ),
              if (rest.isNotEmpty)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                  sliver: SliverList.separated(
                    itemCount: rest.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, i) => Opacity(
                      opacity: 0.55,
                      child: _buildHabitTile(
                        context,
                        provider,
                        rest[i],
                        today,
                        restDay: true,
                      ),
                    ),
                  ),
                )
              else
                const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
            ],
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showAddHabitSheet(context),
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  Widget _buildHabitTile(
    BuildContext context,
    HabitProvider provider,
    HabitModel habit,
    DateTime today, {
    bool restDay = false,
  }) {
    final log = provider.logFor(habit, today);
    final isDone = habit.hasTarget
        ? (log?.count ?? 0) >= (habit.targetCount ?? 1)
        : (log?.completed ?? false);
    final hasNote = (log?.note ?? '').isNotEmpty;

    return HabitTile(
      habit: habit,
      isDone: isDone,
      currentCount: log?.count,
      hasNote: hasNote,
      onLongPress: () => showHabitNoteDialog(
        context: context,
        provider: provider,
        habit: habit,
        date: today,
        initialNote: log?.note ?? '',
      ),
      onToggle: restDay ? () {} : () => provider.toggleToday(habit),
      onIncrement: !restDay && habit.hasTarget
          ? () {
              final next = (log?.count ?? 0) + 1;
              provider.setCompletion(
                habit,
                today,
                completed: next >= (habit.targetCount ?? 1),
                count: next,
              );
            }
          : null,
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => HabitDetailScreen(habit: habit),
        ),
      ),
    );
  }
}

class _FrozenDayBanner extends StatelessWidget {
  final HabitProvider provider;
  final DateTime date;

  const _FrozenDayBanner({required this.provider, required this.date});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.primaryFor(context).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryFor(context).withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.ac_unit_rounded,
            size: 20,
            color: AppTheme.primaryFor(context),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Streak freeze — today won\'t break your streak',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
          TextButton(
            onPressed: () => provider.unfreezeDate(date),
            child: const Text('Undo'),
          ),
        ],
      ),
    );
  }
}

class _CategoryFilterChips extends StatelessWidget {
  final HabitProvider provider;

  const _CategoryFilterChips({required this.provider});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selected = provider.categoryFilter;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          FilterChip(
            label: const Text('All'),
            selected: selected == null,
            onSelected: (_) => provider.setCategoryFilter(null),
            selectedColor: AppTheme.primaryFor(context).withValues(alpha: 0.12),
          ),
          const SizedBox(width: 6),
          ...HabitCategories.all.map((c) {
            final hasHabits = provider.activeHabits
                .any((h) => h.categoryKey == c.key);
            if (!hasHabits) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(right: 6),
              child: FilterChip(
                avatar: Icon(c.icon, size: 16),
                label: Text(c.label),
                selected: selected == c.key,
                onSelected: (_) => provider.setCategoryFilter(
                  selected == c.key ? null : c.key,
                ),
                selectedColor: AppTheme.primaryFor(context).withValues(alpha: 0.12),
                labelStyle: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  final int done;
  final int total;
  final double rate;

  const _ProgressCard({
    required this.done,
    required this.total,
    required this.rate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.cardDecoration(context),
      child: Row(
        children: [
          SizedBox(
            width: 64,
            height: 64,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: total == 0 ? 0 : rate,
                  strokeWidth: 6,
                  backgroundColor: Theme.of(context)
                      .colorScheme
                      .outline
                      .withValues(alpha: 0.3),
                  color: AppTheme.primaryFor(context),
                ),
                Center(
                  child: Text(
                    '${(rate * 100).round()}%',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Daily progress',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  total == 0
                      ? 'No habits scheduled today'
                      : '$done of $total habits completed',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.mutedText(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
