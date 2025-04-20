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
import 'package:volt_ui/pages/wallet/transaction_details/transaction_pending.dart';
import 'package:volt_ui/pages/wallet/wallet_overview.dart';
import 'package:volt_ui/pages/wallet/wallet_transactions.dart';
import 'package:volt_ui/repository/wallet_repository.dart';
import 'package:volt_ui/services/wallet/wallet_poller.dart';
import 'package:volt_ui/ui/vui_button.dart';

class WalletMain extends StatefulWidget {
  final Wallet wallet;
  final bool isActive;

  const WalletMain({
    super.key,
    required this.wallet,
    required this.isActive,
  });

  @override
  State<WalletMain> createState() => _WalletMainState();
}

class _WalletMainState extends State<WalletMain> {
  late final WalletRepository walletRepository;
  late WalletPoller _walletPoller;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    walletRepository = WalletRepository(widget.wallet);
    _walletPoller = WalletPoller(
      context: context,
      wallet: widget.wallet,
      walletRepository: walletRepository,
      onRefreshStarted: () => {
        setState(() {
          _isLoading = true;
          _error = null;
        })
      },
      onRefreshStopped: () async {
        setState(() {
          _isLoading = false;
          _error = null;
        });
      },
      onRefreshErrored: (error) => {
        setState(() {
          _isLoading = false;
          _error = error;
        })
      },
      onInvoicePaid: (String message) {
        showSuccess(
          context: context,
          text: message,
        );
      },
    );
    _walletPoller.start();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
              padding: const EdgeInsets.only(
                  top: 20, left: 20, right: 20, bottom: 20),
              child: WalletOverview(
                balanceSats: widget.wallet.cachedBalanceSats,
                isLoading: _isLoading,
                onSettings: _openSettings,
                onRefresh: _walletPoller.start,
                wallet: widget.wallet,
              )),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(
              _error!,
              style: const TextStyle(color: Colors.redAccent),
            ),
          ],
          _buildActionButtons(),
          const SizedBox(height: 20),
          WalletTransactions(
              transactions: _transactions, onTransactionTap: _openTransaction),
        ],
      ),
    );
  }

  List<LndHubTransaction> get _transactions {
    return widget.wallet.cachedTransactions;
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
        body: PayInvoice(
            onSuccess: _onPayInvoiceSuccess, repository: walletRepository));
  }

  void _openTransaction(LndHubTransaction transaction) {
    if (transaction.isPaid) {
      openFullscreen(
        context: context,
        title: 'Lightning Transaction',
        body: TransactionDetails(transaction: transaction),
      );
    } else {
      _openTransactionPending(transaction);
    }
  }

  void _onPayInvoiceSuccess(LndHubPaymentInvoiceDto dto) async {
    await _walletPoller.start();
    // ignore: use_build_context_synchronously
    Navigator.of(context).pop();
    showSuccess(
        // ignore: use_build_context_synchronously
        context: context,
        text:
            'Payment successful: ${dto.value.toInt()} sats with: ${dto.memo}');
  }

  void openCreateInvoice(BuildContext context) {
    return openFullscreen(
        context: context,
        title: 'Receive',
        body: CreateInvoice(
            onSuccess: _onCreateInvoiceSuccess, repository: walletRepository));
  }

  void _onCreateInvoiceSuccess(String invoice) async {
    await _walletPoller.start();
    LndHubTransaction? transaction =
        walletRepository.getTransactionByPaymentRequest(invoice);

    if (transaction != null) {
      _openTransactionPending(transaction, replace: true);
    } else {
      if (context.mounted) {
        // ignore: use_build_context_synchronously
        Navigator.of(context).pop();
        // ignore: use_build_context_synchronously
        showError(context: context, text: 'Created Invoice not found');
      }
    }
  }

  void _openTransactionPending(LndHubTransaction transaction,
      {bool replace = false}) {
    _walletPoller.transactionNotifier = ValueNotifier(transaction);
    _walletPoller.start();

    openFullscreen(
      replace: replace,
      context: context,
      title: 'Lightning Transaction',
      body: TransactionPending(
          transactionNotifier: _walletPoller.transactionNotifier!),
      onClosed: () {
        if (_walletPoller.transactionNotifier != null) {
          _walletPoller.transactionNotifier!.dispose();
        }
        _walletPoller.transactionNotifier = null;
      },
    );
  }

  @override
  void didUpdateWidget(covariant WalletMain oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isActive && !oldWidget.isActive) {
      _walletPoller.start();
    } else if (!widget.isActive && oldWidget.isActive) {
      _walletPoller.stop();
    }
  }
}
