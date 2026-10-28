import '../../../../core/network/api_client.dart';
import '../models/balance_model.dart';

abstract class WalletRemoteDataSource {
  Future<Balancemodel> getWalletBalance(
    Map<String, String> headers,
  );
}

class WalletRemoteDataSourceImpl implements WalletRemoteDataSource {
  final ApiClient _client;

  WalletRemoteDataSourceImpl(this._client);

  @override
  Future<Balancemodel> getWalletBalance(
    Map<String, String> headers,
  ) async {
    final response = await _client.get(
      'api/v1/wallet/balance',
      headers: headers,
    );

    return Balancemodel.fromJson(
      Map<String, dynamic>.from(response as Map),
    );
  }
}
