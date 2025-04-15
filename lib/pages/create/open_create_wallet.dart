import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:volt_ui/layout/open_fullscreen.dart';
import 'package:volt_ui/models/wallets/wallet.dart';
import 'package:volt_ui/pages/create/create_wallet.dart';
import 'package:volt_ui/services/storage_provider.dart';

void openCreateWallet(BuildContext context) {
  openFullscreen(
      context: context,
      title: 'Add Wallet',
      body: CreateWallet(onFinished: (Wallet wallet) async {
        final storage = Provider.of<StorageProvider>(context, listen: false);
        Navigator.of(context).pop();
        await storage.addWallet(wallet);
      }));
}
