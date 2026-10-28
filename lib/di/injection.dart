
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/network/api_client.dart';

// Login imports
import '../data/data_sources/auth_demo_data_source.dart';
import '../data/data_sources/wallet_remote_datasource.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../domain/usecase/login_usecase.dart';
import '../domain/usecase/send_money_usecase.dart';
import '../features/auth/presentation/bloc/login_bloc.dart';

// Wallet imports — paths apne project ke according check karein

import '../data/repositories/wallet_repository_impl.dart';


// Shared API client
final apiClient = ApiClient(
  baseUrl: 'https://jwallet-api.onrender.com',
);

// Login dependency injection
final remoteDataSource = AuthRemoteDataSourceImpl(apiClient);
final repository = AuthRepositoryImpl(remoteDataSource);
final loginUseCase = LoginUser(repository);
final loginBloc = LoginBloc(loginUseCase);

// Wallet dependency injection
final walletRemoteDataSource = WalletRemoteDataSourceImpl(apiClient);
final walletRepository = WalletRepositoryImpl(walletRemoteDataSource);
final getWalletBalanceUsecase = GetWalletBalance(walletRepository);
