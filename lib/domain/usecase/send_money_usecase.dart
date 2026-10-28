
import 'package:dartz/dartz.dart';

import '../../core/utils/app_error.dart';

import '../../data/models/balance_model.dart';
import '../repositories/wallet_repository.dart';

class GetWalletBalance {
  final WalletRepository _repository;

  GetWalletBalance(this._repository);

  Future<Either<AppError, Balancemodel>> call(
      Map<String, String> headers,
      ) async {
    return _repository.getWalletBalance(headers);
  }
}
