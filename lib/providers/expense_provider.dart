
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/providers/database_provider.dart';
import '../core/database/app_database.dart';

// Listen to all saved expenses
final expensesProvider = StreamProvider<List<Expense>>((ref) {
  final expenseDao = ref.watch(expenseDaoProvider);
  return expenseDao.watchAllExpenses();
});
