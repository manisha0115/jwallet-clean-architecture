
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../domain/repositories/wallet_repository.dart';
import '../bloc/wallet_bloc.dart';
import '../bloc/wallet_event.dart';
import '../bloc/wallet_state.dart';



class WalletScreen extends StatelessWidget {
  final WalletRepository walletRepository;
  final String accessToken;

  const WalletScreen({
    super.key,
    required this.walletRepository,
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
      child: _WalletView(headers: headers),
    );
  }
}

class _WalletView extends StatelessWidget {
  final Map<String, String> headers;

  const _WalletView({required this.headers});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text(
          'My Wallet',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: false,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF172554),
        elevation: 0,
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
                  const Text(
                    'Available Balance',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF64748B),
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

                  const SizedBox(height: 28),

                  const Text(
                    'Wallet Details',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF172554),
                    ),
                  ),
                  const SizedBox(height: 14),

                  _detailTile(
                    icon: Icons.account_balance_outlined,
                    title: 'Wallet ID',
                    value: wallet.walletId,
                  ),
                  const SizedBox(height: 12),
                  _detailTile(
                    icon: Icons.currency_exchange,
                    title: 'Currency',
                    value: wallet.currency,
                  ),
                  const SizedBox(height: 12),
                  _detailTile(
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
                      foregroundColor: const Color(0xFF21366D),
                      side: const BorderSide(
                        color: Color(0xFF21366D),
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
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8ECF3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF0FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF21366D),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF172554),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
