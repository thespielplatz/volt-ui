import 'package:flutter/material.dart';
import 'package:volt_ui/pages/wallet/create_wallet.dart';
import 'package:volt_ui/pages/wallet/wallet_home.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _secureStorage = const FlutterSecureStorage();
  static const _configKey = 'wallet_config';

  bool isConfigured = false;
  final TextEditingController _configController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkIfConfigured();
  }

  Future<void> _checkIfConfigured() async {
    var config = await _getWalletConfig();
    if (config != null && config.isNotEmpty) {
      setState(() {
        isConfigured = true;
      });
    }
  }

  _setupWallet() async {
    final configText = _configController.text.trim();
    if (configText.isNotEmpty) {
      await _setWalletConfig(configText);
      setState(() {
        isConfigured = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1B34),
      body: isConfigured
          ? const WalletHome()
          : CreateWallet(
              controller: _configController,
              onSetup: _setupWallet,
            ),
    );
  }

  Future<String?> _getWalletConfig() async {
    return await _secureStorage.read(key: _configKey);
  }

  _setWalletConfig(String walletConfig) async {
    await _secureStorage.write(key: _configKey, value: walletConfig);
  }
}
