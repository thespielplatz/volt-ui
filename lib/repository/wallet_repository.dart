// lib/repository/wallet_repository.dart
import 'package:volt_ui/api/lndhub_api.dart';
import 'package:volt_ui/models/lndhub/lndhub_transaction.dart';
import 'package:volt_ui/models/wallets/lnd_hub_wallet.dart';
import 'package:volt_ui/models/wallets/wallet.dart';
// import 'package:volt_ui/models/transaction.dart'; // Uncomment if you have a transaction model

class WalletRepository {
  final Wallet wallet;
  List<LndHubTransaction> allTransactions = [];

  LndHubApi? _api;

  WalletRepository(this.wallet) {
    if (wallet is LndHubWallet) {
      var lndHubWallet = wallet as LndHubWallet;
      _api = LndHubApi(
        url: lndHubWallet.url,
        username: lndHubWallet.username,
        password: lndHubWallet.password,
      );
    }
  }

  Future<int> getBalance() async {
    if (_api != null) {
      return await _api!.getBalance();
    }

    throw UnimplementedError('getBalance not implemented for ${wallet.type}');
  }

  Future<List<LndHubTransaction>> getTransactions() async {
    if (_api != null) {
      final transactions = await _api!.getTransactions();
      final invoices = await _api!.getUserInvoices();
      allTransactions = [...transactions, ...invoices];
      allTransactions.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return allTransactions;
    }
    throw UnimplementedError(
        'getTransactions not implemented for ${wallet.type}');
  }

  Future<String> createInvoice({
    required int amountSat,
    String? memo,
  }) async {
    if (_api != null) {
      return await _api!.createInvoice(amountSat: amountSat, memo: memo);
    }

    throw UnimplementedError(
        'createInvoice not implemented for ${wallet.type}');
  }

  Future<Map<String, dynamic>> payInvoice(String bolt11) async {
    if (_api != null) {
      return await _api!.payInvoice(bolt11);
    }

    throw UnimplementedError('payInvoice not implemented for ${wallet.type}');
  }

  Future<Map<String, dynamic>> decodeInvoice(String bolt11) async {
    if (_api != null) {
      return await _api!.decodeInvoice(bolt11);
    }

    throw UnimplementedError(
        'decodeInvoice not implemented for ${wallet.type}');
  }

  LndHubTransaction? getTransactionByPaymentRequest(String paymentRequest) {
    return allTransactions.firstWhere(
      (transaction) => transaction.paymentRequest == paymentRequest,
    );
  }
}
