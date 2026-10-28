
import 'dart:io';

import 'package:dartz/dartz.dart';


import '../../core/utils/app_error.dart';
import '../../domain/entities/money_transfer_request_model.dart';
import '../../domain/repositories/money_transfer_repository.dart';
import '../data_sources/money_transfer_remote_data_source.dart';
import '../models/transfer_model.dart';


class MoneyTransferRepositoryImpl
    implements MoneyTransferRepository {
  final MoneyTransferRemoteDataSource _remoteDataSource;

  MoneyTransferRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<AppError, Transfermodel>> transferMoney({
    required MoneyTransferRequestModel request,
    required Map<String, String> headers,
    required String idempotencyKey,
  }) async {
    try {
      final result = await _remoteDataSource.transferMoney(
        request: request,
        headers: headers,
        idempotencyKey: idempotencyKey,
      );

      return Right(result);

    } on SocketException catch (e) {
      return Left(
        AppError(
          AppErrorType.network,
          message: 'Network error: ${e.message}',
        ),
      );
    } on HttpException catch (e) {
      return Left(
        AppError(
          AppErrorType.api,
          message: e.message,
        ),
      );
    } on FormatException {
      return Left(
        AppError(
          AppErrorType.api,
          message: 'Invalid server response',
        ),
      );
    } catch (e) {
      return Left(
        AppError(
          AppErrorType.api,
          message: e.toString(),
        ),
      );
    }

  }
}
