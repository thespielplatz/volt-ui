// lib/wallet_transactions.dart
import 'package:flutter/material.dart';

class WalletTransactions extends StatelessWidget {
  const WalletTransactions({super.key});

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
            child: ListView(
              children: [
                _buildTransactionTile(
                  type: 'receive',
                  title: 'Received from Alice',
                  date: '2025-04-06',
                  amount: 21000,
                ),
                _buildTransactionTile(
                  type: 'send',
                  title: 'Payment to Bob',
                  date: '2025-04-05',
                  amount: -15000,
                ),
                _buildTransactionTile(
                  type: 'pending',
                  title: 'Pending invoice',
                  date: '2025-04-04',
                  amount: 0,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

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
      title: Text(title, style: const TextStyle(color: Color(0xFFFEF3EB))),
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

  _createIcon(Icon icon) {
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
