
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/providers/database_provider.dart';
import '../core/database/app_database.dart' as db;

final budgetsProvider =
NotifierProvider<BudgetNotifier, List<db.Budget>>(
  BudgetNotifier.new,
);

class BudgetNotifier extends Notifier<List<db.Budget>> {
  StreamSubscription<List<db.Budget>>? _subscription;

  @override
  List<db.Budget> build() {
    final dao = ref.watch(budgetDaoProvider);

    _subscription = dao.watchBudgets().listen((budgets) {
      state = budgets;
    });

    ref.onDispose(() {
      _subscription?.cancel();
    });

    return [];
  }

  // Add or update budget
  Future<void> addBudget({
    required String category,
    required double amount,
    required int month,
    required int year,
  }) async {
    if (amount <= 0) {
      throw ArgumentError('Budget amount must be greater than zero');
    }

    final dao = ref.read(budgetDaoProvider);

    await dao.addBudget(
      db.BudgetsCompanion.insert(
        category: category,
        amount: amount,
        month: month,
        year: year,
      ),
    );
  }

  // Get monthly budgets
  Future<List<db.Budget>> getMonthlyBudgets(
      int month,
      int year,
      ) async {
    final dao = ref.read(budgetDaoProvider);

    return dao.getMonthlyBudgets(month, year);
  }

  // Delete budget
  Future<void> deleteBudget(int id) async {
    final dao = ref.read(budgetDaoProvider);

    await dao.deleteBudget(id);
  }
}
