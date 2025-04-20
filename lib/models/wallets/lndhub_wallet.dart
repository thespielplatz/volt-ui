import 'package:volt_ui/models/wallets/wallet.dart';

class LndHubWallet extends Wallet {
  final String username;
  final String password;

  LndHubWallet({
    required super.id,
    required super.label,
    required super.url,
    required super.cachedBalanceSats,
    required super.cachedTransactions,
    required this.username,
    required this.password,
  });

  @override
  String get type => 'LNDHub';

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();

    json.addAll({
      'username': username,
      'password': password,
    });

    return json;
  }

  factory LndHubWallet.fromJson(Map<String, dynamic> json) {
    final base = Wallet.parseBaseFields(json);

    return LndHubWallet(
      id: base.id,
      label: base.label,
      url: base.url,
      cachedBalanceSats: base.cachedBalanceSats,
      cachedTransactions: base.cachedTransactions,
      username: json['username'],
      password: json['password'],
    );
  }
}
