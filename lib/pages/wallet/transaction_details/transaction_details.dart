import 'package:flutter/material.dart';
import 'package:volt_ui/models/lndhub/lndhub_transaction.dart';
import 'package:volt_ui/pages/wallet/transaction_details/get_formatted_sats.dart';
import 'package:volt_ui/pages/wallet/transaction_details/get_transaction_icon.dart';
import 'package:volt_ui/pages/wallet/transaction_details/wrap_icon.dart';
import 'package:volt_ui/ui/app_colors.dart';
import 'package:volt_ui/utils/vui_format_date.dart';

class TransactionDetails extends StatelessWidget {
  final LndHubTransaction transaction;

  const TransactionDetails({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [..._createTransaction(context)],
        ),
      ),
    );
  }

  List<Widget> _createTransaction(BuildContext context) {
    Icon icon = getTransactionIcon(transaction, size: 75);
    Widget iconWithBackground =
        wrapIcon(icon, border: 15, background: AppColors.pageDarkBackground);

    // Placeholder content for paid transactions
    return [
      iconWithBackground,
      const SizedBox(height: 25),
      Text(
        getFormattedSatsFromTransaction(transaction),
        style: const TextStyle(
            color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 12),
      if (transaction.transactionType == LndHubTransactionType.payment) ...[
        Text(
          'Fee: ${getFormattedSats(transaction.fee.toInt(), addPlusSign: false)}',
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        const SizedBox(height: 16),
      ],
      Text(
        transaction.description ?? '',
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
      const SizedBox(height: 16),
      Text(
        VUIFormatDate(transaction.timestamp),
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
    ];
  }
}
