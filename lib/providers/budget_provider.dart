import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/providers/database_provider.dart';
import '../core/database/app_database.dart' as db;

final budgetsProvider = NotifierProvider<BudgetNotifier, List<db.Budget>>(
  BudgetNotifier.new,
);

class BudgetNotifier extends Notifier<List<db.Budget>> {
  StreamSubscription<List<db.Budget>>? _subscription;

  @override
  List<db.Budget> build() {
    final dao = ref.watch(budgetDaoProvider);

    _subscription = dao.watchBudgets().listen(
      (budgets) {
        debugPrint('Budget stream updated: ${budgets.length} budgets found');

        state = budgets;
      },
      onError: (error) {
        debugPrint('Budget stream error: $error');
      },
    );

    ref.onDispose(() {
      _subscription?.cancel();
    });

    return [];
  }

  // Add or update a budget
  Future<void> addBudget({
    required String category,
    required double amount,
    required int month,
    required int year,
  }) async {
    if (category.trim().isEmpty) {
      throw ArgumentError('Category cannot be empty');
    }

    if (amount <= 0) {
      throw ArgumentError('Budget amount must be greater than zero');
    }

    final dao = ref.read(budgetDaoProvider);

    debugPrint('Saving budget: $category, $amount');

    await dao.addBudget(
      db.BudgetsCompanion.insert(
        category: category.trim(),
        amount: amount,
        month: month,
        year: year,
      ),
    );

    // Fetch all budgets directly from database
    final updatedBudgets = await dao.getAllBudgets();

    debugPrint('========== BUDGET DEBUG ==========');
    debugPrint('Saved category: $category');
    debugPrint('Saved amount: $amount');
    debugPrint('Saved month/year: $month/$year');
    debugPrint('Total budgets in database: ${updatedBudgets.length}');

    for (final budget in updatedBudgets) {
      debugPrint(
        'ID: ${budget.id}, '
        'Category: ${budget.category}, '
        'Amount: ${budget.amount}, '
        'Month: ${budget.month}, '
        'Year: ${budget.year}',
      );
    }

    // Update Riverpod state
    state = updatedBudgets;

    debugPrint('Provider state updated: ${state.length} budgets');
    debugPrint('=================================');
  }

  // Get budgets for a specific month
  Future<List<db.Budget>> getMonthlyBudgets(int month, int year) async {
    final dao = ref.read(budgetDaoProvider);

    return dao.getMonthlyBudgets(month, year);
  }

  // Delete a budget
  Future<void> deleteBudget(int id) async {
    final dao = ref.read(budgetDaoProvider);

    await dao.deleteBudget(id);

    final updatedBudgets = await dao.getAllBudgets();

    state = updatedBudgets;

    debugPrint('Budget deleted. Remaining budgets: ${state.length}');
  }
}
