
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class SpendingChart extends StatelessWidget {
  const SpendingChart({super.key});

  @override
  Widget build(BuildContext context) {
    final values = [3.5, 5.0, 2.5, 6.5, 4.0, 7.5, 3.0];
    final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Container(
      height: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: BarChart(
        BarChartData(
          maxY: 9,
          minY: 0,
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),

          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();

                  if (index < 0 || index >= days.length) {
                    return const SizedBox();
                  }

                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      days[index],
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          barGroups: List.generate(
            values.length,
                (index) {
              return BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: values[index],
                    width: 16,
                    color: index == 5
                        ? AppColors.primary
                        : AppColors.primary.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
