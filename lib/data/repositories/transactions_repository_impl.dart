
import 'dart:io';

import 'package:dartz/dartz.dart';

import '../../core/utils/app_error.dart';
import '../../domain/repositories/transactions_repository.dart';

import '../data_sources/transactions_remote_datasource.dart';
import '../models/transactions_model.dart';

class TransactionsRepositoryImpl
    implements TransactionsRepository {
  final TransactionsRemoteDataSource _remoteDataSource;

  TransactionsRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<AppError, Transactionsmodel>> getTransactions(
      Map<String, String> headers,
      ) async {
    try {
      final result =
      await _remoteDataSource.getTransactions(headers);

      if (!result.success) {
        return Left(
          AppError(
            AppErrorType.api,
            message: 'Failed to fetch transactions',
          ),
        );
      }

      return Right(result);
    } on SocketException {
      return Left(AppError(AppErrorType.network));
    } on HttpException {
      return Left(AppError(AppErrorType.network));
    } on FormatException {
      return Left(
        AppError(
          AppErrorType.api,
          message: 'Invalid server response',
        ),
      );
    } on Exception catch (e) {
      return Left(
        AppError(
          AppErrorType.api,
          message: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }
}
