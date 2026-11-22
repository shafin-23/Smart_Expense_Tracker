import 'package:material_ui/material_ui.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../providers/budget_provider.dart';

class BudgetScreen extends ConsumerWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgets = ref.watch(budgetsProvider);

    final now = DateTime.now();

    final monthlyBudgets = budgets
        .where((b) => b.month == now.month && b.year == now.year)
        .toList();

    final totalBudget = monthlyBudgets.fold<double>(
      0,
      (sum, budget) => sum + budget.amount,
    );

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'My Budget',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            const Text(
              'Manage your monthly spending limits',
              style: TextStyle(color: AppColors.textSecondary),
            ),

            const SizedBox(height: 25),

            // Total budget card
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
                    style: TextStyle(color: AppColors.textSecondary),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    '৳${totalBudget.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    '${monthlyBudgets.length} categories configured',
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // Category heading
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Category Budgets',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                TextButton.icon(
                  onPressed: () {
                    _showBudgetDialog(context, ref);
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add'),
                ),
              ],
            ),

            const SizedBox(height: 10),

            if (monthlyBudgets.isEmpty)
              Container(
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
                      'Add a category budget to get started.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              )
            else
              ...monthlyBudgets.map((budget) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              budget.category,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 7),
                            Text(
                              'Budget: ৳${budget.amount.toStringAsFixed(0)}',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),

                      PopupMenuButton<String>(
                        onSelected: (value) async {
                          if (value == 'edit') {
                            _showBudgetDialog(context, ref, budget: budget);
                          } else if (value == 'delete') {
                            try {
                              await ref
                                  .read(budgetsProvider.notifier)
                                  .deleteBudget(budget.id);

                              debugPrint('DELETE SUCCESS: ${budget.category}');
                            } catch (e) {
                              debugPrint('DELETE ERROR: $e');
                            }
                          }
                        },
                        itemBuilder: (context) => const [
                          PopupMenuItem(value: 'edit', child: Text('Edit')),
                          PopupMenuItem(value: 'delete', child: Text('Delete')),
                        ],
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

  void _showBudgetDialog(
    BuildContext context,
    WidgetRef ref, {
    dynamic budget,
  }) {
    final categoryController = TextEditingController(
      text: budget?.category ?? '',
    );

    final amountController = TextEditingController(
      text: budget?.amount.toString() ?? '',
    );

    final isEditing = budget != null;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(isEditing ? 'Edit Budget' : 'Add Budget'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: categoryController,
                enabled: !isEditing,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  hintText: 'e.g. Food',
                ),
              ),

              const SizedBox(height: 15),

              TextField(
                controller: amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Budget Amount',
                  prefixText: '৳ ',
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
                debugPrint('SAVE BUTTON PRESSED');

                final category = categoryController.text.trim();
                final amount = double.tryParse(amountController.text.trim());

                if (category.isEmpty || amount == null || amount <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Enter a valid category and amount'),
                    ),
                  );
                  return;
                }

                final now = DateTime.now();

                try {
                  debugPrint('VALIDATION SUCCESS');
                  debugPrint('Category: $category');
                  debugPrint('Amount: $amount');

                  await ref
                      .read(budgetsProvider.notifier)
                      .addBudget(
                        category: category,
                        amount: amount,
                        month: budget?.month ?? now.month,
                        year: budget?.year ?? now.year,
                      );

                  debugPrint('SAVE COMPLETED SUCCESSFULLY');

                  if (!dialogContext.mounted) return;

                  Navigator.pop(dialogContext);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Budget saved successfully')),
                  );
                } catch (e, stackTrace) {
                  debugPrint('BUDGET SAVE ERROR: $e');
                  debugPrint('STACK TRACE: $stackTrace');

                  if (!dialogContext.mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Unable to save budget: $e')),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    ).then((_) {
      categoryController.dispose();
      amountController.dispose();
    });
  }
}
