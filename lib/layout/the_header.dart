import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:volt_ui/models/wallets/wallet.dart';
import 'package:volt_ui/pages/create/create_wallet.dart';
import 'package:volt_ui/services/storage_provide.dart';

class TheHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const TheHeader({super.key, required this.title});

  void _openCreateWallet(BuildContext context) {
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
    return AppBar(
      backgroundColor: const Color(0xFF081428),
      title: Row(
        children: [
          const Icon(
            CupertinoIcons.bolt_fill,
            color: Colors.yellow,
            size: 24,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFFFDF4E9),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () => _openCreateWallet(context),
          icon: const Icon(Icons.add, color: Color(0xFFFDF4E9)),
        ),
      ],
      iconTheme: const IconThemeData(color: Color(0xFFFDF4E9)),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
