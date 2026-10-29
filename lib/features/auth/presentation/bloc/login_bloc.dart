
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/storage/secure_storage_service.dart';
import '../../../../domain/usecase/login_usecase.dart';
import 'login_event.dart';
import 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final LoginUser _loginUser;
  final SecureStorageService _secureStorage;

  LoginBloc(
      this._loginUser,
      this._secureStorage,
      ) : super(LoginInitial()) {
    on<LoginSubmitted>(_onLoginSubmitted);
  }

  Future<void> _onLoginSubmitted(
      LoginSubmitted event,
      Emitter<LoginState> emit,
      ) async {
    emit(LoginLoading());

    try {
      final result = await _loginUser.call(
        event.params,
        <String, String>{},
      );

      await result.fold<Future<void>>(
            (error) async {
          emit(
            LoginFailure(
              error.message ?? 'Login failed. Please try again.',
            ),
          );
        },
            (response) async {
          if (response.success) {
            final token = response.data.accessToken;

            if (token.isEmpty) {
              emit(LoginFailure('Login token is missing.'));
              return;
            }

            // Save the token securely before login succeeds.
            await _secureStorage.saveToken(token);
// Verify that the token was saved
            final savedToken = await _secureStorage.getToken();

            if (savedToken != null && savedToken.isNotEmpty) {
              debugPrint('SecureStorage: Token saved successfully');
              debugPrint('SecureStorage: Token exists = true');
            } else {
              debugPrint('SecureStorage: Token save verification failed');
              emit(LoginFailure('Unable to save login session.'));
              return;
            }
            emit(LoginSuccess(response));
          } else {
            emit(LoginFailure('Login failed. Please try again.'));
          }
        },
      );
    } catch (e) {
      emit(
        LoginFailure('Something went wrong. Please try again.'),
      );
    }
  }
}
