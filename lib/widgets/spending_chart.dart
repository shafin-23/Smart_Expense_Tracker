import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_theme.dart';
import '../providers/app_preferences_provider.dart';
import '../providers/transaction_provider.dart';

class SpendingChart extends ConsumerWidget {
  final DateTime? selectedMonth;

  const SpendingChart({
    super.key,
    this.selectedMonth,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferences = ref.watch(appPreferencesProvider);
    final transactions = ref.watch(transactionsProvider);

    final currencySymbol = preferences.currencySymbol;

    final now = DateTime.now();

    final month = selectedMonth ??
        DateTime(now.year, now.month);

    // Five weekly expense buckets.
    final weeklyExpenses = List<double>.filled(5, 0);

    for (final transaction in transactions) {
      // Ignore income.
      if (transaction.isIncome) continue;

      // Only selected month's transactions.
      if (transaction.date.year != month.year ||
          transaction.date.month != month.month) {
        continue;
      }

      // Week 1: days 1-7
      // Week 2: days 8-14
      // Week 3: days 15-21
      // Week 4: days 22-28
      // Week 5: days 29-31
      final weekIndex = (transaction.date.day - 1) ~/ 7;

      if (weekIndex >= 0 && weekIndex < 5) {
        weeklyExpenses[weekIndex] += transaction.amount;
      }
    }

    final maxExpense = weeklyExpenses.fold<double>(
      0,
          (maximum, amount) => math.max(maximum, amount).toDouble(),
    );

    final maxY = maxExpense > 0
        ? maxExpense * 1.2
        : 1.0;

    final isCurrentMonth =
        month.year == now.year &&
            month.month == now.month;

    final currentWeekIndex = (now.day - 1) ~/ 7;

    const weekLabels = [
      '1-7',
      '8-14',
      '15-21',
      '22-28',
      '29-31',
    ];

    return Container(
      height: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: BarChart(
        BarChartData(
          maxY: maxY,
          minY: 0,
          alignment: BarChartAlignment.spaceAround,

          gridData: const FlGridData(show: false),

          borderData: FlBorderData(show: false),

          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (
                  group,
                  groupIndex,
                  rod,
                  rodIndex,
                  ) {
                return BarTooltipItem(
                  '$currencySymbol${rod.toY.toStringAsFixed(2)}',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                );
              },
            ),
          ),

          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(
                showTitles: false,
              ),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(
                showTitles: false,
              ),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(
                showTitles: false,
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();

                  if (index < 0 ||
                      index >= weekLabels.length) {
                    return const SizedBox();
                  }

                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      weekLabels[index],
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 10,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          barGroups: List.generate(5, (index) {
            final isCurrentWeek =
                isCurrentMonth &&
                    index == currentWeekIndex;

            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: weeklyExpenses[index],
                  width: 24,
                  color: isCurrentWeek
                      ? AppColors.primary
                      : AppColors.primary.withValues(
                    alpha: 0.35,
                  ),
                  borderRadius: BorderRadius.circular(5),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}