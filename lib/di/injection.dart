
import '../core/network/api_client.dart';

// Data sources
import '../core/storage/secure_storage_service.dart';
import '../data/data_sources/auth_demo_data_source.dart';
import '../data/data_sources/wallet_remote_datasource.dart';
import '../data/data_sources/money_transfer_remote_data_source.dart';
import '../data/data_sources/transactions_remote_datasource.dart';

// Repositories
import '../data/repositories/auth_repository_impl.dart';
import '../data/repositories/wallet_repository_impl.dart';
import '../data/repositories/money_transfer_repository_impl.dart';
import '../data/repositories/transactions_repository_impl.dart';

// Use cases
import '../domain/usecase/login_usecase.dart';

import '../domain/usecase/money_transfer_usecase.dart';
import '../domain/usecase/get_transactions_usecase.dart';

// BLoC
import '../domain/usecase/send_money_usecase.dart';
import '../features/auth/presentation/bloc/login_bloc.dart';

// Shared API client
final apiClient = ApiClient(
  baseUrl: 'https://jwallet-api.onrender.com',
);

// Login dependencies
final authRemoteDataSource = AuthRemoteDataSourceImpl(apiClient);
final authRepository = AuthRepositoryImpl(authRemoteDataSource);
final loginUseCase = LoginUser(authRepository);
final secureStorage = SecureStorageService();

final loginBloc = LoginBloc(
  loginUseCase,
  secureStorage,
);

// Wallet dependencies
final walletRemoteDataSource = WalletRemoteDataSourceImpl(apiClient);
final walletRepository = WalletRepositoryImpl(walletRemoteDataSource);
final getWalletBalanceUsecase =
GetWalletBalance(walletRepository);

// Money transfer dependencies
final moneyTransferRemoteDataSource =
MoneyTransferRemoteDataSourceImpl(apiClient);

final moneyTransferRepository =
MoneyTransferRepositoryImpl(moneyTransferRemoteDataSource);

final moneyTransferUseCase =
MoneyTransferUseCase(moneyTransferRepository);

// Transactions dependencies
final transactionsRemoteDataSource =
TransactionsRemoteDataSourceImpl(apiClient);

final transactionsRepository =
TransactionsRepositoryImpl(transactionsRemoteDataSource);

final transactionsUsecase =
GetTransactionsUsecase(transactionsRepository);
