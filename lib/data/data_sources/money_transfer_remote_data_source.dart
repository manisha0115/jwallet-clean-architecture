
import 'dart:convert';

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
    try {
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

      // Handle JSON response
      final Map<String, dynamic> responseData;

      if (response is Map<String, dynamic>) {
        responseData = response;
      } else if (response is String) {
        final decoded = jsonDecode(response);

        if (decoded is! Map<String, dynamic>) {
          throw Exception('Invalid transfer response format');
        }

        responseData = decoded;
      } else {
        throw Exception('Unexpected transfer response format');
      }

      return Transfermodel.fromJson(responseData);
    } catch (e) {
      throw Exception(
        'Money transfer failed: ${e.toString().replaceFirst('Exception: ', '')}',
      );
    }
  }
}
