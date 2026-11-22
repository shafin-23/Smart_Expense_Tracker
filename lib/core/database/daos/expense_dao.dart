
import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/expenses.dart';

part 'expense_dao.g.dart';

@DriftAccessor(tables: [Expenses])
class ExpenseDao extends DatabaseAccessor<AppDatabase>
    with _$ExpenseDaoMixin {
  ExpenseDao(super.db);

  // Get all expenses
  Stream<List<Expense>> watchAllExpenses() {
    return (select(db.expenses)
      ..orderBy([
            (t) => OrderingTerm.desc(t.id),
      ]))
        .watch();
  }

  // Insert expense with current date and time
  Future<int> insertExpense({
    required String title,
    required double amount,
    required String category,
  }) {
    return into(db.expenses).insert(
      ExpensesCompanion.insert(
        title: title,
        amount: amount,
        category: Value(category),
        createdAt: Value(DateTime.now()),
      ),
    );
  }

  // Update expense
  Future<int> updateExpense({
    required int id,
    required String title,
    required double amount,
    required String category,
  }) {
    return (update(db.expenses)..where((t) => t.id.equals(id))).write(
      ExpensesCompanion(
        title: Value(title),
        amount: Value(amount),
        category: Value(category),
      ),
    );
  }

  // Delete expense
  Future<int> deleteExpense(int id) {
    return (delete(db.expenses)..where((t) => t.id.equals(id))).go();
  }

  // Calculate total expenses
  Future<double> getTotalExpenses() async {
    final result = await customSelect(
      'SELECT SUM(amount) AS total FROM expenses',
      readsFrom: {db.expenses},
    ).getSingle();

    return result.read<double?>('total') ?? 0.0;
  }

  // Get monthly expenses by category
  Future<double> getMonthlyCategoryExpenses({
    required String category,
    required int month,
    required int year,
  }) async {
    final result = await customSelect(
      '''
      SELECT SUM(amount) AS total
      FROM expenses
      WHERE category = ?
        AND created_at IS NOT NULL
        AND CAST(strftime('%m', created_at) AS INTEGER) = ?
        AND CAST(strftime('%Y', created_at) AS INTEGER) = ?
      ''',
      variables: [
        Variable.withString(category),
        Variable.withInt(month),
        Variable.withInt(year),
      ],
      readsFrom: {db.expenses},
    ).getSingle();

    return result.read<double?>('total') ?? 0.0;
  }
}
