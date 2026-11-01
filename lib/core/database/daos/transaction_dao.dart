
import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/transactions.dart';

part 'transaction_dao.g.dart';

@DriftAccessor(tables: [Transactions])
class TransactionDao extends DatabaseAccessor<AppDatabase>
    with _$TransactionDaoMixin {
  TransactionDao(super.db);

  // Add transaction
  Future<int> addTransaction(TransactionsCompanion entry) {
    return into(transactions).insert(entry);
  }

  // Get all transactions
  Future<List<Transaction>> getAllTransactions() {
    return (select(transactions)
      ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .get();
  }

  // Watch transactions in real time
  Stream<List<Transaction>> watchTransactions() {
    return (select(transactions)
      ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .watch();
  }

  // Update transaction
  Future<bool> updateTransaction(Transaction entry) {
    return update(transactions).replace(entry);
  }

  // Delete transaction
  Future<int> deleteTransaction(int id) {
    return (delete(transactions)..where((t) => t.id.equals(id))).go();
  }
}
