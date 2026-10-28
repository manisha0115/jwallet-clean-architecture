
import 'package:flutter/foundation.dart';

@immutable
abstract class WalletEvent {}

class GetWalletBalanceEvent extends WalletEvent {
  final Map<String, String> headers;

  GetWalletBalanceEvent({
    required this.headers,
  });
}
