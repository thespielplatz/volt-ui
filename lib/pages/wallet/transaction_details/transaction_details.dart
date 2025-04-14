import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:volt_ui/models/lndhub/lndhub_transaction.dart';
import 'package:volt_ui/pages/wallet/transaction_details/get_formatted_sats.dart';
import 'package:volt_ui/pages/wallet/transaction_details/get_transaction_icon.dart';
import 'package:volt_ui/pages/wallet/transaction_details/wrap_icon.dart';
import 'package:volt_ui/ui/vui_button.dart';

class TransactionDetails extends StatelessWidget {
  final LndHubTransaction transaction;

  const TransactionDetails({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final paymentRequest = transaction.paymentRequest ?? '';

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (transaction.isPaid ?? true)
              ..._createTransaction(context)
            else
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
        getFormattedSatsFromTransaction(transaction),
        style: const TextStyle(
            color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 16),
      Text(
        transaction.description ?? '',
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

  List<Widget> _createTransaction(BuildContext context) {
    Icon icon = getTransactionIcon(transaction, size: 75);
    Widget iconWithBackground = wrapIcon(icon, border: 15);

    // Placeholder content for paid transactions
    return [
      iconWithBackground,
      const SizedBox(height: 25),
      Text(
        getFormattedSatsFromTransaction(transaction),
        style: const TextStyle(
            color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 16),
      Text(
        transaction.description ?? '',
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
      const SizedBox(height: 16),
      Text(
        _formatDate(transaction.timestamp),
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
    ];
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${_twoDigits(date.month)}-${_twoDigits(date.day)} ${_twoDigits(date.hour)}:${_twoDigits(date.minute)}';
  }

  String _twoDigits(int n) => n < 10 ? '0$n' : '$n';
}
