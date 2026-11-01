
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../providers/transaction_provider.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(transactionsProvider);

    final expenses =
    transactions.where((item) => !item.isIncome).toList();

    final Map<String, double> categoryTotals = {};

    for (final item in expenses) {
      categoryTotals[item.category] =
          (categoryTotals[item.category] ?? 0) + item.amount;
    }

    final totalExpense = expenses.fold<double>(
      0,
          (sum, item) => sum + item.amount,
    );

    const colors = [
      AppColors.primary,
      Color(0xFF5486FF),
      Color(0xFFFFB547),
      Color(0xFFFF647C),
      Color(0xFF9C7BFF),
    ];

    final entries = categoryTotals.entries.toList();

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Analytics',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Understand your spending habits',
              style: TextStyle(
                color: AppColors.textSecondary,
              ),
            ),

            const SizedBox(height: 25),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const Text(
                    'Total Expenses',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    '৳${totalExpense.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  if (totalExpense > 0)
                    SizedBox(
                      height: 190,
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 4,
                          centerSpaceRadius: 45,
                          sections: List.generate(
                            entries.length,
                                (index) {
                              final entry = entries[index];
                              final percentage =
                                  entry.value / totalExpense * 100;

                              return PieChartSectionData(
                                value: entry.value,
                                color: colors[index % colors.length],
                                radius: 48,
                                title: '${percentage.toStringAsFixed(0)}%',
                                titleStyle: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    )
                  else
                    const SizedBox(
                      height: 190,
                      child: Center(
                        child: Text(
                          'No expense data available',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              'Category Breakdown',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            ...List.generate(entries.length, (index) {
              final entry = entries[index];
              final percentage = totalExpense == 0
                  ? 0.0
                  : entry.value / totalExpense;

              return Padding(
                padding: const EdgeInsets.only(bottom: 18),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          height: 11,
                          width: 11,
                          decoration: BoxDecoration(
                            color: colors[index % colors.length],
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(child: Text(entry.key)),
                        Text(
                          '৳${entry.value.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 9),
                    LinearProgressIndicator(
                      value: percentage,
                      minHeight: 6,
                      backgroundColor: AppColors.surfaceLight,
                      color: colors[index % colors.length],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
