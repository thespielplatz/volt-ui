import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:volt_ui/models/wallets/wallet.dart';
import 'package:volt_ui/pages/create/create_wallet.dart';
import 'package:volt_ui/services/storage_provide.dart';
import 'package:volt_ui/ui/vui_button.dart';

class NoWallets extends StatelessWidget {
  const NoWallets({super.key});

  void _onCreateWallet(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => Scaffold(
          backgroundColor: const Color(0xFF0F1B34),
          body: Padding(
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
            child: CreateWallet(
              onFinished: (Wallet wallet) async {
                final storage =
                    Provider.of<StorageProvider>(context, listen: false);
                Navigator.of(context).pop();
                await storage.addWallet(wallet);
              },
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'No wallets yet',
            style: TextStyle(color: Colors.white70, fontSize: 18),
          ),
          const SizedBox(height: 24),
          VUIButton(
            icon: Icons.add,
            isEnabled: true,
            onPressed: () => _onCreateWallet(context),
            label: 'Add Wallet',
          ),
        ],
      ),
    );
  }
}
