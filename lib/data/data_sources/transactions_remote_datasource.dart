
import '../../../../core/network/api_client.dart';
import '../models/transactions_model.dart';

abstract class TransactionsRemoteDataSource {
  Future<Transactionsmodel> getTransactions(
      Map<String, String> headers,
      );
}

class TransactionsRemoteDataSourceImpl
    implements TransactionsRemoteDataSource {
  final ApiClient _client;

  TransactionsRemoteDataSourceImpl(this._client);

  @override
  Future<Transactionsmodel> getTransactions(
      Map<String, String> headers,
      ) async {
    final response = await _client.get(
      'api/v1/transactions',
      headers: headers,
    );

    return Transactionsmodel.fromJson(
      Map<String, dynamic>.from(response as Map),
    );
  }
}
