// lib/wallet_home.dart
import 'package:flutter/material.dart';
import 'package:volt_ui/pages/wallet/wallt/wallet_overview.dart';
import 'package:volt_ui/ui/vui_button.dart';
import 'wallet_transactions.dart';

class WalletMain extends StatelessWidget {
  const WalletMain({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const WalletOverview(balanceSats: 123456), // replace with real value
          const SizedBox(height: 20),
          _buildActionButtons(),
          const SizedBox(height: 20),
          const WalletTransactions(),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        VUIButton(icon: Icons.send, label: 'Send', onPressed: () {}),
        VUIButton(icon: Icons.download, label: 'Receive', onPressed: () {}),
        VUIButton(icon: Icons.qr_code_scanner, label: 'Scan', onPressed: () {}),
      ],
    );
  }
}
