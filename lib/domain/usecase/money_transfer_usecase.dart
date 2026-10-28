
import 'package:dartz/dartz.dart';


import '../../core/utils/app_error.dart';
import '../../data/models/transfer_model.dart';
import '../entities/money_transfer_request_model.dart';
import '../repositories/money_transfer_repository.dart';

class MoneyTransferUseCase {
  final MoneyTransferRepository _repository;

  MoneyTransferUseCase(this._repository);

  Future<Either<AppError, Transfermodel>> call({
    required MoneyTransferRequestModel request,
    required Map<String, String> headers,
    required String idempotencyKey,
  }) {
    return _repository.transferMoney(
      request: request,
      headers: headers,
      idempotencyKey: idempotencyKey,
    );
  }
}
