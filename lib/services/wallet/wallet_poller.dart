import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:volt_ui/models/lndhub/lndhub_transaction.dart';
import 'package:volt_ui/models/wallets/wallet.dart';
import 'package:volt_ui/repository/wallet_repository.dart';
import 'package:volt_ui/services/storage_provider.dart';
import 'package:collection/collection.dart';

class WalletPoller {
  final Wallet wallet;
  final WalletRepository walletRepository;
  ValueNotifier<LndHubTransaction>? transactionNotifier;
  final void Function(String message) onInvoicePaid;
  final VoidCallback onRefreshStarted;
  final VoidCallback onRefreshStopped;
  final void Function(String error) onRefreshErrored;
  final BuildContext context;

  Timer? _autoRefreshTimer;

  WalletPoller({
    required this.wallet,
    required this.walletRepository,
    required this.onRefreshStarted,
    required this.onRefreshStopped,
    required this.onRefreshErrored,
    required this.onInvoicePaid,
    required this.context,
  });

  start() async {
    _autoRefreshTimer?.cancel();
    onRefreshStarted();

    try {
      await _refreshWallet();
    } catch (e) {
      onRefreshErrored(e.toString());
      return;
    }
    int autoRefreshInterval = 2000;

    // Check if a transaction is being watched
    if (transactionNotifier != null) {
      autoRefreshInterval = 250;
      final updatedTransaction = walletRepository.getTransactionByPaymentHash(
        transactionNotifier!.value.paymentHash,
      );

      if (updatedTransaction != null && updatedTransaction.isPaid) {
        transactionNotifier?.value = updatedTransaction;
      }
    }

    if (_transactionsToWatch(itemsToWatch: 5) <= 0) {
      autoRefreshInterval = 10 * 1000;
    }
    onRefreshStopped();

    // ignore: prefer_conditional_assignment
    _autoRefreshTimer = Timer(
      Duration(milliseconds: autoRefreshInterval),
      () {
        start(); // restart the whole logic cleanly
      },
    );
  }

  Future<void> _refreshWallet() async {
    final balance = await walletRepository.getBalance();
    final transactions = await walletRepository.getTransactions();
    wallet.cachedBalanceSats = balance;
    _notifyAboutNewTransactions(transactions);
    _transactions.clear();
    _transactions.addAll(transactions);
    if (context.mounted) {
      final storage = Provider.of<StorageProvider>(context, listen: false);
      await storage.save();
    }
  }

  void _notifyAboutNewTransactions(List<LndHubTransaction> newTransactions) {
    for (final newTx in newTransactions) {
      final existingTx = _transactions
          .firstWhereOrNull((t) => t.paymentHash == newTx.paymentHash);
      if (existingTx == null) {
        continue;
      }

      if (existingTx.transactionType == LndHubTransactionType.userInvoice &&
          !existingTx.isPaid &&
          newTx.isPaid) {
        onInvoicePaid(
          'Payment received: ${newTx.value} sats with: ${newTx.description}',
        );
      }
    }
  }

  void stop() {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = null;
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

  List<LndHubTransaction> get _transactions {
    return wallet.cachedTransactions;
  }
}
