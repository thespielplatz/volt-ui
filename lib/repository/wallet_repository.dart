// lib/repository/wallet_repository.dart
import 'package:volt_ui/api/lndhub_api.dart';
import 'package:volt_ui/models/lndhub/lndhub_decoded_invoice.dart';
import 'package:volt_ui/models/lndhub/lndhub_payment_invoice_dto.dart';
import 'package:volt_ui/models/lndhub/lndhub_transaction.dart';
import 'package:volt_ui/models/wallets/lnd_hub_wallet.dart';
import 'package:volt_ui/models/wallets/wallet.dart';

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

  Future<LndHubPaymentInvoiceDto> payInvoice(String bolt11) async {
    if (_api != null) {
      return await _api!.payInvoice(bolt11);
    }

    throw UnimplementedError('payInvoice not implemented for ${wallet.type}');
  }

  Future<LndHubDecodedInvoice> decodeInvoice(String bolt11) async {
    if (_api != null) {
      return await _api!.decodeInvoice(bolt11);
    }

    throw UnimplementedError(
        'decodeInvoice not implemented for ${wallet.type}');
  }

  Future<bool> checkRoute(String bolt11) async {
    if (_api != null) {
      return await _api!.checkRoute(bolt11);
    }

    throw UnimplementedError('checkRoute not implemented for ${wallet.type}');
  }

  LndHubTransaction? getTransactionByPaymentRequest(String paymentRequest) {
    return allTransactions.firstWhere(
      (transaction) => transaction.paymentRequest == paymentRequest,
    );
  }
}
