import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../core/theme/brand.dart';
import '../core/utils/date_utils.dart';

class WeekChart extends StatelessWidget {
  final List<double> rates;

  const WeekChart({super.key, required this.rates});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final today = DateOnly.today();

    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          maxY: 1,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 0.25,
            getDrawingHorizontalLine: (_) => FlLine(
              color: isDark ? Colors.white10 : Colors.grey.shade200,
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                getTitlesWidget: (v, _) => Text(
                  '${(v * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 10,
                    color: isDark ? Colors.white38 : Colors.grey,
                  ),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (v, _) {
                  final i = v.toInt();
                  if (i < 0 || i >= 7) return const SizedBox.shrink();
                  final day = today.subtract(Duration(days: 6 - i));
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      DateFormat('E').format(day).substring(0, 1),
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.white54 : Colors.grey,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          barGroups: List.generate(7, (i) {
            final rate = i < rates.length ? rates[i] : 0.0;
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: rate.clamp(0.0, 1.0),
                  width: 16,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(6),
                  ),
                  color: Brand.accent,
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
