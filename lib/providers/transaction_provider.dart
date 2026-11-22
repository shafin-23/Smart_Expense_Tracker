
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/transaction_model.dart';
import '../core/providers/database_provider.dart';
import '../core/database/app_database.dart' as db;

final transactionsProvider =
NotifierProvider<TransactionNotifier, List<TransactionModel>>(
  TransactionNotifier.new,
);

class TransactionNotifier extends Notifier<List<TransactionModel>> {
  @override
  List<TransactionModel> build() {
    final dao = ref.watch(transactionDaoProvider);

    final subscription = dao.watchTransactions().listen(
          (transactions) {
        debugPrint(
          'TRANSACTION STREAM: ${transactions.length} records received',
        );

        state = transactions.map(_toModel).toList();
      },
      onError: (error, stackTrace) {
        debugPrint('TRANSACTION STREAM ERROR: $error');
        debugPrintStack(stackTrace: stackTrace);
      },
    );

    ref.onDispose(() {
      subscription.cancel();
    });

    return [];
  }

  TransactionModel _toModel(db.Transaction transaction) {
    return TransactionModel(
      id: transaction.id.toString(),
      title: transaction.title,
      category: transaction.category,
      amount: transaction.amount,
      date: transaction.date,
      isIncome: transaction.type == 'income',
    );
  }

  Future<void> _refreshTransactions() async {
    final dao = ref.read(transactionDaoProvider);

    final transactions = await dao.getAllTransactions();

    debugPrint(
      'DATABASE REFRESH: ${transactions.length} records found',
    );

    state = transactions.map(_toModel).toList();
  }

  Future<void> addTransaction(
      TransactionModel transaction,
      ) async {
    final dao = ref.read(transactionDaoProvider);

    debugPrint('ADDING TRANSACTION: ${transaction.title}');
    debugPrint('TYPE: ${transaction.isIncome ? 'income' : 'expense'}');

    final id = await dao.addTransaction(
      db.TransactionsCompanion.insert(
        title: transaction.title,
        amount: transaction.amount,
        category: transaction.category,
        type: transaction.isIncome ? 'income' : 'expense',
        date: transaction.date,
      ),
    );

    debugPrint('INSERT SUCCESS. ID: $id');

    await _refreshTransactions();
  }

  Future<void> deleteTransaction(String id) async {
    final transactionId = int.tryParse(id);

    if (transactionId == null) {
      debugPrint('DELETE ERROR: Invalid ID $id');
      return;
    }

    final dao = ref.read(transactionDaoProvider);

    final deletedCount =
    await dao.deleteTransaction(transactionId);

    debugPrint('DELETED RECORDS: $deletedCount');

    await _refreshTransactions();
  }

  Future<void> updateTransaction(
      TransactionModel updated,
      ) async {
    final transactionId = int.tryParse(updated.id);

    if (transactionId == null) {
      debugPrint('UPDATE ERROR: Invalid ID ${updated.id}');
      return;
    }

    final dao = ref.read(transactionDaoProvider);

    final transactions = await dao.getAllTransactions();

    final index = transactions.indexWhere(
          (transaction) => transaction.id == transactionId,
    );

    if (index == -1) {
      debugPrint('UPDATE ERROR: Transaction not found');
      return;
    }

    final existing = transactions[index];

    await dao.updateTransaction(
      existing.copyWith(
        title: updated.title,
        amount: updated.amount,
        category: updated.category,
        type: updated.isIncome ? 'income' : 'expense',
        date: updated.date,
      ),
    );

    debugPrint('UPDATE SUCCESS: ${updated.title}');

    await _refreshTransactions();
  }
}
