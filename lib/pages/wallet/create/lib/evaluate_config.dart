import 'dart:convert';
import 'dart:core';
import 'package:http/http.dart' as http;
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

    // Further validation: Check URL format
    final isValidUrl = Uri.tryParse('https://$url')?.hasAbsolutePath ?? false;

    if (!isValidUrl) {
      throw Exception('lndhub has invalid URL in config');
    }

    await validateLndHubCredentials(
      username: username,
      password: password,
      url: url,
    );

    final id = nanoid(10);
    return LndHubWallet(
        id: id,
        label: "LndHub",
        url: url,
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
  final apiUrl = Uri.tryParse(url);
  if (apiUrl == null || !apiUrl.hasAbsolutePath) {
    throw Exception('Invalid URL in config');
  }

  final authUrl = Uri.parse('${apiUrl}auth');
  final response = await http.post(
    authUrl,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'login': username,
      'password': password,
    }),
  );

  if (response.statusCode == 200) {
    return;
  }
  if (response.body.toLowerCase().contains('not found')) {
    throw Exception('User not found');
  }
  throw Exception('❌ Auth failed: ${response.body}');
}
