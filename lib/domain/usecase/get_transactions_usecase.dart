
import 'package:dartz/dartz.dart';

import '../../core/utils/app_error.dart';
import '../../data/models/transactions_model.dart';
import '../repositories/transactions_repository.dart';

class GetTransactionsUsecase {
  final TransactionsRepository _repository;

  GetTransactionsUsecase(this._repository);

  Future<Either<AppError, Transactionsmodel>> call(
      Map<String, String> headers,
      ) async {
    return _repository.getTransactions(headers);
  }
}
