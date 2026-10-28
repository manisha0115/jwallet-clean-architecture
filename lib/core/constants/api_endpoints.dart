class ApiEndpoints {
  ApiEndpoints._();
  // Configure your real server: flutter run --dart-define=API_BASE_URL=https://your-domain/api/
  static const baseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: 'https://example.com/api/');
  static const login = 'auth/login';
  static const walletSummary = 'wallet/summary';
  static const sendMoney = 'wallet/send';
  static const transactions = 'wallet/transactions';
}
