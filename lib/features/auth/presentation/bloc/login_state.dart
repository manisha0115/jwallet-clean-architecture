import 'package:flutter/foundation.dart';
import '../../../../data/models/login_response_model.dar.dart';


@immutable
abstract class LoginState {}

class LoginInitial extends LoginState {}

class LoginLoading extends LoginState {}

class LoginSuccess extends LoginState {
  final LoginResponseModel response;

  LoginSuccess(this.response);
}

class LoginFailure extends LoginState {
  final String message;

  LoginFailure(this.message);
}