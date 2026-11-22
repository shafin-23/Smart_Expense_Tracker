import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../models/transaction_model.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/app_preferences_provider.dart';
import '../../widgets/balance_card.dart';
import '../../widgets/spending_chart.dart';
import '../../widgets/transaction_tile.dart';
import '../transactions/add_transaction_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _searchController =
  TextEditingController();

  String _selectedCategory = 'All';

  DateTime _selectedMonth = DateTime(
    DateTime.now().year,
    DateTime.now().month,
  );

  final List<String> _categories = [
    'All',
    'Food',
    'Transport',
    'Shopping',
    'Bills',
    'Education',
    'Health',
    'Entertainment',
    'Salary',
    'Freelancing',
    'Business',
    'Investment',
    'Gift',
    'Other',
  ];

  static const List<String> _monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatMonth(DateTime date) {
    return '${_monthNames[date.month - 1]} ${date.year}';
  }

  List<DateTime> _getAvailableMonths(
      List<TransactionModel> transactions,
      ) {
    final currentMonth = DateTime(
      DateTime.now().year,
      DateTime.now().month,
    );

    if (transactions.isEmpty) {
      return [currentMonth];
    }

    final sortedDates = transactions.map((transaction) {
      return DateTime(
        transaction.date.year,
        transaction.date.month,
      );
    }).toList()
      ..sort((a, b) => a.compareTo(b));

    final firstMonth = sortedDates.first;

    final totalMonths =
        (currentMonth.year - firstMonth.year) * 12 +
            currentMonth.month -
            firstMonth.month +
            1;

    return List.generate(totalMonths, (index) {
      return DateTime(
        firstMonth.year,
        firstMonth.month + index,
      );
    }).reversed.toList();
  }

  void _changeMonth(int difference) {
    final transactions = ref.read(transactionsProvider);
    final availableMonths = _getAvailableMonths(transactions);

    final currentIndex = availableMonths.indexWhere(
          (month) =>
      month.year == _selectedMonth.year &&
          month.month == _selectedMonth.month,
    );

    if (currentIndex == -1) return;

    final newIndex = currentIndex - difference;

    if (newIndex < 0 || newIndex >= availableMonths.length) {
      return;
    }

    setState(() {
      _selectedMonth = availableMonths[newIndex];
      _searchController.clear();
      _selectedCategory = 'All';
    });
  }

  List<TransactionModel> _filterTransactions(
      List<TransactionModel> transactions,
      ) {
    final searchText =
    _searchController.text.trim().toLowerCase();

    return transactions.where((transaction) {
      final matchesSearch =
          transaction.title.toLowerCase().contains(searchText) ||
              transaction.category.toLowerCase().contains(searchText);

      final matchesCategory =
          _selectedCategory == 'All' ||
              transaction.category == _selectedCategory;

      return matchesSearch && matchesCategory;
    }).toList();
  }

  Future<void> _openTransactionScreen({
    TransactionModel? transaction,
  }) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddTransactionScreen(
          transaction: transaction,
        ),
      ),
    );
  }

  Future<void> _deleteTransaction(
      BuildContext context,
      WidgetRef ref,
      String id,
      String title,
      ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Transaction?'),
        content: Text(
          'Are you sure you want to delete "$title"?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext, false);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext, true);
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await ref
          .read(transactionsProvider.notifier)
          .deleteTransaction(id);

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Transaction deleted successfully'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete transaction: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final preferences = ref.watch(appPreferencesProvider);
    final currencySymbol = preferences.currencySymbol;

    final transactions = ref.watch(transactionsProvider);

    // All-time income.
    final allTimeIncome = transactions
        .where((item) => item.isIncome)
        .fold<double>(
      0,
          (sum, item) => sum + item.amount,
    );

    // All-time expense.
    final allTimeExpense = transactions
        .where((item) => !item.isIncome)
        .fold<double>(
      0,
          (sum, item) => sum + item.amount,
    );

    // All-time balance.
    final allTimeBalance = allTimeIncome - allTimeExpense;

    // Transactions of selected month.
    final monthlyTransactions = transactions.where((item) {
      return item.date.year == _selectedMonth.year &&
          item.date.month == _selectedMonth.month;
    }).toList();

    // Selected month income.
    final monthlyIncome = monthlyTransactions
        .where((item) => item.isIncome)
        .fold<double>(
      0,
          (sum, item) => sum + item.amount,
    );

    // Selected month expense.
    final monthlyExpense = monthlyTransactions
        .where((item) => !item.isIncome)
        .fold<double>(
      0,
          (sum, item) => sum + item.amount,
    );

    final monthlyIncomeCount = monthlyTransactions
        .where((item) => item.isIncome)
        .length;

    final monthlyExpenseCount = monthlyTransactions
        .where((item) => !item.isIncome)
        .length;

    // Sort selected month's transactions.
    final recentTransactions = [...monthlyTransactions]
      ..sort((a, b) => b.date.compareTo(a.date));

    final filteredTransactions =
    _filterTransactions(recentTransactions);

    final availableMonths = _getAvailableMonths(transactions);

    // Keep selected month valid if transaction history changes.
    final selectedMonthExists = availableMonths.any(
          (month) =>
      month.year == _selectedMonth.year &&
          month.month == _selectedMonth.month,
    );

    if (!selectedMonthExists && availableMonths.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        setState(() {
          _selectedMonth = availableMonths.first;
        });
      });
    }

    final canGoToNewerMonth =
        availableMonths.isNotEmpty &&
            availableMonths.first.isAfter(_selectedMonth);

    final canGoToOlderMonth =
        availableMonths.isNotEmpty &&
            availableMonths.last.isBefore(_selectedMonth);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dashboard Header.
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Welcome back,',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '${preferences.profileName} 👋',
                        style: const TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const CircleAvatar(
                  radius: 23,
                  backgroundColor: AppColors.surfaceLight,
                  child: Icon(
                    Icons.person_outline,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 25),

            const Text(
              'My Wallet',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 12),

            // All-time balance.
            BalanceCard(
              balance: allTimeBalance,
              income: allTimeIncome,
              expense: allTimeExpense,
            ),

            const SizedBox(height: 28),

            // Monthly selector.
            const Text(
              'Monthly Overview',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 5,
              ),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.textSecondary.withValues(
                    alpha: 0.2,
                  ),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: canGoToOlderMonth
                        ? () => _changeMonth(-1)
                        : null,
                    icon: const Icon(Icons.chevron_left),
                    color: AppColors.primary,
                    tooltip: 'Previous month',
                  ),
                  Expanded(
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<DateTime>(
                        value: availableMonths.any(
                              (month) =>
                          month.year == _selectedMonth.year &&
                              month.month == _selectedMonth.month,
                        )
                            ? _selectedMonth
                            : availableMonths.first,
                        isExpanded: true,
                        alignment: Alignment.center,
                        icon: const Icon(
                          Icons.keyboard_arrow_down,
                          color: AppColors.primary,
                        ),
                        items: availableMonths.map((month) {
                          return DropdownMenuItem<DateTime>(
                            value: month,
                            child: Center(
                              child: Text(
                                _formatMonth(month),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value == null) return;

                          setState(() {
                            _selectedMonth = value;
                            _searchController.clear();
                            _selectedCategory = 'All';
                          });
                        },
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: canGoToNewerMonth
                        ? () => _changeMonth(1)
                        : null,
                    icon: const Icon(Icons.chevron_right),
                    color: AppColors.primary,
                    tooltip: 'Next month',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Monthly Income and Expense.
            Row(
              children: [
                Expanded(
                  child: _SummaryCard(
                    title: 'Monthly Income',
                    amount: monthlyIncome,
                    currencySymbol: currencySymbol,
                    icon: Icons.trending_up,
                    color: AppColors.income,
                    count: monthlyIncomeCount,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SummaryCard(
                    title: 'Monthly Expense',
                    amount: monthlyExpense,
                    currencySymbol: currencySymbol,
                    icon: Icons.trending_down,
                    color: AppColors.expense,
                    count: monthlyExpenseCount,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // Monthly Transactions.
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Monthly Transactions',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${monthlyTransactions.length} records',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            // Search.
            TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {});
              },
              decoration: InputDecoration(
                hintText: 'Search transactions...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  onPressed: () {
                    _searchController.clear();
                    setState(() {});
                  },
                  icon: const Icon(Icons.close),
                )
                    : null,
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: AppColors.textSecondary.withValues(
                      alpha: 0.2,
                    ),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 1.5,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Category Filter.
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
              ),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.textSecondary.withValues(
                    alpha: 0.2,
                  ),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.filter_list,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Category:',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedCategory,
                        isExpanded: true,
                        items: _categories.map((category) {
                          return DropdownMenuItem<String>(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedCategory = value;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),

            // Transaction List.
            if (monthlyTransactions.isEmpty)
              _NoMonthlyTransactions(
                month: _formatMonth(_selectedMonth),
              )
            else if (filteredTransactions.isEmpty)
              const _NoSearchResults()
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${filteredTransactions.length} transactions found',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ListView.separated(
                    shrinkWrap: true,
                    physics:
                    const NeverScrollableScrollPhysics(),
                    itemCount: filteredTransactions.length,
                    separatorBuilder: (_, _) =>
                    const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = filteredTransactions[index];

                      return _TransactionItem(
                        title: item.title,
                        amount: item.amount,
                        category: item.category,
                        isIncome: item.isIncome,
                        currencySymbol: currencySymbol,
                        onEdit: () {
                          _openTransactionScreen(
                            transaction: item,
                          );
                        },
                        onDelete: () {
                          _deleteTransaction(
                            context,
                            ref,
                            item.id,
                            item.title,
                          );
                        },
                      );
                    },
                  ),
                ],
              ),

            const SizedBox(height: 28),

            // Monthly Spending Chart.
            const Text(
              'Monthly Spending Activity',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 5),

            Text(
              _formatMonth(_selectedMonth),
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),

            const SizedBox(height: 14),

            SpendingChart(
              selectedMonth: _selectedMonth,
            ),

            const SizedBox(height: 28),

            // Recent Transactions.
            const Text(
              'Recent Transactions',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            if (recentTransactions.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(25),
                  child: Text(
                    'No transactions this month',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              )
            else
              ...recentTransactions.take(3).map(
                    (transaction) => TransactionTile(
                  transaction: transaction,
                ),
              ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// Summary Card.
class _SummaryCard extends StatelessWidget {
  final String title;
  final double amount;
  final String currencySymbol;
  final IconData icon;
  final Color color;
  final int count;

  const _SummaryCard({
    required this.title,
    required this.amount,
    required this.currencySymbol,
    required this.icon,
    required this.color,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.textSecondary.withValues(
            alpha: 0.15,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '$currencySymbol ${amount.toStringAsFixed(2)}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            '$count records',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

// Individual Transaction Item.
class _TransactionItem extends StatelessWidget {
  final String title;
  final double amount;
  final String category;
  final bool isIncome;
  final String currencySymbol;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _TransactionItem({
    required this.title,
    required this.amount,
    required this.category,
    required this.isIncome,
    required this.currencySymbol,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final color = isIncome
        ? AppColors.income
        : AppColors.expense;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.textSecondary.withValues(
            alpha: 0.12,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isIncome
                  ? Icons.arrow_downward
                  : Icons.arrow_upward,
              color: color,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  category,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 5),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isIncome ? '+' : '-'}$currencySymbol ${amount.toStringAsFixed(2)}',
                style: TextStyle(
                  color: color,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: onEdit,
                    tooltip: 'Edit transaction',
                    visualDensity: VisualDensity.compact,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                    padding: EdgeInsets.zero,
                    icon: const Icon(
                      Icons.edit_outlined,
                      color: AppColors.primary,
                      size: 19,
                    ),
                  ),
                  IconButton(
                    onPressed: onDelete,
                    tooltip: 'Delete transaction',
                    visualDensity: VisualDensity.compact,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                    padding: EdgeInsets.zero,
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Colors.redAccent,
                      size: 19,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// No Monthly Transactions.
class _NoMonthlyTransactions extends StatelessWidget {
  final String month;

  const _NoMonthlyTransactions({
    required this.month,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 35),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.receipt_long_outlined,
            size: 45,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 12),
          const Text(
            'No transactions this month',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'No records found for $month.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

// No Search Results.
class _NoSearchResults extends StatelessWidget {
  const _NoSearchResults();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 30),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.search_off,
            size: 40,
            color: AppColors.textSecondary,
          ),
          SizedBox(height: 10),
          Text(
            'No matching transactions found',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 5),
          Text(
            'Try another search or category.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}