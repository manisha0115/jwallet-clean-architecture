
import 'package:flutter/foundation.dart';

import '../../../../data/models/balance_model.dart';

@immutable
abstract class WalletState {}

class WalletInitial extends WalletState {}

class WalletLoading extends WalletState {}

class WalletSuccess extends WalletState {
  final Balancemodel response;

  WalletSuccess(this.response);
}

class WalletFailure extends WalletState {
  final String message;

  WalletFailure(this.message);
}
