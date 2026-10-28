
import 'package:dartz/dartz.dart';

import '../../core/utils/app_error.dart';
import '../../data/models/balance_model.dart';


abstract class WalletRepository {
  Future<Either<AppError, Balancemodel>>
  getWalletBalance(
      Map<String, String> headers,
      );
}
