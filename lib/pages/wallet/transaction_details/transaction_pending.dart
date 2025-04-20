import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:volt_ui/models/lndhub/lndhub_transaction.dart';
import 'package:volt_ui/pages/wallet/transaction_details/get_formatted_sats.dart';
import 'package:volt_ui/ui/app_colors.dart';
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
    return [
      _createSatsRow(),
      const SizedBox(height: 16),
      Text(
        transactionNotifier.value.description ?? '',
        style: const TextStyle(color: AppColors.text, fontSize: 16),
      ),
      const SizedBox(height: 16),
      _createQRCode(),
      const SizedBox(height: 24),
      Text(
        paymentRequest,
        style: const TextStyle(color: AppColors.textSecondary),
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

  _createSatsRow() {
    return ValueListenableBuilder<LndHubTransaction>(
      valueListenable: transactionNotifier,
      builder: (context, tx, _) {
        return Row(
          mainAxisSize:
              MainAxisSize.min, // prevent row from stretching full width
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              getFormattedSatsFromTransaction(transactionNotifier.value),
              style: const TextStyle(
                color: AppColors.text,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (!tx.isPaid)
              const SizedBox(width: 8), // spacing between text and spinner
            if (!tx.isPaid)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: AppColors.accentColor,
                ),
              ),
          ],
        );
      },
    );
  }

  _createQRCode() {
    return ValueListenableBuilder<LndHubTransaction>(
      valueListenable: transactionNotifier,
      builder: (context, tx, _) {
        final qrSize = MediaQuery.of(context).size.width - 58;
        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: AppColors.text,
                borderRadius: BorderRadius.circular(12),
              ),
              child: QrImageView(
                data: tx.paymentRequest ?? '',
                version: QrVersions.auto,
                size: qrSize,
                backgroundColor: AppColors.text,
              ),
            ),
            if (tx.isPaid)
              Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color.fromARGB(255, 3, 141, 8),
                ),
                padding: const EdgeInsets.all(12),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 150,
                ),
              ),
          ],
        );
      },
    );
  }
}
