
import '../../../../data/models/transactions_model.dart';

abstract class TransactionState {}

class TransactionInitial extends TransactionState {}

class TransactionLoading extends TransactionState {}

class TransactionLoaded extends TransactionState {
  final List<Datum> transactions;
  final String selectedFilter;

  TransactionLoaded({
    required this.transactions,
    this.selectedFilter = 'All',
  });

  List<Datum> get filteredTransactions {
    switch (selectedFilter) {
      case 'Credit':
        return transactions
            .where((t) => t.type.toUpperCase() == 'CREDIT')
            .toList();

      case 'Debit':
        return transactions
            .where((t) => t.type.toUpperCase() == 'DEBIT')
            .toList();

      case 'Pending':
        return transactions
            .where((t) => t.status.toUpperCase() == 'PENDING')
            .toList();

      default:
        return transactions;
    }
  }

  TransactionLoaded copyWith({
    List<Datum>? transactions,
    String? selectedFilter,
  }) {
    return TransactionLoaded(
      transactions: transactions ?? this.transactions,
      selectedFilter: selectedFilter ?? this.selectedFilter,
    );
  }
}

class TransactionFailure extends TransactionState {
  final String message;

  TransactionFailure(this.message);
}
