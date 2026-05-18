import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../core/utils/date_utils.dart';

class YearHeatmap extends StatelessWidget {
  final List<int> levels;
  final int weekStart;

  const YearHeatmap({
    super.key,
    required this.levels,
    this.weekStart = 1,
  });

  @override
  Widget build(BuildContext context) {
    if (levels.isEmpty) return const SizedBox.shrink();

    final today = DateOnly.today();
    final start = today.subtract(Duration(days: levels.length - 1));
    final pad = (start.weekday - weekStart + 7) % 7;

    final cells = <int?>[];
    for (var i = 0; i < pad; i++) {
      cells.add(null);
    }
    cells.addAll(levels);
    while (cells.length % 7 != 0) {
      cells.add(null);
    }

    final weekCount = cells.length ~/ 7;
    const cellSize = 11.0;
    const gap = 3.0;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(weekCount, (col) {
          return Padding(
            padding: EdgeInsets.only(right: col < weekCount - 1 ? gap : 0),
            child: Column(
              children: List.generate(7, (row) {
                final index = col * 7 + row;
                final level = cells[index];
                return Padding(
                  padding: EdgeInsets.only(bottom: row < 6 ? gap : 0),
                  child: _HeatCell(
                    level: level,
                    size: cellSize,
                    context: context,
                  ),
                );
              }),
            ),
          );
        }),
      ),
    );
  }
}

class _HeatCell extends StatelessWidget {
  final int? level;
  final double size;
  final BuildContext context;

  const _HeatCell({
    required this.level,
    required this.size,
    required this.context,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = AppTheme.primaryFor(context);

    Color color;
    if (level == null) {
      color = Colors.transparent;
    } else if (level == 0) {
      color = isDark
          ? Colors.white.withValues(alpha: 0.06)
          : Colors.black.withValues(alpha: 0.05);
    } else {
      final alpha = 0.2 + (level! / 4) * 0.65;
      color = primary.withValues(alpha: alpha);
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2.5),
      ),
    );
  }
}
