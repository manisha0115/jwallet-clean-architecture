
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter/widgets.dart';


import '../../core/utils/app_error.dart';
import '../../domain/entities/login_request_params.dart';
import '../../domain/repositories/auth_repository.dart';
import '../data_sources/auth_demo_data_source.dart';
import '../models/login_response_model.dar.dart';


class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<AppError, LoginResponseModel>> login(
      LoginRequestParams params,
      Map<String, String> headers,
      BuildContext? context,
      ) async {
    try {
      final result = await _remoteDataSource.login(params);

      if (!result.success) {
        return Left(
          AppError(
            AppErrorType.api,
            message: 'Login failed',
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
