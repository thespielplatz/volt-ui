import 'package:volt_ui/models/wallets/wallet.dart';

class LnBitsWallet extends Wallet {
  final String adminKey;

  LnBitsWallet({
    required super.id,
    required super.label,
    required super.url,
    required super.cachedBalanceSats,
    required super.cachedTransactions,
    required this.adminKey,
  });

  @override
  String get type => 'LnBits';

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();

    json.addAll({
      'adminKey': adminKey,
    });

    return json;
  }

  factory LnBitsWallet.fromJson(Map<String, dynamic> json) {
    final base = Wallet.parseBaseFields(json);

    return LnBitsWallet(
      id: base.id,
      label: base.label,
      url: base.url,
      cachedBalanceSats: base.cachedBalanceSats,
      cachedTransactions: base.cachedTransactions,
      adminKey: json['adminKey'],
    );
  }
}
