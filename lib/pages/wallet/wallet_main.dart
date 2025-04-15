import 'package:flutter/material.dart';
import 'package:volt_ui/layout/open_fullscreen.dart';
import 'package:volt_ui/layout/show_error.dart';
import 'package:volt_ui/layout/show_success.dart';
import 'package:volt_ui/models/lndhub/lndhub_payment_invoice_dto.dart';
import 'package:volt_ui/models/lndhub/lndhub_transaction.dart';
import 'package:volt_ui/models/wallets/wallet.dart';
import 'package:volt_ui/pages/wallet/create_invoice/create_invoice.dart';
import 'package:volt_ui/pages/wallet/pay_invoice/pay_invoice.dart';
import 'package:volt_ui/pages/wallet/settings/wallet_settings.dart';
import 'package:volt_ui/pages/wallet/transaction_details/transaction_details.dart';
import 'package:volt_ui/pages/wallet/wallet_overview.dart';
import 'package:volt_ui/pages/wallet/wallet_transactions.dart';
import 'package:volt_ui/repository/wallet_repository.dart';
import 'package:volt_ui/ui/vui_button.dart';

class WalletMain extends StatefulWidget {
  final Wallet wallet;

  const WalletMain({
    super.key,
    required this.wallet,
  });

  @override
  State<WalletMain> createState() => _WalletMainState();
}

class _WalletMainState extends State<WalletMain> {
  late final WalletRepository _repo;
  int? _balanceSats;
  final List<LndHubTransaction> _transactions = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _repo = WalletRepository(widget.wallet);
    _refreshWallet();
  }

  Future<void> _refreshWallet() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final balance = await _repo.getBalance();
      final transactions = await _repo.getTransactions();
      _transactions.clear();
      _transactions.addAll(transactions);

      setState(() {
        _balanceSats = balance;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
              child: WalletOverview(
                balanceSats: _balanceSats ?? 0,
                isLoading: _isLoading,
                onSettings: _openSettings,
                onRefresh: _refreshWallet,
                wallet: widget.wallet,
              )),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(
              _error!,
              style: const TextStyle(color: Colors.redAccent),
            ),
          ],
          const SizedBox(height: 20),
          _buildActionButtons(),
          const SizedBox(height: 20),
          WalletTransactions(
              transactions: _transactions, onTransactionTap: _openTransaction),
        ],
      ),
    );
  }

  _openSettings() {
    return openFullscreen(
        context: context,
        title: 'Wallet Settings',
        body: WalletSettings(
          wallet: widget.wallet,
        ));
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        VUIButton(
            isFullWidth: false,
            icon: Icons.send,
            label: 'Send',
            onPressed: () {
              openPayInvoice(context);
            }),
        VUIButton(
            isFullWidth: false,
            icon: Icons.download,
            label: 'Receive',
            onPressed: () {
              openCreateInvoice(context);
            }),
        /* VUIButton(icon: Icons.qr_code_scanner, label: 'Scan', onPressed: () {}), */
      ],
    );
  }

  void openPayInvoice(BuildContext context) {
    return openFullscreen(
        context: context,
        title: 'Pay Invoice',
        body: PayInvoice(onSuccess: _onPayInvoiceSuccess, repository: _repo));
  }

  void _onPayInvoiceSuccess(LndHubPaymentInvoiceDto dto) async {
    await _refreshWallet();
    // ignore: use_build_context_synchronously
    Navigator.of(context).pop();
    showSuccess(
        context: context,
        text:
            'Payment successful: ${dto.value.toInt()} sats with: ${dto.memo}');
  }

  void openCreateInvoice(BuildContext context) {
    return openFullscreen(
        context: context,
        title: 'Receive',
        body: CreateInvoice(
            onSuccess: _onCreateInvoiceSuccess, repository: _repo));
  }

  void _onCreateInvoiceSuccess(String invoice) async {
    await _refreshWallet();
    LndHubTransaction? transaction =
        _repo.getTransactionByPaymentRequest(invoice);

    if (transaction != null) {
      _openTransaction(transaction, replace: true);
    } else {
      if (context.mounted) {
        // ignore: use_build_context_synchronously
        Navigator.of(context).pop();
        // ignore: use_build_context_synchronously
        showError(context: context, text: 'Created Invoice not found');
      }
    }
  }

  void _openTransaction(LndHubTransaction transaction, {bool replace = false}) {
    openFullscreen(
        replace: replace,
        context: context,
        title: 'Lightning Transaction',
        body: TransactionDetails(transaction: transaction));
  }
}
