
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../domain/usecase/money_transfer_usecase.dart';
import 'transfer_event.dart';
import 'transfer_state.dart';

class TransferBloc extends Bloc<TransferEvent, TransferState> {
  final MoneyTransferUseCase transferUsecase;

  TransferBloc(this.transferUsecase) : super(TransferInitial()) {
    on<SubmitTransfer>(_onSubmitTransfer);
  }

  Future<void> _onSubmitTransfer(
      SubmitTransfer event,
      Emitter<TransferState> emit,
      ) async {
    emit(TransferLoading());

    try {
      final result = await transferUsecase(
        request: event.request,
        headers: event.headers,
        idempotencyKey: event.idempotencyKey,
      );

      result.fold(
            (error) {
          emit(
            TransferFailure(error.toString()),
          );
        },
            (response) {
          if (response.success) {
            emit(TransferSuccess(response));
          } else {
            emit(
              TransferFailure('Money transfer failed.'),
            );
          }
        },
      );
    } catch (e) {
      emit(
        TransferFailure(
          e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }
}
