
import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../models/transaction_model.dart';

class TransactionTile extends StatelessWidget {
  final TransactionModel transaction;
  final VoidCallback? onDelete;

  const TransactionTile({
    super.key,
    required this.transaction,
    this.onDelete,
  });

  IconData get categoryIcon {
    switch (transaction.category) {
      case 'Food':
        return Icons.restaurant;
      case 'Shopping':
        return Icons.shopping_bag_outlined;
      case 'Transport':
        return Icons.directions_car_outlined;
      case 'Entertainment':
        return Icons.movie_outlined;
      case 'Health':
        return Icons.medical_services_outlined;
      case 'Income':
        return Icons.account_balance_wallet_outlined;
      default:
        return Icons.category_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.isIncome;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(17),
      ),
      child: Row(
        children: [
          Container(
            height: 46,
            width: 46,
            decoration: BoxDecoration(
              color: (isIncome
                  ? AppColors.income
                  : AppColors.expense)
                  .withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              categoryIcon,
              color: isIncome
                  ? AppColors.income
                  : AppColors.expense,
            ),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${transaction.category} • '
                      '${transaction.date.day}/${transaction.date.month}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          Text(
            '${isIncome ? '+' : '-'}৳'
                '${transaction.amount.toStringAsFixed(0)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: isIncome
                  ? AppColors.income
                  : AppColors.expense,
            ),
          ),

          if (onDelete != null) ...[
            const SizedBox(width: 5),
            IconButton(
              onPressed: onDelete,
              icon: const Icon(
                Icons.delete_outline,
                color: AppColors.textSecondary,
                size: 20,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
