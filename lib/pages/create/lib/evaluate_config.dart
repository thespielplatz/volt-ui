import 'dart:core';
import 'package:volt_ui/api/lndhub_api.dart';
import 'package:volt_ui/models/wallets/lnd_hub_wallet.dart';
import 'package:volt_ui/models/wallets/wallet.dart';
import 'package:nanoid/nanoid.dart';

Future<Wallet?> evaluateConfig(String config) async {
  final uriPattern = RegExp(r'^lndhub://([^:]+):([^@]+)@(.+)$');

  final match = uriPattern.firstMatch(config.trim());

  if (match != null) {
    final username = match.group(1) ?? '';
    final password = match.group(2) ?? '';
    final url = match.group(3) ?? '';

    final apiUrl = Uri.tryParse(url);
    if (apiUrl == null || !apiUrl.hasAbsolutePath) {
      throw Exception('lndhub: Invalid URL');
    }

    final cleanedUrl = Uri.tryParse(url.replaceAll(RegExp(r'\/+$'), ''));

    await validateLndHubCredentials(
      username: username,
      password: password,
      url: cleanedUrl.toString(),
    );

    final id = nanoid(10);
    return LndHubWallet(
        id: id,
        label: "LndHub",
        url: cleanedUrl.toString(),
        username: username,
        password: password);
  }

  throw Exception('Invalid config format.');
}

Future<void> validateLndHubCredentials({
  required String username,
  required String password,
  required String url,
}) async {
  final response = await LndHubApi.testConfig(
      username: username, password: password, url: url);

  if (response.statusCode == 200) {
    return;
  }
  if (response.body.toLowerCase().contains('not found')) {
    throw Exception('User not found');
  }
  throw Exception('❌ Auth failed: ${response.body}');
}
