import 'package:volt_ui/models/wallets/lnbits_wallet.dart';
import 'package:volt_ui/models/wallets/lnd_hub_wallet.dart';

abstract class Wallet {
  final String id;
  final String label;

  Wallet({required this.id, required this.label});

  String get type;

  Map<String, dynamic> toJson();

  static Wallet fromJson(Map<String, dynamic> json) {
    switch (json['type']) {
      case 'LNDHub':
        return LndHubWallet.fromJson(json);
      case 'LnBits':
        return LnBitsWallet.fromJson(json);
      default:
        throw Exception('Unknown wallet type: ${json['type']}');
    }
  }
}
