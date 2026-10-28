
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/network/api_client.dart';
import '../data/data_sources/auth_demo_data_source.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../domain/usecase/login_usecase.dart';
import '../features/auth/presentation/bloc/login_bloc.dart';


// Use your deployed backend's HTTPS base URL.
final apiClient = ApiClient(
  baseUrl: 'https://your-backend-domain.com/',
);

final remoteDataSource = AuthRemoteDataSourceImpl(
  apiClient,
);

final repository = AuthRepositoryImpl(
  remoteDataSource,
);

final loginUseCase = LoginUser(repository);

final loginBloc = LoginBloc(loginUseCase);
