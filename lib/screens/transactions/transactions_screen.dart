
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../providers/transaction_provider.dart';
import '../../widgets/transaction_tile.dart';

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() =>
      _TransactionsScreenState();
}

class _TransactionsScreenState
    extends ConsumerState<TransactionsScreen> {
  String searchQuery = '';
  String selectedFilter = 'All';

  Future<void> _deleteTransaction(String id) async {
    try {
      await ref
          .read(transactionsProvider.notifier)
          .deleteTransaction(id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Transaction deleted'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete transaction: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context){
    final transactions = ref.watch(transactionsProvider);

    final filteredTransactions = transactions.where((item) {
      final query = searchQuery.toLowerCase();

      final matchesSearch =
          item.title.toLowerCase().contains(query) ||
              item.category.toLowerCase().contains(query);

      final matchesFilter =
          selectedFilter == 'All' ||
              (selectedFilter == 'Income' && item.isIncome) ||
              (selectedFilter == 'Expense' && !item.isIncome);

      return matchesSearch && matchesFilter;
    }).toList();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Transactions',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              onChanged: (value) {
                setState(() => searchQuery = value);
              },
              decoration: const InputDecoration(
                hintText: 'Search transactions...',
                prefixIcon: Icon(Icons.search),
              ),
            ),

            const SizedBox(height: 18),

            Wrap(
              spacing: 10,
              children: ['All', 'Income', 'Expense'].map((filter) {
                return ChoiceChip(
                  label: Text(filter),
                  selected: selectedFilter == filter,
                  onSelected: (_) {
                    setState(() => selectedFilter = filter);
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            Text(
              '${filteredTransactions.length} transactions found',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),

            const SizedBox(height: 12),

            Expanded(
              child: filteredTransactions.isEmpty
                  ? const Center(
                child: Text(
                  'No transactions found',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                  ),
                ),
              )
                  : ListView.builder(
                itemCount: filteredTransactions.length,
                itemBuilder: (context, index) {
                  final transaction =
                  filteredTransactions[index];

                  return TransactionTile(
                    transaction: transaction,
                    onDelete: () =>
                        _deleteTransaction(transaction.id),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
