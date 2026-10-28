
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../domain/usecase/login_usecase.dart';
import 'login_event.dart';
import 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final LoginUser _loginUser;

  LoginBloc(this._loginUser) : super(LoginInitial()) {
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

      result.fold(
            (error) {
          emit(
            LoginFailure(
              error.message ?? 'Login failed. Please try again.',
            ),
          );
        },
            (response) {
          if (response.success) {
            emit(LoginSuccess(response));
          } else {
            emit(LoginFailure('Login failed. Please try again.'));
          }
        },
      );
    } catch (e) {
      emit(LoginFailure('Something went wrong. Please try again.'));
    }
  }
}
