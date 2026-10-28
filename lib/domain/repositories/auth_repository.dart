
import 'package:dartz/dartz.dart';
import 'package:flutter/widgets.dart';


import '../../core/utils/app_error.dart';
import '../../data/models/login_response_model.dar.dart';
import '../entities/login_request_params.dart';

abstract class AuthRepository {
  Future<Either<AppError, LoginResponseModel>> login(
      LoginRequestParams params,
      Map<String, String> headers,
      BuildContext? context,
      );
}
