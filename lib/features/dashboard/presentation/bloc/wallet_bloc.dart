
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../domain/repositories/wallet_repository.dart';
import 'wallet_event.dart';
import 'wallet_state.dart';

class WalletBloc extends Bloc<WalletEvent, WalletState> {
  final WalletRepository _walletRepository;

  WalletBloc(this._walletRepository) : super(WalletInitial()) {
    on<GetWalletBalanceEvent>(_onGetWalletBalance);
  }

  Future<void> _onGetWalletBalance(
      GetWalletBalanceEvent event,
      Emitter<WalletState> emit,
      ) async {
    emit(WalletLoading());

    try {
      final result = await _walletRepository.getWalletBalance(
        event.headers,
      );

      result.fold(
            (error) {
          emit(
            WalletFailure(
              error.message ?? 'Failed to load wallet balance.',
            ),
          );
        },
            (response) {
          if (response.success) {
            emit(WalletSuccess(response));
          } else {
            emit(
              WalletFailure('Failed to load wallet balance.'),
            );
          }
        },
      );
    } catch (e) {
      emit(
        WalletFailure(
          'Something went wrong. Please try again.',
        ),
      );
    }
  }
}
