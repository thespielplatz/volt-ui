import 'dart:core';
import 'package:http/http.dart' as http;

enum ConfigType {
  lndHub,
}

class ConfigEvaluationResult {
  final ConfigType? configType;
  final String? message;

  ConfigEvaluationResult({this.configType, this.message});
}

Future<ConfigEvaluationResult> evaluateConfig(String config) async {
  final uriPattern = RegExp(r'^lndhub://([^:]+):([^@]+)@(.+)$');

  final match = uriPattern.firstMatch(config.trim());

  if (match != null) {
    // ignore: unused_local_variable
    final username = match.group(1) ?? '';
    // ignore: unused_local_variable
    final password = match.group(2) ?? '';
    final url = match.group(3) ?? '';

    // Further validation: Check URL format
    final isValidUrl = Uri.tryParse('https://$url')?.hasAbsolutePath ?? false;

    if (!isValidUrl) {
      throw Exception('lndhub has invalid URL in config');
    }

    final success = await validateLndHubCredentials(
      username: username,
      password: password,
      url: url,
    );

    if (!success) {
      throw Exception('Auth failed at $url');
    }

    return ConfigEvaluationResult(
      configType: ConfigType.lndHub,
      message: 'Connection successful',
    );
  }

  throw Exception(
      'Invalid config format. Expected: lndhub://<user>:<pass>@<url>');
}

Future<bool> validateLndHubCredentials({
  required String username,
  required String password,
  required String url,
}) async {
  print('Testing LNDHub credentials: $username:xxx@$url');
  final apiUrl = Uri.tryParse('https://$url');
  if (apiUrl == null || !apiUrl.hasAbsolutePath) {
    throw Exception('Invalid URL in config');
  }

  final authUrl = Uri.parse('${apiUrl.origin}/auth');

  try {
    final response = await http.post(
      authUrl,
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'login': username,
        'password': password,
      },
    );

    if (response.statusCode == 200) {
      print('✅ Auth response: ${response.body}');
      return true;
    } else {
      print('❌ Auth failed: ${response.body}');
      return false;
    }
  } catch (e) {
    print('❌ Error during auth: $e');
    return false;
  }
}
