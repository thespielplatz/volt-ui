import 'package:flutter/material.dart';
import 'package:volt_ui/models/lndhub/lndhub_transaction.dart';
import 'package:volt_ui/pages/wallet/transaction_details/get_formatted_sats.dart';
import 'package:volt_ui/pages/wallet/transaction_details/get_transaction_icon.dart';
import 'package:volt_ui/pages/wallet/transaction_details/wrap_icon.dart';
import 'package:volt_ui/ui/app_colors.dart';

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
          Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: const Text(
                'Transactions',
                style: TextStyle(
                  color: AppColors.text,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              )),
          const SizedBox(height: 12),
          Expanded(
              child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: AppColors.pageDarkBackground,
            ),
            child: transactions.isEmpty
                ? const Center(
                    child: Text(
                      'No transactions found',
                      style: TextStyle(color: AppColors.text),
                    ),
                  )
                : _buildTransactionList(),
          )),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${_twoDigits(date.month)}-${_twoDigits(date.day)} ${_twoDigits(date.hour)}:${_twoDigits(date.minute)}';
  }

  String _twoDigits(int n) => n < 10 ? '0$n' : '$n';

  Widget _buildTransactionList() {
    return Scrollbar(
      child: ListView.builder(
        itemCount: transactions.length,
        itemBuilder: (context, index) {
          return _buildTransactionTile(transaction: transactions[index]);
        },
      ),
    );
  }

  Widget _buildTransactionTile({
    required LndHubTransaction transaction,
  }) {
    final title = _getTitleFromTransaction(transaction);
    final date = _formatDate(transaction.timestamp);
    Icon icon = getTransactionIcon(transaction);
    Color amountColor;

    if (transaction.transactionType == LndHubTransactionType.payment) {
      amountColor = const Color(0xFFFDF4E9);
    } else if (transaction.transactionType ==
        LndHubTransactionType.userInvoice) {
      if (transaction.isPaid) {
        amountColor = Colors.lightGreen;
      } else {
        amountColor = Colors.grey;
      }
    } else {
      amountColor = AppColors.text;
    }

    return ListTile(
      onTap: () => onTransactionTap?.call(transaction),
      leading: wrapIcon(icon),
      title: Text(title,
          style: const TextStyle(color: AppColors.text, fontSize: 14)),
      subtitle:
          Text(date, style: const TextStyle(color: AppColors.textSecondary)),
      trailing: Text(
        getFormattedSatsFromTransaction(transaction),
        style: TextStyle(
          color: amountColor,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  String _getTitleFromTransaction(
    LndHubTransaction transaction,
  ) {
    if (transaction.description != null &&
        transaction.description!.isNotEmpty) {
      return transaction.description!;
    }

    if (transaction.transactionType == LndHubTransactionType.payment) {
      return 'Payment';
    } else {
      return 'Invoice';
    }
  }
}
