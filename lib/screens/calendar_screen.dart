import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../core/theme/app_theme.dart';
import '../core/utils/date_utils.dart';
import '../widgets/screen_header.dart';
import '../models/habit_model.dart';
import '../providers/habit_provider.dart';
import '../widgets/habit_tile.dart';
import '../widgets/note_dialog.dart';
import 'habit_detail_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focused = DateOnly.today();
  DateTime _selected = DateOnly.today();
  CalendarFormat _format = CalendarFormat.month;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HabitProvider>();
    final habits = provider.habitsForDate(_selected);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: ScreenHeader(
              subtitle: 'Pick any day',
              title: 'Calendar',
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: TableCalendar(
              firstDay: DateTime(2020),
              lastDay: DateTime.now().add(const Duration(days: 365)),
              focusedDay: _focused,
              selectedDayPredicate: (d) =>
                  DateOnly.of(d) == DateOnly.of(_selected),
              calendarFormat: _format,
              startingDayOfWeek: provider.weekStart == 7
                  ? StartingDayOfWeek.sunday
                  : StartingDayOfWeek.monday,
              onFormatChanged: (f) => setState(() => _format = f),
              onDaySelected: (selected, focused) {
                setState(() {
                  _selected = DateOnly.of(selected);
                  _focused = focused;
                });
              },
              onPageChanged: (focused) => _focused = focused,
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: AppTheme.primaryFor(context).withValues(alpha: 0.25),
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: AppTheme.primaryFor(context),
                  shape: BoxShape.circle,
                ),
                markerDecoration: BoxDecoration(
                  color: AppTheme.primaryFor(context).withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: true,
                titleCentered: true,
                formatButtonDecoration: BoxDecoration(
                  color: isDark ? AppTheme.darkCard : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              eventLoader: (day) {
                final count = provider.dayCompletionCount(day);
                return count > 0 ? List.filled(count.clamp(1, 3), 'x') : [];
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    DateFormat('EEEE, MMM d').format(_selected),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                ),
                if (!DateOnly.of(_selected).isAfter(DateOnly.today()))
                  TextButton.icon(
                    onPressed: () async {
                      await provider.toggleFreezeDate(_selected);
                      if (context.mounted) {
                        final frozen = provider.isDateFrozen(_selected);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              frozen
                                  ? 'Streak freeze enabled for this day'
                                  : 'Streak freeze removed',
                            ),
                          ),
                        );
                      }
                    },
                    icon: Icon(
                      provider.isDateFrozen(_selected)
                          ? Icons.ac_unit_rounded
                          : Icons.ac_unit_outlined,
                      size: 18,
                    ),
                    label: Text(
                      provider.isDateFrozen(_selected) ? 'Frozen' : 'Freeze',
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: habits.isEmpty
                ? Center(
                    child: Text(
                      provider.activeHabits.isEmpty
                          ? 'No habits to show'
                          : 'No habits scheduled this day',
                      style: TextStyle(
                        color: isDark ? Colors.white54 : Colors.grey,
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    itemCount: habits.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, i) {
                      final habit = habits[i];
                      return _CalendarHabitRow(
                        habit: habit,
                        selected: _selected,
                        provider: provider,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _CalendarHabitRow extends StatelessWidget {
  final HabitModel habit;
  final DateTime selected;
  final HabitProvider provider;

  const _CalendarHabitRow({
    required this.habit,
    required this.selected,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    final log = provider.logFor(habit, selected);
    final isDone = habit.hasTarget
        ? (log?.count ?? 0) >= (habit.targetCount ?? 1)
        : (log?.completed ?? false);
    final isFuture = DateOnly.of(selected).isAfter(DateOnly.today());
    final hasNote = (log?.note ?? '').isNotEmpty;

    return Opacity(
      opacity: isFuture ? 0.5 : 1,
      child: HabitTile(
        habit: habit,
        isDone: isDone,
        currentCount: log?.count,
        hasNote: hasNote,
        onLongPress: () => showHabitNoteDialog(
          context: context,
          provider: provider,
          habit: habit,
          date: selected,
          initialNote: log?.note ?? '',
        ),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => HabitDetailScreen(habit: habit),
          ),
        ),
        onToggle: isFuture
            ? () {}
            : () async {
                final log = provider.logFor(habit, selected);
                final wasDone = habit.hasTarget
                    ? (log?.count ?? 0) >= (habit.targetCount ?? 1)
                    : (log?.completed ?? false);
                await provider.setCompletion(
                  habit,
                  selected,
                  completed: !wasDone,
                  count: !wasDone ? 1 : 0,
                );
              },
        onIncrement: !isFuture && habit.hasTarget
            ? () {
                final next = (log?.count ?? 0) + 1;
                provider.setCompletion(
                  habit,
                  selected,
                  completed: next >= (habit.targetCount ?? 1),
                  count: next,
                );
              }
            : null,
      ),
    );
  }
}
