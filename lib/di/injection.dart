
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/network/api_client.dart';

// Login imports
import '../data/data_sources/auth_demo_data_source.dart';
import '../data/data_sources/money_transfer_remote_data_source.dart';
import '../data/data_sources/transactions_remote_datasource.dart';
import '../data/data_sources/wallet_remote_datasource.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../data/repositories/money_transfer_repository_impl.dart';
import '../data/repositories/transactions_repository_impl.dart';
import '../data/repositories/wallet_repository_Impl.dart';
import '../domain/usecase/get_transactions_usecase.dart';
import '../domain/usecase/login_usecase.dart';
import '../domain/usecase/money_transfer_usecase.dart';
import '../domain/usecase/send_money_usecase.dart';
import '../features/auth/presentation/bloc/login_bloc.dart';

// Wallet imports — paths apne project ke according check karein



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

// Transfer dependency injection
final moneyTransferRemoteDataSource = MoneyTransferRemoteDataSourceImpl(apiClient);
final moneyTransferRepository = MoneyTransferRepositoryImpl(moneyTransferRemoteDataSource);
final moneyTransferUseCase = MoneyTransferUseCase(moneyTransferRepository);

// Transcation dependency injection
final transactionsRemoteDataSource = TransactionsRemoteDataSourceImpl(apiClient);
final transactionsRepository = TransactionsRepositoryImpl(transactionsRemoteDataSource);
final transactionsUsecase = GetTransactionsUsecase(transactionsRepository);