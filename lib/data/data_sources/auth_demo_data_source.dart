
import 'package:flutter/cupertino.dart';

import '../../../../core/network/api_client.dart';
import '../../domain/entities/login_request_params.dart';

import '../models/login_response_model.dar.dart';


abstract class AuthRemoteDataSource {
  Future<LoginResponseModel> login(
      LoginRequestParams params,
      );
}

class AuthRemoteDataSourceImpl
    implements AuthRemoteDataSource {
  final ApiClient _client;

  AuthRemoteDataSourceImpl(this._client);


  @override
  Future<LoginResponseModel> login(
      LoginRequestParams params,
      ) async {
    debugPrint('LoginRemoteDataSource: login() called');

    final response = await _client.post(
      'api/v1/auth/login',
      params: params.toJson(),
    );

    debugPrint('LoginRemoteDataSource: response received');

    return LoginResponseModel.fromJson(
      Map<String, dynamic>.from(response as Map),
    );
  }

}
