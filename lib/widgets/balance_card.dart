
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_preferences_provider.dart';

class BalanceCard extends ConsumerWidget {
  final double balance;
  final double income;
  final double expense;

  const BalanceCard({
    super.key,
    required this.balance,
    required this.income,
    required this.expense,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferences = ref.watch(appPreferencesProvider);
    final currencySymbol = preferences.currencySymbol;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF126B4A),
            Color(0xFF103A32),
            Color(0xFF172A2C),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.account_balance_wallet_outlined,
                color: Colors.white70,
              ),
              SizedBox(width: 8),
              Text(
                'Total Balance',
                style: TextStyle(color: Colors.white70),
              ),
              Spacer(),
              Icon(
                Icons.more_horiz,
                color: Colors.white,
              ),
            ],
          ),

          const SizedBox(height: 15),

          Text(
            '$currencySymbol${balance.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 26),

          Row(
            children: [
              Expanded(
                child: _info(
                  Icons.arrow_downward,
                  'Income',
                  income,
                  currencySymbol,
                ),
              ),
              Expanded(
                child: _info(
                  Icons.arrow_upward,
                  'Expense',
                  expense,
                  currencySymbol,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _info(
      IconData icon,
      String title,
      double amount,
      String currencySymbol,
      ) {
    return Row(
      children: [
        CircleAvatar(
          radius: 17,
          backgroundColor: Colors.white.withValues(alpha: 0.15),
          child: Icon(
            icon,
            size: 17,
            color: Colors.white,
          ),
        ),

        const SizedBox(width: 9),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                '$currencySymbol${amount.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
