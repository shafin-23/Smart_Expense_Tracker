
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'tables/transactions.dart';
import 'tables/budgets.dart';
import 'tables/expenses.dart';

import 'daos/transaction_dao.dart';
import 'daos/budget_dao.dart';
import 'daos/expense_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Transactions,
    Budgets,
    Expenses,
  ],
  daos: [
    TransactionDao,
    BudgetDao,
    ExpenseDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 7;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 2) {
        await m.createTable(budgets);
      }

      if (from < 3) {
        await m.createTable(expenses);
      }

      if (from < 4) {
        await m.addColumn(expenses, expenses.category);
      }

      if (from < 5) {
        await m.addColumn(expenses, expenses.createdAt);
      }

      // Version 6: Migrate old expenses into transactions.
      if (from < 6) {
        await customStatement('''
              INSERT INTO transactions (
                title,
                amount,
                category,
                type,
                date,
                note
              )
              SELECT
                title,
                amount,
                category,
                'expense',
                COALESCE(created_at, CURRENT_TIMESTAMP),
                NULL
              FROM expenses
            ''');
      }

      // Version 7: Convert text dates into Unix timestamps.
      if (from < 7) {
        await customStatement('''
              UPDATE transactions
              SET date = CAST(strftime('%s', date) AS INTEGER)
              WHERE typeof(date) = 'text'
                AND strftime('%s', date) IS NOT NULL
            ''');
      }
    },
  );
}

QueryExecutor _openConnection() {
  return driftDatabase(
    name: 'expense_tracker',
  );
}
