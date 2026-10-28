
import 'package:dartz/dartz.dart';

import '../../core/utils/app_error.dart';
import '../../data/models/transactions_model.dart';

abstract class TransactionsRepository {
  Future<Either<AppError, Transactionsmodel>> getTransactions(
      Map<String, String> headers,
      );
}
