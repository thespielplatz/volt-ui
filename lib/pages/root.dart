import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:volt_ui/pages/no_wallets.dart';
import 'package:volt_ui/pages/wallet/wallet_main.dart';
import 'package:volt_ui/services/storage_provider.dart';
import 'package:volt_ui/ui/app_colors.dart';

class RootPage extends StatefulWidget {
  const RootPage({super.key});

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  late final PageController _pageController;
  int _currentPage = 0;

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
      backgroundColor: AppColors.pageBackground,
      body: Consumer<StorageProvider>(
        builder: (context, storage, _) {
          final wallets = storage.wallets;

          if (wallets.isEmpty) {
            return const NoWallets();
          }

          final canSwipeLeft = _currentPage > 0;
          final canSwipeRight = _currentPage < wallets.length - 1;

          return Stack(
            children: [
              PageView.builder(
                controller: _pageController,
                itemCount: wallets.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  return WalletMain(
                    wallet: wallets[index],
                    isActive: _currentPage == index,
                  );
                },
              ),
              if (canSwipeLeft)
                const Positioned(
                  left: 8,
                  top: 56,
                  child: Icon(Icons.arrow_back_ios,
                      color: Colors.white38, size: 20),
                ),
              if (canSwipeRight)
                const Positioned(
                  right: 8,
                  top: 56,
                  child: Icon(Icons.arrow_forward_ios,
                      color: Colors.white38, size: 20),
                ),
            ],
          );
        },
      ),
    );
  }
}
