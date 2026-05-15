import 'package:flutter/material.dart';

import '../core/constants/habit_categories.dart';
import '../core/constants/habit_icons.dart';
import '../core/theme/app_theme.dart';
import '../models/habit_model.dart';

class HabitTile extends StatelessWidget {
  final HabitModel habit;
  final bool isDone;
  final int? currentCount;
  final bool hasNote;
  final VoidCallback onToggle;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onIncrement;

  const HabitTile({
    super.key,
    required this.habit,
    required this.isDone,
    this.currentCount,
    this.hasNote = false,
    required this.onToggle,
    this.onTap,
    this.onLongPress,
    this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final category = HabitCategories.forKey(habit.categoryKey);
    final muted = AppTheme.mutedText(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: AppTheme.cardDecoration(context).copyWith(
            color: isDone
                ? habit.color.withValues(alpha: isDark ? 0.1 : 0.06)
                : null,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: habit.color.withValues(alpha: isDark ? 0.22 : 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    HabitIcons.iconFor(habit.iconKey),
                    color: habit.color,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              habit.name,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                          if (hasNote) ...[
                            const SizedBox(width: 6),
                            Icon(
                              Icons.sticky_note_2_outlined,
                              size: 16,
                              color: AppTheme.primaryFor(context),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        habit.hasTarget
                            ? '${currentCount ?? 0} / ${habit.targetCount}'
                            : habit.isDaily
                                ? category.label
                                : habit.scheduleLabel,
                        style: TextStyle(fontSize: 12, color: muted),
                      ),
                    ],
                  ),
                ),
                if (habit.hasTarget && onIncrement != null)
                  IconButton(
                    onPressed: onIncrement,
                    icon: Icon(Icons.add_circle_outline_rounded,
                        color: habit.color),
                  ),
                GestureDetector(
                  onTap: onToggle,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isDone
                          ? habit.color
                          : Colors.transparent,
                      border: isDone
                          ? null
                          : Border.all(
                              color: isDark
                                  ? AppTheme.darkBorder
                                  : AppTheme.lightBorder,
                              width: 2,
                            ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: isDone
                        ? const Icon(Icons.check_rounded,
                            size: 20, color: Colors.white)
                        : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
