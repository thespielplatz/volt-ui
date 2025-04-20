import 'package:volt_ui/models/lndhub/lndhub_transaction.dart';
import 'package:volt_ui/models/wallets/lnbits_wallet.dart';
import 'package:volt_ui/models/wallets/lndhub_wallet.dart';
import 'package:volt_ui/models/wallets/wallet_base_fields.dart';

abstract class Wallet {
  final String id;
  String label;
  final String url;
  int cachedBalanceSats;
  List<LndHubTransaction> cachedTransactions;

  Wallet({
    required this.id,
    required this.label,
    required this.url,
    required this.cachedBalanceSats,
    required this.cachedTransactions,
  });

  String get type;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'url': url,
      'type': type,
      'cachedBalanceSats': cachedBalanceSats,
      'cachedTransactions': cachedTransactions.map((e) => e.toJson()).toList(),
    };
  }

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

  static WalletBaseFields parseBaseFields(Map<String, dynamic> json) {
    return WalletBaseFields(
      id: json['id'],
      label: json['label'],
      url: json['url'],
      cachedBalanceSats: json['cachedBalanceSats'] ?? 0,
      cachedTransactions: parseCachedTransaction(json),
    );
  }

  static parseCachedTransaction(Map<String, dynamic> json) {
    final cachedTxRaw = json['cachedTransactions'];

    List<LndHubTransaction> parsedTransactions = [];

    if (cachedTxRaw is List) {
      try {
        parsedTransactions = cachedTxRaw
            .whereType<Map<String, dynamic>>() // ensure every item is a Map
            .map(LndHubTransaction.fromJson)
            .toList();
      } catch (e) {
        return [];
      }
    }
    return parsedTransactions;
  }
}
