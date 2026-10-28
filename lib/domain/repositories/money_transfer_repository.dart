
import 'package:dartz/dartz.dart';


import '../../core/utils/app_error.dart';
import '../../data/models/transactions_model.dart';
import '../../data/models/transfer_model.dart';
import '../entities/money_transfer_request_model.dart';


abstract class MoneyTransferRepository {
  Future<Either<AppError, Transfermodel>> transferMoney({
    required MoneyTransferRequestModel request,
    required Map<String, String> headers,
    required String idempotencyKey,
  });
}
