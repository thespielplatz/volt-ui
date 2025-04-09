import 'package:flutter/material.dart';
import 'package:volt_ui/models/lndhub/lndhub_transaction.dart';

class WalletTransactions extends StatelessWidget {
  final List<LndHubTransaction> transactions;

  WalletTransactions({super.key, required this.transactions});

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
                      final tx = transactions[index];
                      final isSend = tx.value < 0;
                      final isZero = tx.value == 0;

                      return _buildTransactionTile(
                        type: isZero
                            ? 'pending'
                            : isSend
                                ? 'send'
                                : 'receive',
                        title: tx.description ?? tx.type,
                        date: _formatDate(tx.timestamp),
                        amount: tx.value,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${_twoDigits(date.month)}-${_twoDigits(date.day)}';
  }

  String _twoDigits(int n) => n < 10 ? '0$n' : '$n';

  Widget _buildTransactionTile({
    required String type, // 'send', 'receive', 'pending'
    required String title,
    required String date,
    required int amount,
  }) {
    Icon icon;
    Color amountColor;

    if (type == 'send') {
      icon = const Icon(Icons.north_east, color: Colors.red);
      amountColor = const Color(0xFFFDF4E9);
    } else if (type == 'receive') {
      icon = const Icon(Icons.south_east, color: Colors.green);
      amountColor = Colors.lightGreen;
    } else {
      icon = const Icon(Icons.more_horiz, color: Colors.grey);
      amountColor = const Color(0xFFFDF4E9);
    }

    return ListTile(
      leading: _createIcon(icon),
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

  Widget _createIcon(Icon icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: const BoxDecoration(
        color: Color(0xFF081428),
        shape: BoxShape.circle,
      ),
      child: icon,
    );
  }
}
