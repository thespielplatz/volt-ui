// lib/services/wallet_storage_provider.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:volt_ui/models/wallets/wallet.dart';

class StorageProvider with ChangeNotifier {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  static const _walletsKey = 'wallets';

  List<Wallet> _wallets = [];
  List<Wallet> get wallets => _wallets;

  StorageProvider() {
    _loadWallets();
  }

  Future<void> _loadWallets() async {
    final data = await _secureStorage.read(key: _walletsKey);
    if (data != null) {
      final decoded = jsonDecode(data) as List;
      _wallets = decoded.map((e) => Wallet.fromJson(e)).toList();
    }
    notifyListeners();
  }

  Future<void> _persistWallets() async {
    final encoded = jsonEncode(_wallets.map((w) => w.toJson()).toList());
    await _secureStorage.write(key: _walletsKey, value: encoded);
  }

  Future<void> addWallet(Wallet wallet) async {
    _wallets.add(wallet);
    await _persistWallets();
    notifyListeners();
  }

  Future<void> removeWallet(String id) async {
    _wallets.removeWhere((w) => w.id == id);
    await _persistWallets();
    notifyListeners();
  }

  Future<void> save() async {
    await _persistWallets();
  }

  Wallet? getWalletById(String id) {
    for (final w in _wallets) {
      if (w.id == id) return w;
    }
    return null;
  }

  bool get hasWallets => _wallets.isNotEmpty;
}
