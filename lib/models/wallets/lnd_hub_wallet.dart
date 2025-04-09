import 'package:volt_ui/models/wallets/wallet.dart';

class LndHubWallet extends Wallet {
  final String url;
  final String username;
  final String password;

  LndHubWallet({
    required super.id,
    required super.label,
    required this.url,
    required this.username,
    required this.password,
  });

  @override
  String get type => 'LNDHub';

  @override
  Map<String, dynamic> toJson() => {
        'type': type,
        'id': id,
        'label': label,
        'url': url,
        'username': username,
        'password': password,
      };

  factory LndHubWallet.fromJson(Map<String, dynamic> json) => LndHubWallet(
        id: json['id'],
        label: json['label'],
        url: json['url'],
        username: json['username'],
        password: json['password'],
      );
}
