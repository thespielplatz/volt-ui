// lib/wallet_home.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:volt_ui/models/wallets/wallet.dart';
import 'package:volt_ui/pages/wallet/wallt/wallet_overview.dart';
import 'package:volt_ui/pages/wallet/wallt/wallet_transactions.dart';
import 'package:volt_ui/services/storage_provide.dart';
import 'package:volt_ui/ui/vui_button.dart';

class WalletMain extends StatefulWidget {
  final Wallet wallet;

  const WalletMain({
    super.key,
    required this.wallet,
  });

  @override
  State<WalletMain> createState() => _CreateWalletMain();
}

class _CreateWalletMain extends State<WalletMain> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          WalletOverview(
            balanceSats: 123456, // Replace with real balance if available
            onDelete: _onDelete,
          ),
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

  _onDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Wallet'),
        content: const Text(
            'Are you sure you want to delete this wallet? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final storage = Provider.of<StorageProvider>(context, listen: false);
      await storage.removeWallet(widget.wallet.id);
    }
  }
}
