
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'tables/transactions.dart';
import 'tables/budgets.dart';

import 'daos/transaction_dao.dart';
import 'daos/budget_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [Transactions, Budgets],
  daos: [TransactionDao, BudgetDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 2) {
        await m.createTable(budgets);
      }
    },
  );
}

QueryExecutor _openConnection() {
  return driftDatabase(
    name: 'expense_tracker',
  );
}
