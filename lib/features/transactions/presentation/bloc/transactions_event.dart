abstract class TransactionEvent {}

class LoadTransactions extends TransactionEvent {
  final Map<String, String> headers;

  LoadTransactions({required this.headers});
}

class FilterTransactions extends TransactionEvent {
  final String filter;

  FilterTransactions(this.filter);
}