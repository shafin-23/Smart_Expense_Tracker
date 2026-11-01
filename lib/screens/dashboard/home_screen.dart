
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../providers/transaction_provider.dart';
import '../../widgets/balance_card.dart';
import '../../widgets/spending_chart.dart';
import '../../widgets/transaction_tile.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(transactionsProvider);

    final income = transactions
        .where((item) => item.isIncome)
        .fold<double>(0, (sum, item) => sum + item.amount);

    final expense = transactions
        .where((item) => !item.isIncome)
        .fold<double>(0, (sum, item) => sum + item.amount);

    final balance = income - expense;

    final recentTransactions = transactions.take(3).toList();

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back,',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Shafin 👋',
                        style: TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                CircleAvatar(
                  radius: 23,
                  backgroundColor: AppColors.surfaceLight,
                  child: const Icon(
                    Icons.person_outline,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 25),

            // Balance
            const Text(
              'My Wallet',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 12),

            BalanceCard(
              balance: balance,
              income: income,
              expense: expense,
            ),

            const SizedBox(height: 28),

            // Chart heading
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Spending Activity',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'This Week',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            const SpendingChart(),

            const SizedBox(height: 28),

            // Recent transactions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Transactions',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Navigation is handled by bottom bar.
                  },
                  child: const Text(
                    'Recent',
                    style: TextStyle(color: AppColors.primary),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            if (recentTransactions.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(25),
                  child: Text(
                    'No transactions yet',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              )
            else
              ...recentTransactions.map(
                    (transaction) => TransactionTile(
                  transaction: transaction,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
