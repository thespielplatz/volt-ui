import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:volt_ui/layout/the_header.dart';
import 'package:volt_ui/models/wallets/wallet.dart';
import 'package:volt_ui/pages/root.dart';
import 'package:volt_ui/services/storage_provider.dart';

void main() {
  runWithConfig();
}

void runWithConfig({List<Wallet>? initWallets}) {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) {
          final storage = StorageProvider();
          initWallets?.forEach(storage.addWallet);
          return storage;
        }),
      ],
      child: const VoltUIApp(),
    ),
  );
}

class VoltUIApp extends StatelessWidget {
  const VoltUIApp({super.key});

  @override
  Widget build(BuildContext context) {
    const String appTitle = 'Volt UI';
    return const MaterialApp(
      title: appTitle,
      home: Scaffold(
        appBar: TheHeader(title: appTitle),
        backgroundColor: Color(0xFF0F1B34),
        body: RootPage(),
      ),
    );
  }
}
