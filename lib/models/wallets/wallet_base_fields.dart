import 'package:volt_ui/models/lndhub/lndhub_transaction.dart';

class WalletBaseFields {
  final String id;
  final String label;
  final String url;
  final int cachedBalanceSats;
  final List<LndHubTransaction> cachedTransactions;

  WalletBaseFields({
    required this.id,
    required this.label,
    required this.url,
    required this.cachedBalanceSats,
    required this.cachedTransactions,
  });
}
