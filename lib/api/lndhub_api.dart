import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:volt_ui/models/lndhub/lndhub_transaction.dart';

class LndHubApi {
  final String url;
  final String username;
  final String password;

  String? _accessToken;
  String? _refreshToken;

  bool get isAuthenticated => _accessToken != null;

  LndHubApi({
    required this.url,
    required this.username,
    required this.password,
  });

  /// Quick config test
  static Future<http.Response> testConfig({
    required String username,
    required String password,
    required String url,
  }) {
    return http.post(
      Uri.parse('$url/auth'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'login': username,
        'password': password,
      }),
    );
  }

  /// Authenticate and store tokens
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

  /// Refresh the access token
  Future<void> refreshToken() async {
    if (_refreshToken == null) {
      throw Exception('No refresh token available.');
    }

    final res = await http.post(
      Uri.parse('$url/refresh'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refresh_token': _refreshToken}),
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      _accessToken = data['access_token'];
    } else {
      throw Exception('Token refresh failed: ${res.body}');
    }
  }

  /// Get wallet balance
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

  /// Create a new Lightning invoice
  Future<String> createInvoice({
    required int amountSat,
    String? memo,
  }) async {
    await authenticate();

    final res = await http.post(
      Uri.parse('$url/addinvoice'),
      headers: {
        'Authorization': 'Bearer $_accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'amt': amountSat,
        if (memo != null) 'memo': memo,
      }),
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return data['payment_request'];
    } else {
      throw Exception('Invoice creation failed: ${res.body}');
    }
  }

  /// Pay a Lightning invoice
  Future<Map<String, dynamic>> payInvoice(String bolt11) async {
    await authenticate();

    final res = await http.post(
      Uri.parse('$url/payinvoice'),
      headers: {
        'Authorization': 'Bearer $_accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'invoice': bolt11}),
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception('Invoice payment failed: ${res.body}');
    }
  }

  /// Decode a Lightning invoice
  Future<Map<String, dynamic>> decodeInvoice(String bolt11) async {
    await authenticate();

    final res = await http.post(
      Uri.parse('$url/decodeinvoice'),
      headers: {
        'Authorization': 'Bearer $_accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'invoice': bolt11}),
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception('Invoice decode failed: ${res.body}');
    }
  }

  Future<List<LndHubTransaction>> getTransactions() async {
    await authenticate();

    final res = await http.get(
      Uri.parse('$url/gettxs'),
      headers: {
        'Authorization': 'Bearer $_accessToken',
      },
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);

      if (data is List) {
        return data.map((tx) {
          return LndHubTransaction.fromPaymentJson(tx);
        }).toList();
      }

      throw Exception('Unexpected response format: $data');
    } else {
      throw Exception('Fetching transactions failed: ${res.body}');
    }
  }

  Future<List<LndHubTransaction>> getUserInvoices() async {
    await authenticate();

    final res = await http.get(
      Uri.parse('$url/getuserinvoices'),
      headers: {
        'Authorization': 'Bearer $_accessToken',
      },
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);

      if (data is List) {
        return data
            .map((invoice) => LndHubTransaction.fromUserInvoiceJson(invoice))
            .toList();
      }

      throw Exception('Unexpected response format: $data');
    } else {
      throw Exception('Fetching user invoices failed: ${res.body}');
    }
  }
}
