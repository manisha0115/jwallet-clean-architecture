
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/storage/secure_storage_service.dart';
import '../../../../di/injection.dart';
import '../../../../domain/repositories/wallet_repository.dart';
import '../../../../domain/usecase/money_transfer_usecase.dart';
import '../../../transactions/presentation/bloc/transactions_bloc.dart';
import '../../../transactions/presentation/bloc/transactions_event.dart';
import '../../../transactions/presentation/screens/transactions_screen.dart';
import '../../../transfer_screen/presentation/bloc/transfer_bloc.dart';
import '../../../transfer_screen/presentation/screens/money_transfer_screen.dart';
import '../bloc/wallet_bloc.dart';
import '../bloc/wallet_event.dart';
import '../bloc/wallet_state.dart';



class WalletScreen extends StatelessWidget {
  final WalletRepository walletRepository;
  final MoneyTransferUseCase moneyTransferUseCase;
  final String accessToken;

  const WalletScreen({
    super.key,
    required this.walletRepository,
    required this.moneyTransferUseCase,
    required this.accessToken,
  });

  @override
  Widget build(BuildContext context) {

    final headers = <String, String>{
      'Authorization': 'Bearer $accessToken',
      'Accept': 'application/json',
    };

    return BlocProvider(
      create: (_) => WalletBloc(walletRepository)
        ..add(GetWalletBalanceEvent(headers: headers)),
      child: _WalletView(
        headers: headers,
        accessToken: accessToken,
        moneyTransferUseCase: moneyTransferUseCase,
      ),
    );
  }
}

class _WalletView extends StatelessWidget {
  final Map<String, String> headers;
  final String accessToken;
  final MoneyTransferUseCase moneyTransferUseCase;

  const _WalletView({
    required this.headers,
    required this.accessToken,
    required this.moneyTransferUseCase,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final isDark =
        Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      appBar: AppBar(
        title: const Text(
          'My Wallet',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: false,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),

            onPressed: () {
              showModalBottomSheet<void>(
                context: context,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                ),
                builder: (bottomSheetContext) {
                  return SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.logout_rounded,
                            size: 42,
                            color: Colors.redAccent,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Are you sure you want to logout?',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'You will need to login again to access your wallet.',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),

                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(bottomSheetContext);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                                    foregroundColor: Theme.of(context).colorScheme.onSurface,
                                    elevation: 0,
                                    minimumSize: const Size.fromHeight(48),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text('Cancel'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () async {
                                    Navigator.pop(bottomSheetContext);

                                    try {
                                      await SecureStorageService().deleteToken();

                                      if (!context.mounted) return;

                                      Navigator.pushNamedAndRemoveUntil(
                                        context,
                                        '/login',
                                            (route) => false,
                                      );
                                    } catch (e) {
                                      if (!context.mounted) return;

                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Logout failed. Please try again.'),
                                        ),
                                      );
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                                    foregroundColor: Theme.of(context).colorScheme.onSurface,
                                    elevation: 0,
                                    minimumSize: const Size.fromHeight(48),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text('Logout'),
                                ),
                              ),
                            ],
                          )

                        ],
                      ),
                    ),
                  );
                },
              );
            },

          ),
        ],
      ),

      body: BlocBuilder<WalletBloc, WalletState>(
        builder: (context, state) {
          if (state is WalletLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is WalletFailure) {
            return _buildError(
              context,
              state.message,
            );
          }

          if (state is WalletSuccess) {
            final wallet = state.response.data;

            return RefreshIndicator(
              onRefresh: () async {
                context.read<WalletBloc>().add(
                  GetWalletBalanceEvent(headers: headers),
                );

                await context
                    .read<WalletBloc>()
                    .stream
                    .firstWhere(
                      (state) =>
                  state is WalletSuccess ||
                      state is WalletFailure,
                );
              },

              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                children: [
                  Text(
                    'Available Balance',
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Wallet balance card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF21366D),
                          Color(0xFF4169B2),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF21366D)
                              .withValues(alpha: 0.20),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.account_balance_wallet_outlined,
                              color: Colors.white,
                              size: 28,
                            ),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Text(
                                'JWallet',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(
                                  alpha: 0.15,
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                wallet.currency,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
                        Text(
                          '${wallet.currency} '
                              '${wallet.availableBalance.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Available to spend',
                          style: TextStyle(
                            color: Color(0xFFDCE7FF),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 28),
                        const Divider(color: Colors.white30),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(
                              Icons.credit_card,
                              color: Colors.white70,
                              size: 22,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                wallet.maskedAccountNumber,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.verified_user_outlined,
                              color: Colors.white70,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

// Wallet actions
                  // Wallet actions
                  Row(
                    children: [
                      Expanded(
                        child: _actionButton(
                          context: context,
                          icon: Icons.send_rounded,
                          title: 'Send Money',
                          onTap: () async {
                            final transferred = await Navigator.push<bool>(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BlocProvider<TransferBloc>(
                                  create: (_) => TransferBloc(moneyTransferUseCase),
                                  child: MoneyTransferScreen(
                                    accessToken: accessToken,
                                  ),
                                ),
                              ),
                            );

                            if (!context.mounted) return;

                            if (transferred == true) {
                              context.read<WalletBloc>().add(
                                GetWalletBalanceEvent(headers: headers),
                              );
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _actionButton(
                          context: context,
                          icon: Icons.receipt_long_rounded,
                          title: 'Transactions',
                          onTap: () async {
                            final headers = <String, String>{
                              'Authorization': 'Bearer $accessToken',
                              'Accept': 'application/json',
                            };

                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BlocProvider<TransactionBloc>(
                                  create: (_) => TransactionBloc(transactionsUsecase)
                                    ..add(LoadTransactions(headers: headers)),
                                  child: TransactionHistoryScreen(
                                    accessToken: accessToken,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),


                  const SizedBox(height: 28),

                  Text(
                    'Wallet Details',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 14),

                  _detailTile(
                    context: context,
                    icon: Icons.account_balance_outlined,
                    title: 'Wallet ID',
                    value: wallet.walletId,
                  ),
                  const SizedBox(height: 12),
                  _detailTile(
                    context: context,
                    icon: Icons.currency_exchange,
                    title: 'Currency',
                    value: wallet.currency,
                  ),
                  const SizedBox(height: 12),
                  _detailTile(
                    context: context,
                    icon: Icons.account_box_outlined,
                    title: 'Account Number',
                    value: wallet.maskedAccountNumber,
                  ),

                  const SizedBox(height: 24),



            OutlinedButton.icon(
              onPressed: () {
                context.read<WalletBloc>().add(
                  GetWalletBalanceEvent(
                    headers: headers,
                  ),
                );
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh Balance'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                foregroundColor: isDark ? Colors.white : const Color(0xFF21366D),
                side: BorderSide(
                  color: isDark ? Colors.white : const Color(0xFF21366D),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
                ],
              ),
            );
          }

          return Center(
            child: Text(
              'Your wallet information will appear here.',
              style: theme.textTheme.bodyMedium,
            ),
          );
        },
      ),
    );
  }

  Widget _buildError(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.account_balance_wallet_outlined,
              size: 60,
              color: Colors.redAccent,
            ),
            const SizedBox(height: 16),
            const Text(
              'Unable to load wallet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                context.read<WalletBloc>().add(
                  GetWalletBalanceEvent(headers: headers),
                );
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String value,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color ??
            theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outlineVariant,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return Material(
      color: theme.cardTheme.color ?? theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: 20,
            horizontal: 12,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.outlineVariant,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 28,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}
