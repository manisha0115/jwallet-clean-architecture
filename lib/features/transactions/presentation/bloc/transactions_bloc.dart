
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../domain/usecase/get_transactions_usecase.dart';
import 'transactions_event.dart';
import 'transactions_state.dart';

class TransactionBloc
    extends Bloc<TransactionEvent, TransactionState> {
  final GetTransactionsUsecase getTransactionsUseCase;

  TransactionBloc(this.getTransactionsUseCase)
      : super(TransactionInitial()) {
    on<LoadTransactions>(_onLoadTransactions);
    on<FilterTransactions>(_onFilterTransactions);
  }

  Future<void> _onLoadTransactions(
      LoadTransactions event,
      Emitter<TransactionState> emit,
      ) async {
    emit(TransactionLoading());

    final result = await getTransactionsUseCase(event.headers);

    result.fold(
          (error) {
        emit(TransactionFailure(error.toString()));
      },
          (response) {
        emit(
          TransactionLoaded(
            transactions: response.data,
          ),
        );
      },
    );
  }

  void _onFilterTransactions(
      FilterTransactions event,
      Emitter<TransactionState> emit,
      ) {
    final currentState = state;

    if (currentState is TransactionLoaded) {
      emit(
        currentState.copyWith(
          selectedFilter: event.filter,
        ),
      );
    }
  }
}
