import 'package:flutter/widgets.dart';
import 'package:dartz/dartz.dart';

import '../../core/utils/app_error.dart';
import '../../core/utils/usecase.dart';
import '../../data/models/login_response_model.dar.dart';
import '../entities/login_request_params.dart';
import '../repositories/auth_repository.dart';

class LoginUser extends UseCaseForParamsAndHeader<LoginResponseModel, LoginRequestParams, Map<String, String>?> {
  final AuthRepository _repository;
  final BuildContext? context;

  LoginUser(
    this._repository, {
    this.context,
  });

  @override
  Future<Either<AppError, LoginResponseModel>> call(
    LoginRequestParams params,
    Map<String, String>? header,
  ) async {
    return _repository.login(
      params,
      header ?? <String, String>{},
      context,
    );
  }
}
