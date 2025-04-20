import 'dart:async';

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
import 'package:volt_ui/ui/vui_button.dart';
import 'package:collection/collection.dart';

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
  late final WalletRepository _repo;
  int? _balanceSats;
  final List<LndHubTransaction> _transactions = [];
  ValueNotifier<LndHubTransaction>? _transactionNotifier;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _repo = WalletRepository(widget.wallet);
    startAutorefreshWallet();
  }

  Future<void> _refreshWallet() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final balance = await _repo.getBalance();
      final transactions = await _repo.getTransactions();
      _updateTransactions(transactions);

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
      padding: const EdgeInsets.only(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
              padding: const EdgeInsets.only(
                  top: 20, left: 20, right: 20, bottom: 20),
              child: WalletOverview(
                balanceSats: _balanceSats ?? 0,
                isLoading: _isLoading,
                onSettings: _openSettings,
                onRefresh: startAutorefreshWallet,
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
    await startAutorefreshWallet();
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
            onSuccess: _onCreateInvoiceSuccess, repository: _repo));
  }

  void _onCreateInvoiceSuccess(String invoice) async {
    await startAutorefreshWallet();
    LndHubTransaction? transaction =
        _repo.getTransactionByPaymentRequest(invoice);

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
    _transactionNotifier = ValueNotifier(transaction);
    startAutorefreshWallet();

    openFullscreen(
      replace: replace,
      context: context,
      title: 'Lightning Transaction',
      body: TransactionPending(transactionNotifier: _transactionNotifier!),
      onClosed: () {
        if (_transactionNotifier != null) {
          _transactionNotifier!.dispose();
        }
        _transactionNotifier = null;
      },
    );
  }

  @override
  void didUpdateWidget(covariant WalletMain oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isActive && !oldWidget.isActive) {
      startAutorefreshWallet();
    } else if (!widget.isActive && oldWidget.isActive) {
      stopAutorefreshWallet();
    }
  }

  Timer? _autoRefreshTimer;

  startAutorefreshWallet() async {
    _autoRefreshTimer?.cancel();
    await _refreshWallet();

    int autoRefreshInterval = 2000;

    // Check if a transaction is being watched
    if (_transactionNotifier != null) {
      autoRefreshInterval = 250;
      final updatedTransaction = _repo.getTransactionByPaymentHash(
        _transactionNotifier!.value.paymentHash,
      );

      if (updatedTransaction != null && updatedTransaction.isPaid) {
        _transactionNotifier?.value = updatedTransaction;
      }
    }

    if (_transactionsToWatch(itemsToWatch: 5) <= 0) {
      autoRefreshInterval = 10 * 1000;
    }

    // ignore: prefer_conditional_assignment
    print(
        '${widget.wallet.label} Starting autorefresh with $autoRefreshInterval');
    _autoRefreshTimer = Timer(
      Duration(milliseconds: autoRefreshInterval),
      () {
        startAutorefreshWallet(); // restart the whole logic cleanly
      },
    );
  }

  void stopAutorefreshWallet() {
    print('${widget.wallet.label} Stop autorefresh');
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = null;
  }

  void _updateTransactions(List<LndHubTransaction> newTransactions) {
    for (final newTx in newTransactions) {
      final existingTx = _transactions
          .firstWhereOrNull((t) => t.paymentHash == newTx.paymentHash);
      if (existingTx == null) {
        continue;
      }

      if (existingTx.transactionType == LndHubTransactionType.userInvoice &&
          !existingTx.isPaid &&
          newTx.isPaid) {
        if (context.mounted) {
          showSuccess(
            context: context,
            text:
                'Payment received: ${newTx.value} sats with: ${newTx.description}',
          );
        }
      }
    }

    _transactions.clear();
    _transactions.addAll(newTransactions);
  }

  int _transactionsToWatch({int? itemsToWatch}) {
    final transactionsToCheck =
        itemsToWatch != null ? _transactions.take(itemsToWatch) : _transactions;

    return transactionsToCheck
        .where((tx) =>
            !tx.isPaid &&
            tx.transactionType == LndHubTransactionType.userInvoice)
        .length;
  }
}
