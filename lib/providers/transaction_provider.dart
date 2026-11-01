
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/transaction_model.dart';

final transactionsProvider =
NotifierProvider<TransactionNotifier, List<TransactionModel>>(
  TransactionNotifier.new,
);

class TransactionNotifier extends Notifier<List<TransactionModel>> {
  @override
  List<TransactionModel> build() {
    final now = DateTime.now();

    return [
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
  }

  void addTransaction(TransactionModel transaction) {
    state = [transaction, ...state];
  }

  void deleteTransaction(String id) {
    state = state.where((item) => item.id != id).toList();
  }

  void updateTransaction(TransactionModel updated) {
    state = [
      for (final item in state)
        if (item.id == updated.id) updated else item,
    ];
  }
}
