
import '../../../../data/models/transfer_model.dart';

abstract class TransferState {}

class TransferInitial extends TransferState {}

class TransferLoading extends TransferState {}

class TransferSuccess extends TransferState {
  final Transfermodel response;

  TransferSuccess(this.response);
}

class TransferFailure extends TransferState {
  final String message;

  TransferFailure(this.message);
}
