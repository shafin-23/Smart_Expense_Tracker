
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'tables/transactions.dart';
import 'daos/transaction_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [Transactions],
  daos: [TransactionDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

QueryExecutor _openConnection() {
  return driftDatabase(
    name: 'expense_tracker',
  );
}
