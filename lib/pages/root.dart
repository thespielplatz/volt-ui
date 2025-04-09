import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:volt_ui/models/wallets/wallet.dart';
import 'package:volt_ui/pages/wallet/create/create_wallet.dart';
import 'package:volt_ui/pages/wallet/wallt/wallet_main.dart';
import 'package:volt_ui/services/storage_provide.dart';

class RootPage extends StatefulWidget {
  const RootPage({super.key});

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1B34),
      body: Consumer<StorageProvider>(
        builder: (context, storage, _) {
          final wallets = storage.wallets;

          final pages = [
            ...wallets.map((wallet) => WalletMain(wallet: wallet)),
            _buildCreateWalletScreen(context),
          ];

          return PageView(
            controller: _pageController,
            children: pages,
          );
        },
      ),
    );
  }

  Widget _buildCreateWalletScreen(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: CreateWallet(
          onFinished: (Wallet wallet) async {
            final storage =
                Provider.of<StorageProvider>(context, listen: false);
            await storage.addWallet(wallet);

            // Jump to the new wallet page
            final walletCount = storage.wallets.length;
            _pageController.animateToPage(
              walletCount - 1, // index of the last wallet page
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
            );
          },
        ),
      ),
    );
  }
}
