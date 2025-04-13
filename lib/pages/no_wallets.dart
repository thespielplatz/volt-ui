import 'package:flutter/material.dart';
import 'package:volt_ui/pages/create/open_create_wallet.dart';
import 'package:volt_ui/ui/vui_button.dart';

class NoWallets extends StatelessWidget {
  const NoWallets({super.key});

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
            onPressed: () => openCreateWallet(context),
            label: 'Add Wallet',
          ),
        ],
      ),
    );
  }
}
