
import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/budgets.dart';

part 'budget_dao.g.dart';

@DriftAccessor(tables: [Budgets])
class BudgetDao extends DatabaseAccessor<AppDatabase>
    with _$BudgetDaoMixin {
  BudgetDao(super.db);

  // Add or update a category budget
  Future<void> addBudget(BudgetsCompanion entry) async {
    await into(budgets).insert(
      entry,
      mode: InsertMode.insertOrReplace,
    );
  }

  // Get all budgets
  Future<List<Budget>> getAllBudgets() {
    return select(budgets).get();
  }

  // Watch budgets in real time
  Stream<List<Budget>> watchBudgets() {
    return select(budgets).watch();
  }

  // Get budgets for a specific month
  Future<List<Budget>> getMonthlyBudgets(
      int month,
      int year,
      ) {
    return (select(budgets)
      ..where((b) =>
      b.month.equals(month) &
      b.year.equals(year)))
        .get();
  }

  // Delete budget
  Future<int> deleteBudget(int id) {
    return (delete(budgets)
      ..where((b) => b.id.equals(id)))
        .go();
  }
}
