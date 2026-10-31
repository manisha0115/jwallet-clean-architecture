
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../domain/entities/money_transfer_request_model.dart';
import '../bloc/transfer_bloc.dart';
import '../bloc/transfer_event.dart';
import '../bloc/transfer_state.dart';

class MoneyTransferScreen extends StatefulWidget {
  final String accessToken;
  final double availableBalance;

  const MoneyTransferScreen({
    super.key,
    required this.accessToken,
    required this.availableBalance,
  });

  @override
  State<MoneyTransferScreen> createState() =>
      _MoneyTransferScreenState();
}

class _MoneyTransferScreenState extends State<MoneyTransferScreen> {
  final _formKey = GlobalKey<FormState>();

  final _beneficiaryController = TextEditingController();
  final _mobileController = TextEditingController();
  final _amountController = TextEditingController();
  final _remarksController = TextEditingController();

  bool _isSubmitting = false;
  String? _idempotencyKey;

  static const Color _primaryColor = Color(0xFF243B80);

  @override
  void dispose() {
    _beneficiaryController.dispose();
    _mobileController.dispose();
    _amountController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  // -------------------- VALIDATION --------------------

  String? _validateRequired(String? value, String label) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter $label';
    }
    return null;
  }

  String? _validateMobile(String? value) {
    if (value == null ||
        !RegExp(r'^[0-9]{10}$').hasMatch(value.trim())) {
      return 'Enter a valid 10-digit mobile number';
    }
    return null;
  }

  String? _validateAmount(String? value) {
    final amount = double.tryParse(value?.trim() ?? '');

    if (amount == null || !amount.isFinite || amount <= 0) {
      return 'Enter a valid amount greater than zero';
    }

    return null;
  }

  // -------------------- SUBMIT TRANSFER --------------------

  void _submitTransfer() {
    if (_isSubmitting) return;

    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    final amount = double.tryParse(_amountController.text.trim());

    if (amount == null || !amount.isFinite || amount <= 0) {
      return;
    }

    // Check available wallet balance before API call.
    if (amount > widget.availableBalance) {
      final theme = Theme.of(context);
      final colors = theme.colorScheme;
      final isDark = theme.brightness == Brightness.dark;

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              'Insufficient wallet balance. '
                  'Available balance: ₹${widget.availableBalance.toStringAsFixed(2)}',
              style: TextStyle(
                color: isDark ? Colors.white : colors.onPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            backgroundColor: colors.primary,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );

      return;
    }

    // Generate idempotency key.
    _idempotencyKey ??=
    'transfer-${DateTime.now().microsecondsSinceEpoch}';

    final request = MoneyTransferRequestModel(
      beneficiaryName: _beneficiaryController.text.trim(),
      mobileNumber: _mobileController.text.trim(),
      amount: amount,
      remarks: _remarksController.text.trim(),
    );

    context.read<TransferBloc>().add(
      SubmitTransfer(
        request: request,
        headers: {
          'Authorization': 'Bearer ${widget.accessToken}',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        idempotencyKey: _idempotencyKey!,
      ),
    );
  }


  void _resetForm() {
    _beneficiaryController.clear();
    _mobileController.clear();
    _amountController.clear();
    _remarksController.clear();
    _idempotencyKey = null;

    _formKey.currentState?.reset();
  }


  void _showSuccessDialog(TransferSuccess state) {
    final data = state.response.data;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        final colors = Theme.of(dialogContext).colorScheme;

        return AlertDialog(
          backgroundColor: colors.surface,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  color: Colors.green,
                  size: 64,
                ),
                const SizedBox(height: 16),
                Text(
                  'Transfer Successful!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: colors.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your money has been transferred successfully.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  '${data.currency} '
                      '${data.amount.toStringAsFixed(2)}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: colors.primary,
                  ),
                ),
                const SizedBox(height: 24),
                _detailRow(
                  dialogContext,
                  'Transaction ID',
                  data.transactionId,
                ),
                const SizedBox(height: 12),
                _detailRow(
                  dialogContext,
                  'Status',
                  data.status,
                ),
                const SizedBox(height: 12),
                _detailRow(
                  dialogContext,
                  'Available Balance',
                  '${data.currency} '
                      '${data.availableBalance.toStringAsFixed(2)}',
                ),
              ],
            ),
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Close the success dialog first.
                  Navigator.of(dialogContext).pop();

                  // Clear the completed transfer form.
                  _resetForm();

                  // Return to the Wallet screen with success result.
                  if (mounted) {
                    Navigator.of(context).pop(true);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: colors.onPrimary,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Done',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // -------------------- DIALOG DETAIL ROW --------------------

  Widget _detailRow(
      BuildContext context,
      String label,
      String value,
      ) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            '$label:',
            style: TextStyle(
              color: colors.onSurfaceVariant,
              fontSize: 13,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              color: colors.onSurface,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  // -------------------- SCREEN UI --------------------

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return BlocListener<TransferBloc, TransferState>(
      listener: (context, state) {
        if (!mounted) return;

        if (state is TransferLoading) {
          setState(() => _isSubmitting = true);
        } else {
          setState(() => _isSubmitting = false);
        }

        if (state is TransferSuccess) {
          _showSuccessDialog(state);
        } else if (state is TransferFailure) {
          final errorMessage = state.message.toLowerCase();

          String displayMessage;

          if (errorMessage.contains('insufficient')) {
            displayMessage =
            'Insufficient wallet balance. Your available balance is '
                '₹${widget.availableBalance.toStringAsFixed(2)}.';
          } else {
            displayMessage = state.message;
          }

          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(displayMessage),
                backgroundColor: Colors.red.shade700,
              ),
            );
        }
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: const Text(
            'Money Transfer',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          backgroundColor: theme.appBarTheme.backgroundColor ??
              theme.scaffoldBackgroundColor,
          foregroundColor:
          theme.appBarTheme.foregroundColor ?? colors.onSurface,
          elevation: 0,
          centerTitle: false,
        ),
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Header card
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: colors.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.account_balance_wallet_outlined,
                        color: Colors.white,
                        size: 34,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Send Money Securely',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Enter the beneficiary details below.',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                _label(context, 'Beneficiary Name'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _beneficiaryController,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  decoration: _decoration(
                    context,
                    'Enter beneficiary name',
                    Icons.person_outline,
                  ),
                  validator: (value) =>
                      _validateRequired(value, 'beneficiary name'),
                ),

                const SizedBox(height: 20),

                _label(context, 'Mobile Number'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _mobileController,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  maxLength: 10,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  decoration: _decoration(
                    context,
                    'Enter 10-digit mobile number',
                    Icons.phone_android,
                  ).copyWith(counterText: ''),
                  validator: _validateMobile,
                ),

                const SizedBox(height: 20),

                _label(context, 'Amount (INR)'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  textInputAction: TextInputAction.next,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d*\.?\d{0,2}'),
                    ),
                  ],
                  decoration: _decoration(
                    context,
                    'Enter transfer amount',
                    Icons.currency_rupee,
                  ),
                  validator: _validateAmount,
                ),

                const SizedBox(height: 20),

                _label(context, 'Remarks (Optional)'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _remarksController,
                  textCapitalization: TextCapitalization.sentences,
                  maxLines: 3,
                  maxLength: 200,
                  decoration: _decoration(
                    context,
                    'Add a note for this transfer',
                    Icons.notes,
                  ),
                ),

                const SizedBox(height: 28),

                SizedBox(
                  height: 54,
                  child: ElevatedButton(
                    onPressed:
                    _isSubmitting ? null : _submitTransfer,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primary,
                      foregroundColor: colors.onPrimary,
                      disabledBackgroundColor:
                      isDark ? Colors.grey.shade800 : Colors.grey.shade400,
                      disabledForegroundColor:
                      isDark ? Colors.white70 : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                      height: 23,
                      width: 23,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        :Text(
                      'Transfer Money',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.lock_outline,
                      size: 16,
                      color: colors.onSurfaceVariant,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'Your transfer is processed securely',
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // -------------------- FIELD LABEL --------------------

  Widget _label(BuildContext context, String text) {
    final colors = Theme.of(context).colorScheme;

    return Text(
      text,
      style: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 14,
        color: colors.onSurface,
      ),
    );
  }

  // -------------------- FIELD DECORATION --------------------

  InputDecoration _decoration(
      BuildContext context,
      String hint,
      IconData icon,
      ) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: colors.onSurfaceVariant,
      ),
      prefixIcon: Icon(
        icon,
        color: colors.primary,
      ),
      filled: true,
      fillColor: colors.surface,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: colors.outlineVariant,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: colors.primary,
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: colors.error,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: colors.error,
          width: 1.5,
        ),
      ),
    );
  }
}
