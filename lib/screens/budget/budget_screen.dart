
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class BudgetScreen extends StatelessWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final budgets = [
      {
        'name': 'Food & Dining',
        'spent': 3500.0,
        'limit': 5000.0,
        'icon': Icons.restaurant,
      },
      {
        'name': 'Shopping',
        'spent': 2800.0,
        'limit': 4000.0,
        'icon': Icons.shopping_bag_outlined,
      },
      {
        'name': 'Transport',
        'spent': 1200.0,
        'limit': 3000.0,
        'icon': Icons.directions_car_outlined,
      },
    ];

    const totalBudget = 12000.0;
    const totalSpent = 7500.0;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'My Budget',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Monthly Budget',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                    ),
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    '৳12,000',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 18),

                  LinearProgressIndicator(
                    value: totalSpent / totalBudget,
                    minHeight: 10,
                    backgroundColor: AppColors.surfaceLight,
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),

                  const SizedBox(height: 12),

                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '৳7,500 spent',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        '৳4,500 left',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            const Text(
              'Category Budgets',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            ...budgets.map((budget) {
              final spent = budget['spent'] as double;
              final limit = budget['limit'] as double;
              final progress = spent / limit;

              return Container(
                margin: const EdgeInsets.only(bottom: 13),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(17),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          budget['icon'] as IconData,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            budget['name'] as String,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Text(
                          '৳${spent.toStringAsFixed(0)} / '
                              '৳${limit.toStringAsFixed(0)}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),

                    const SizedBox(height: 15),

                    LinearProgressIndicator(
                      value: progress.clamp(0.0, 1.0),
                      minHeight: 7,
                      backgroundColor: AppColors.surfaceLight,
                      color: progress >= 1
                          ? AppColors.expense
                          : AppColors.primary,
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
