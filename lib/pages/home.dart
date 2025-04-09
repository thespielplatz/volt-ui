import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:volt_ui/pages/wallet/create/create_wallet.dart';
import 'package:volt_ui/pages/wallet/wallt/wallet_main.dart';
import 'package:volt_ui/services/storage_provide.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isConfigured = false;

  @override
  void initState() {
    super.initState();
    _checkWallets();
  }

  Future<void> _checkWallets() async {
    final storage = Provider.of<StorageProvider>(context, listen: false);
    if (storage.hasWallets) {
      setState(() {
        isConfigured = true;
      });
    }
  }

  Future<void> _setupWalletFinished() async {
    _checkWallets();
  }

  Future<void> _deleteWallets() async {
    final storage = Provider.of<StorageProvider>(context, listen: false);
    for (var w in List.from(storage.wallets)) {
      await storage.removeWallet(w.id);
    }

    setState(() {
      isConfigured = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1B34),
      body: isConfigured
          ? WalletMain(
              onDelete: _deleteWallets,
            )
          : CreateWallet(
              onFinished: _setupWalletFinished,
            ),
    );
  }
}
