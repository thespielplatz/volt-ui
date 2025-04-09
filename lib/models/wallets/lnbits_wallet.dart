import 'package:volt_ui/models/wallets/wallet.dart';

class LnBitsWallet extends Wallet {
  final String adminKey;

  LnBitsWallet({
    required super.id,
    required super.label,
    required this.adminKey,
  });

  @override
  String get type => 'LnBits';

  @override
  Map<String, dynamic> toJson() => {
        'type': type,
        'id': id,
        'label': label,
        'adminKey': adminKey,
      };

  factory LnBitsWallet.fromJson(Map<String, dynamic> json) => LnBitsWallet(
        id: json['id'],
        label: json['label'],
        adminKey: json['adminKey'],
      );
}
