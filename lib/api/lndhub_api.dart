import 'dart:convert';
import 'package:http/http.dart' as http;

class LndHubApi {
  final String url;
  final String username;
  final String password;

  String? _accessToken;
  String? _refreshToken;

  bool get isAuthenticated => _accessToken != null;

  static testConfig(
      {required String username,
      required String password,
      required String url}) async {
    return await http.post(
      Uri.parse('$url/auth'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'login': username,
        'password': password,
      }),
    );
  }

  LndHubApi({
    required this.url,
    required this.username,
    required this.password,
  });

  Future<void> authenticate() async {
    if (isAuthenticated) return;

    final res = await http.post(
      Uri.parse('$url/auth'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'login': username,
        'password': password,
      }),
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      _accessToken = data['access_token'];
      _refreshToken = data['refresh_token'];
    } else {
      throw Exception('LndHub login failed: ${res.body}');
    }
  }

  Future<int> getBalance() async {
    await authenticate();

    final res = await http.get(
      Uri.parse('$url/balance'),
      headers: {
        'Authorization': 'Bearer $_accessToken',
      },
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return data['BTC']['AvailableBalance'] as int;
    } else {
      throw Exception('Balance fetch failed: ${res.body}');
    }
  }

  // Add more methods: getTransactions(), createInvoice(), etc.
}
