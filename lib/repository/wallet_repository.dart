// lib/repository/wallet_repository.dart
import 'package:volt_ui/api/lndhub_api.dart';
import 'package:volt_ui/models/wallets/lnd_hub_wallet.dart';
import 'package:volt_ui/models/wallets/wallet.dart';

class WalletRepository {
  final Wallet wallet;

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

  // Future<List<Transaction>> getTransactions() { ... }
}
