
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/models/transactions_model.dart';
import '../bloc/transactions_bloc.dart';
import '../bloc/transactions_event.dart';
import '../bloc/transactions_state.dart';

class TransactionHistoryScreen extends StatefulWidget {
  final String accessToken;

  const TransactionHistoryScreen({
    super.key,
    required this.accessToken,
  });
  @override
  State<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {

  late final isDark =
      Theme.of(context).brightness == Brightness.dark;
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Transaction History',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        elevation: 0,
      ),
      body: BlocBuilder<TransactionBloc, TransactionState>(
        builder: (context, state) {
          // Loading
          if (state is TransactionInitial ||
              state is TransactionLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // API error
          if (state is TransactionFailure) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.redAccent,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        _reload(context);
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          // Unexpected state
          if (state is! TransactionLoaded) {
            return const Center(
              child: Text('Unable to load transactions'),
            );
          }

          final transactions = state.filteredTransactions;

          // No data after filtering
          if (transactions.isEmpty) {
            return RefreshIndicator(
              onRefresh: () async {
                _reload(context);
                await context.read<TransactionBloc>().stream.firstWhere(
                      (state) =>
                  state is TransactionLoaded ||
                      state is TransactionFailure,
                );
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 140),
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 56,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Center(
                    child: Text(
                      'No transaction history found',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          // Data found
          return RefreshIndicator(
            onRefresh: () async {
              _reload(context);
              await context.read<TransactionBloc>().stream.firstWhere(
                    (state) =>
                state is TransactionLoaded ||
                    state is TransactionFailure,
              );
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                _summaryCard(state.transactions),
                const SizedBox(height: 24),
                Text(
                  'Recent Transactions',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 14),
                _filterBar(context, state.selectedFilter),
                const SizedBox(height: 16),
                ...transactions.map(
                      (transaction) => _transactionCard(context, transaction),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _reload(BuildContext context) {
    context.read<TransactionBloc>().add(
      LoadTransactions(
        headers: {
          'Authorization': 'Bearer ${widget.accessToken}',
          'Accept': 'application/json',
        },
      ),
    );
  }

  Widget _summaryCard(List<Datum> transactions) {
    final credits = transactions
        .where((t) => t.type.toUpperCase() == 'CREDIT')
        .fold<double>(0, (sum, t) => sum + t.amount);

    final debits = transactions
        .where((t) => t.type.toUpperCase() == 'DEBIT')
        .fold<double>(0, (sum, t) => sum + t.amount);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF243B80),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'TRANSACTION OVERVIEW',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${transactions.length} transactions',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 23,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: _summaryItem(
                  'Total Credit',
                  credits,
                  Colors.greenAccent,
                ),
              ),
              Expanded(
                child: _summaryItem(
                  'Total Debit',
                  debits,
                  Colors.orangeAccent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryItem(String title, double amount, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.white70)),
        const SizedBox(height: 6),
        Text(
          '₹${amount.toStringAsFixed(2)}',
          style: TextStyle(
            color: color,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _filterBar(BuildContext context, String selected) {
    const filters = ['All', 'Credit', 'Debit', 'Pending'];
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((filter) {
          final active = selected == filter;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(filter),
              selected: active,
              onSelected: (_) {
                context
                    .read<TransactionBloc>()
                    .add(FilterTransactions(filter));
              },
              selectedColor: colors.primary,
              backgroundColor: isDark
                  ? colors.surface
                  : Colors.white,
              checkmarkColor: Colors.white,
              showCheckmark: true,
              labelStyle: TextStyle(
                color: active
                    ? Colors.white
                    : (isDark ? Colors.white : Colors.black),
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _transactionCard(
      BuildContext context,
      Datum transaction,
      ) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final isCredit = transaction.type.toUpperCase() == 'CREDIT';
    final isPending =
        transaction.status.toUpperCase() == 'PENDING';

    final amountColor = isCredit
        ? Colors.green
        : Colors.redAccent;

    final statusColor = isPending
        ? Colors.orange
        : Colors.green;

    final beneficiaryName =
    transaction.beneficiaryName.trim().isNotEmpty
        ? transaction.beneficiaryName
        : 'Unknown beneficiary';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color ?? colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors.outlineVariant,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Transaction type icon
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: isCredit
                  ? Colors.green.withValues(alpha: 0.12)
                  : Colors.redAccent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              isCredit
                  ? Icons.arrow_downward_rounded
                  : Icons.arrow_upward_rounded,
              color: amountColor,
              size: 24,
            ),
          ),

          const SizedBox(width: 12),

          // Transaction information
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  beneficiaryName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.onSurface,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  '${transaction.type} • ${_formatDate(transaction.createdAt)}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontSize: 11,
                  ),
                ),

                const SizedBox(height: 7),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    transaction.status,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Transaction amount
          Flexible(
            child: Text(
              '${isCredit ? '+' : '-'}₹${transaction.amount.toStringAsFixed(2)}',
              textAlign: TextAlign.end,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: amountColor,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Date unavailable';

    final local = date.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final minute = local.minute.toString().padLeft(2, '0');
    final period = local.hour >= 12 ? 'PM' : 'AM';

    return '$day/$month/${local.year} • $hour:$minute $period';
  }
}
