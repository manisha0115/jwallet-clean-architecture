import 'package:flutter/foundation.dart';
import '../../../../domain/entities/login_request_params.dart';

@immutable
abstract class LoginEvent {}

class LoginSubmitted extends LoginEvent {
  final LoginRequestParams params;

  LoginSubmitted(this.params);
}