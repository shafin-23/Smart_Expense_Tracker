
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/app_database.dart';

// Main Database Provider
final databaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();

  ref.onDispose(() {
    database.close();
  });

  return database;
});

// Transaction DAO Provider
final transactionDaoProvider = Provider((ref) {
  return ref.watch(databaseProvider).transactionDao;
});

// Budget DAO Provider
final budgetDaoProvider = Provider((ref) {
  return ref.watch(databaseProvider).budgetDao;
});

// Expense DAO Provider (New Assignment Feature)
final expenseDaoProvider = Provider((ref) {
  return ref.watch(databaseProvider).expenseDao;
});
