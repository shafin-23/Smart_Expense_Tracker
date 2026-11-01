import 'dart:async';

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

    // Database থেকে real-time transaction update
    final subscription = dao.watchTransactions().listen((transactions) {
      state = transactions.map(_toModel).toList();
    });

    ref.onDispose(() {
      subscription.cancel();
    });

    // Database empty হলে demo data insert করবে
    unawaited(_seedIfEmpty(dao));

    return [];
  }

  // Drift Transaction কে TransactionModel-এ convert
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

  // Database empty হলে sample data
  Future<void> _seedIfEmpty(dynamic dao) async {
    final existingTransactions = await dao.getAllTransactions();

    if (existingTransactions.isNotEmpty) return;

    final now = DateTime.now();

    final sampleTransactions = [
      TransactionModel(
        id: '1',
        title: 'Salary',
        category: 'Income',
        amount: 35000,
        date: now,
        isIncome: true,
      ),
      TransactionModel(
        id: '2',
        title: 'Grocery Shopping',
        category: 'Shopping',
        amount: 2500,
        date: now,
        isIncome: false,
      ),
      TransactionModel(
        id: '3',
        title: 'Netflix Subscription',
        category: 'Entertainment',
        amount: 650,
        date: now,
        isIncome: false,
      ),
      TransactionModel(
        id: '4',
        title: 'Freelance Project',
        category: 'Income',
        amount: 5000,
        date: now,
        isIncome: true,
      ),
      TransactionModel(
        id: '5',
        title: 'Restaurant',
        category: 'Food',
        amount: 1200,
        date: now,
        isIncome: false,
      ),
    ];

    for (final transaction in sampleTransactions) {
      await addTransaction(transaction);
    }
  }

  // Add transaction
  Future<void> addTransaction(TransactionModel transaction) async {
    final dao = ref.read(transactionDaoProvider);

    await dao.addTransaction(
      db.TransactionsCompanion.insert(
        title: transaction.title,
        amount: transaction.amount,
        category: transaction.category,
        type: transaction.isIncome ? 'income' : 'expense',
        date: transaction.date,
      ),
    );
  }

  // Delete transaction
  Future<void> deleteTransaction(String id) async {
    final transactionId = int.tryParse(id);

    if (transactionId == null) return;

    final dao = ref.read(transactionDaoProvider);

    await dao.deleteTransaction(transactionId);
  }

  // Update transaction
  Future<void> updateTransaction(TransactionModel updated) async {
    final transactionId = int.tryParse(updated.id);

    if (transactionId == null) return;

    final dao = ref.read(transactionDaoProvider);
    final transactions = await dao.getAllTransactions();

    final existing = transactions.firstWhere(
          (transaction) => transaction.id == transactionId,
    );

    await dao.updateTransaction(
      existing.copyWith(
        title: updated.title,
        amount: updated.amount,
        category: updated.category,
        type: updated.isIncome ? 'income' : 'expense',
        date: updated.date,
      ),
    );
  }
}