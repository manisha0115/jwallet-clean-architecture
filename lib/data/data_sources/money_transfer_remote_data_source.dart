
import '../../core/network/api_client.dart';
import '../../domain/entities/money_transfer_request_model.dart';

import '../models/transfer_model.dart';

abstract class MoneyTransferRemoteDataSource {
  Future<Transfermodel> transferMoney({
    required MoneyTransferRequestModel request,
    required Map<String, String> headers,
    required String idempotencyKey,
  });
}

class MoneyTransferRemoteDataSourceImpl
    implements MoneyTransferRemoteDataSource {
  final ApiClient _client;

  MoneyTransferRemoteDataSourceImpl(this._client);

  @override
  Future<Transfermodel> transferMoney({
    required MoneyTransferRequestModel request,
    required Map<String, String> headers,
    required String idempotencyKey,
  }) async {
    final response = await _client.post(
      'api/v1/transactions/transfer',
      headers: {
        ...headers,
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Idempotency-Key': idempotencyKey,
      },
      params: request.toJson(),
    );

    return Transfermodel.fromJson(
      response as Map<String, dynamic>,
    );
  }
}
