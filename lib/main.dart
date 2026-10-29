
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jwallet_clean_architecture/splash_screen.dart';

import 'app/theme/app_theme.dart';
import 'core/network/api_client.dart';
import 'core/storage/auth_check_screen.dart';
import 'core/storage/secure_storage_service.dart';
import 'data/data_sources/auth_demo_data_source.dart';

import 'data/repositories/auth_repository_impl.dart';
import 'di/injection.dart';
import 'domain/usecase/login_usecase.dart';
import 'features/auth/presentation/bloc/login_bloc.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/dashboard/presentation/screens/wallet_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Create your API client using its actual constructor.
  final apiClient = ApiClient(baseUrl: 'https://jwallet-api.onrender.com');

  final remoteDataSource = AuthRemoteDataSourceImpl(apiClient);

  final authRepository = AuthRepositoryImpl(remoteDataSource);

  final loginUser = LoginUser(authRepository);

  runApp(
    BlocProvider<LoginBloc>(
      create: (_) => LoginBloc(
        loginUser,
        SecureStorageService(),
      ),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,

      // Remove: home: const SplashScreen()
      // Keep initialRoute as '/'

      initialRoute: '/',

      routes: {
        '/': (context) => const AuthCheckScreen(),

        '/login': (context) => const LoginScreen(),

        '/wallet': (context) {
          final accessToken =
          ModalRoute.of(context)!.settings.arguments as String;

          return WalletScreen(
            walletRepository: walletRepository,
            moneyTransferUseCase: moneyTransferUseCase,
            accessToken: accessToken,
          );
        },
      },
    );
  }
}
