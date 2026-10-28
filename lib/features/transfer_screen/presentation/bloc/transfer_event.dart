import '../../../../domain/entities/money_transfer_request_model.dart';

abstract class TransferEvent {}

class SubmitTransfer extends TransferEvent {
  final MoneyTransferRequestModel request;
  final Map<String, String> headers;
  final String idempotencyKey;

  SubmitTransfer({
    required this.request,
    required this.headers,
    required this.idempotencyKey,
  });
}