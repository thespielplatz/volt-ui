import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:volt_ui/models/lndhub/lndhub_transaction.dart';
import 'package:volt_ui/pages/wallet/transaction_details/get_formatted_sats.dart';
import 'package:volt_ui/ui/vui_button.dart';

class TransactionPending extends StatelessWidget {
  final ValueNotifier<LndHubTransaction> transactionNotifier;

  const TransactionPending({super.key, required this.transactionNotifier});

  @override
  Widget build(BuildContext context) {
    final paymentRequest = transactionNotifier.value.paymentRequest ?? '';

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ..._createInvoicePending(context, paymentRequest),
          ],
        ),
      ),
    );
  }

  List<Widget> _createInvoicePending(
      BuildContext context, String paymentRequest) {
    final qrSize = MediaQuery.of(context).size.width - 58;

    return [
      Text(
        getFormattedSatsFromTransaction(transactionNotifier.value),
        style: const TextStyle(
            color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 16),
      Text(
        transactionNotifier.value.description ?? '',
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
      const SizedBox(height: 16),
      Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: QrImageView(
          data: paymentRequest,
          version: QrVersions.auto,
          size: qrSize,
          backgroundColor: Colors.white,
        ),
      ),
      const SizedBox(height: 24),
      Text(
        paymentRequest,
        style: const TextStyle(color: Colors.grey),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      const SizedBox(height: 16),
      VUIButton(
        icon: Icons.copy,
        label: 'Copy to clipboard',
        onPressed: () {
          Clipboard.setData(ClipboardData(text: paymentRequest));
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Copied to clipboard')),
          );
        },
      ),
    ];
  }
}
