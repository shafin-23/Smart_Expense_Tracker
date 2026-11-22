
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../providers/budget_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/app_preferences_provider.dart';

class BudgetScreen extends ConsumerWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgets = ref.watch(budgetsProvider);
    final transactions = ref.watch(transactionsProvider);
    final preferences = ref.watch(appPreferencesProvider);

    final currencySymbol = preferences.currencySymbol;
    final now = DateTime.now();

    final monthlyBudgets = budgets.where((budget) {
      return budget.month == now.month &&
          budget.year == now.year;
    }).toList();

    final monthlyExpenses = transactions.where((transaction) {
      return !transaction.isIncome &&
          transaction.date.year == now.year &&
          transaction.date.month == now.month;
    }).toList();

    double getCategorySpent(String category) {
      return monthlyExpenses
          .where(
            (transaction) =>
        transaction.category.toLowerCase() ==
            category.toLowerCase(),
      )
          .fold<double>(
        0,
            (sum, transaction) => sum + transaction.amount,
      );
    }

    final totalBudget = monthlyBudgets.fold<double>(
      0,
          (sum, budget) => sum + budget.amount,
    );

    final totalSpent = monthlyBudgets.fold<double>(
      0,
          (sum, budget) =>
      sum + getCategorySpent(budget.category),
    );

    final remaining = totalBudget - totalSpent;
    final isOverBudget = remaining < 0;

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

            const SizedBox(height: 8),

            const Text(
              'Manage your monthly spending limits',
              style: TextStyle(
                color: AppColors.textSecondary,
              ),
            ),

            const SizedBox(height: 25),

            // Monthly Summary Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total Monthly Budget',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    '$currencySymbol${totalBudget.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    children: [
                      _summaryItem(
                        'Total Spent',
                        currencySymbol,
                        totalSpent,
                        Colors.orange,
                      ),
                      _summaryItem(
                        isOverBudget ? 'Over Budget' : 'Remaining',
                        currencySymbol,
                        remaining.abs(),
                        isOverBudget ? Colors.red : Colors.green,
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: LinearProgressIndicator(
                      value: totalBudget > 0
                          ? (totalSpent / totalBudget)
                          .clamp(0.0, 1.0)
                          : 0,
                      minHeight: 10,
                      backgroundColor:
                      Colors.grey.withValues(alpha: 0.2),
                      valueColor:
                      AlwaysStoppedAnimation<Color>(
                        isOverBudget
                            ? Colors.red
                            : Colors.green,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    totalBudget == 0
                        ? 'Add a budget to start tracking.'
                        : isOverBudget
                        ? 'You exceeded your total budget by '
                        '$currencySymbol${remaining.abs().toStringAsFixed(0)}'
                        : 'You have used '
                        '${(totalSpent / totalBudget * 100).toStringAsFixed(1)}% '
                        'of your budget.',
                    style: TextStyle(
                      color: isOverBudget
                          ? Colors.red
                          : AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    '${monthlyBudgets.length} categories configured',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Category Heading
            Row(
              mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Category Budgets',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                TextButton.icon(
                  onPressed: () {
                    _showBudgetDialog(
                      context,
                      ref,
                      currencySymbol: currencySymbol,
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add'),
                ),
              ],
            ),

            const SizedBox(height: 12),

            if (monthlyBudgets.isEmpty)
              _emptyBudget(),

            ...monthlyBudgets.map((budget) {
              final spent = getCategorySpent(
                budget.category,
              );

              final left = budget.amount - spent;
              final overBudget = left < 0;

              final progress = budget.amount > 0
                  ? (spent / budget.amount).clamp(0.0, 1.0)
                  : 0.0;

              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: overBudget
                        ? Colors.red.withValues(alpha: 0.5)
                        : AppColors.border,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            budget.category,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),

                        PopupMenuButton<String>(
                          onSelected: (value) async {
                            if (value == 'edit') {
                              _showBudgetDialog(
                                context,
                                ref,
                                budget: budget,
                                currencySymbol: currencySymbol,
                              );
                            } else if (value == 'delete') {
                              try {
                                await ref
                                    .read(budgetsProvider.notifier)
                                    .deleteBudget(budget.id);

                                if (!context.mounted) return;

                                ScaffoldMessenger.of(context)
                                    .showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Budget deleted successfully',
                                    ),
                                  ),
                                );
                              } catch (e) {
                                debugPrint(
                                  'BUDGET DELETE ERROR: $e',
                                );
                              }
                            }
                          },
                          itemBuilder: (context) => const [
                            PopupMenuItem(
                              value: 'edit',
                              child: Text('Edit'),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Text('Delete'),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Spent: $currencySymbol${spent.toStringAsFixed(0)}',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          'Budget: $currencySymbol${budget.amount.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 9,
                        backgroundColor:
                        Colors.grey.withValues(alpha: 0.2),
                        valueColor:
                        AlwaysStoppedAnimation<Color>(
                          overBudget ? Colors.red : Colors.green,
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          overBudget
                              ? 'Over budget'
                              : 'Remaining',
                          style: TextStyle(
                            color: overBudget
                                ? Colors.red
                                : Colors.green,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),

                        Text(
                          '$currencySymbol${left.abs().toStringAsFixed(0)}'
                              '${overBudget ? ' exceeded' : ' left'}',
                          style: TextStyle(
                            color: overBudget
                                ? Colors.red
                                : Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),

                    if (overBudget) ...[
                      const SizedBox(height: 10),
                      const Row(
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.red,
                            size: 18,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'You have exceeded this budget!',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _summaryItem(
      String title,
      String currency,
      double amount,
      Color color,
      ) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '$currency${amount.toStringAsFixed(0)}',
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyBudget() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 45,
            color: AppColors.textSecondary,
          ),
          SizedBox(height: 12),
          Text(
            'No budgets added yet',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 5),
          Text(
            'Add a category budget to start tracking your expenses.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // Add / Edit Budget Dialog
  void _showBudgetDialog(
      BuildContext context,
      WidgetRef ref, {
        dynamic budget,
        required String currencySymbol,
      }) {
    final categories = [
      'Food',
      'Transport',
      'Shopping',
      'Bills',
      'Education',
      'Health',
      'Entertainment',
      'Other',
    ];

    String selectedCategory =
        budget?.category ?? categories.first;

    final amountController = TextEditingController(
      text: budget?.amount.toString() ?? '',
    );

    final isEditing = budget != null;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                isEditing ? 'Edit Budget' : 'Add Budget',
              ),

              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Category Dropdown
                  DropdownButtonFormField<String>(
                    initialValue: selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Select Category',
                      prefixIcon: Icon(
                        Icons.category_outlined,
                      ),
                      border: OutlineInputBorder(),
                    ),
                    items: categories.map((category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: isEditing
                        ? null
                        : (value) {
                      if (value != null) {
                        setDialogState(() {
                          selectedCategory = value;
                        });
                      }
                    },
                  ),

                  const SizedBox(height: 18),

                  // Budget Amount
                  TextField(
                    controller: amountController,
                    keyboardType:
                    const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Budget Amount',
                      prefixText: '$currencySymbol ',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ],
              ),

              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Cancel'),
                ),

                ElevatedButton(
                  onPressed: () async {
                    final amount = double.tryParse(
                      amountController.text.trim(),
                    );

                    if (amount == null ||
                        !amount.isFinite ||
                        amount <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Please enter a valid budget amount',
                          ),
                        ),
                      );
                      return;
                    }

                    final now = DateTime.now();

                    try {
                      await ref
                          .read(budgetsProvider.notifier)
                          .addBudget(
                        category: selectedCategory,
                        amount: amount,
                        month: budget?.month ?? now.month,
                        year: budget?.year ?? now.year,
                      );

                      if (!dialogContext.mounted) return;

                      Navigator.pop(dialogContext);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isEditing
                                ? 'Budget updated successfully'
                                : 'Budget added successfully',
                          ),
                        ),
                      );
                    } catch (e, stackTrace) {
                      debugPrint('BUDGET SAVE ERROR: $e');
                      debugPrintStack(
                        stackTrace: stackTrace,
                      );

                      if (!dialogContext.mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Unable to save budget: $e',
                          ),
                        ),
                      );
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    ).then((_) {
      amountController.dispose();
    });
  }
}
