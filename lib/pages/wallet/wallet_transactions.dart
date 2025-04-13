import 'package:flutter/material.dart';
import 'package:volt_ui/models/lndhub/lndhub_transaction.dart';
import 'package:volt_ui/pages/wallet/transaction_details/get_transaction_icon.dart';
import 'package:volt_ui/pages/wallet/transaction_details/wrap_icon.dart';

class WalletTransactions extends StatelessWidget {
  final List<LndHubTransaction> transactions;
  final void Function(LndHubTransaction transaction)? onTransactionTap;

  const WalletTransactions(
      {super.key, required this.transactions, required this.onTransactionTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Transactions',
            style: TextStyle(
              color: Color(0xFFFDF4E9),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: transactions.isEmpty
                ? const Center(
                    child: Text(
                      'No transactions found',
                      style: TextStyle(color: Color(0xFFFDF4E9)),
                    ),
                  )
                : ListView.builder(
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      return _buildTransactionTile(
                          transaction: transactions[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${_twoDigits(date.month)}-${_twoDigits(date.day)} ${_twoDigits(date.hour)}:${_twoDigits(date.minute)}';
  }

  String _twoDigits(int n) => n < 10 ? '0$n' : '$n';

  Widget _buildTransactionTile({
    required LndHubTransaction transaction,
  }) {
    final title = transaction.description ?? transaction.type;
    final date = _formatDate(transaction.timestamp);
    final amount = transaction.value;
    Icon icon = getTransactionIcon(transaction);
    Color amountColor;

    if (transaction.transactionType == LndHubTransactionType.payment) {
      amountColor = const Color(0xFFFDF4E9);
    } else if (transaction.transactionType ==
        LndHubTransactionType.userInvoice) {
      if (transaction.isPaid ?? false) {
        amountColor = Colors.lightGreen;
      } else {
        amountColor = Colors.grey;
      }
    } else {
      amountColor = const Color(0xFFFDF4E9);
    }

    return ListTile(
      onTap: () => onTransactionTap?.call(transaction),
      leading: wrapIcon(icon),
      title: Text(title,
          style: const TextStyle(color: Color(0xFFFEF3EB), fontSize: 14)),
      subtitle: Text(date, style: const TextStyle(color: Color(0xFFAEC2D9))),
      trailing: Text(
        amount >= 0 ? '+$amount sats' : '$amount sats',
        style: TextStyle(
          color: amountColor,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }
}
