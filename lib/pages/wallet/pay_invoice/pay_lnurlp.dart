import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:tsp_dart_lnurl/dart_lnurl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:volt_ui/layout/sats_input_formatter.dart';
import 'package:volt_ui/layout/show_error.dart';
import 'package:volt_ui/models/lndhub/lndhub_payment_invoice_dto.dart';
import 'package:volt_ui/models/lnurl/lnurlp_callback_response_dto.dart';
import 'package:volt_ui/repository/wallet_repository.dart';
import 'package:volt_ui/ui/app_colors.dart';
import 'package:volt_ui/ui/vui_button.dart';

class PayLnurlp extends StatefulWidget {
  final void Function(LndHubPaymentInvoiceDto dto) onSuccess;
  final WalletRepository repository;
  final LNURLPayParams lnurlPayParams;

  const PayLnurlp(
      {super.key,
      required this.onSuccess,
      required this.repository,
      required this.lnurlPayParams});

  @override
  State<PayLnurlp> createState() => _PayLnurlpState();
}

class _PayLnurlpState extends State<PayLnurlp> {
  final _satsController = TextEditingController();
  final _descController = TextEditingController();
  bool _isValidAmount = false;
  bool _isLoading = false;
  late int minSats;
  late int maxSats;
  late int commentsLength;

  @override
  void initState() {
    super.initState();
    minSats = (widget.lnurlPayParams.minSendable / 1000).floor();
    maxSats = (widget.lnurlPayParams.maxSendable / 1000).floor();
    commentsLength = widget.lnurlPayParams.commentAllowed ?? 0;
    _satsController.addListener(_validateAmount);
    if (minSats == maxSats) {
      _satsController.text = minSats.toString();
      _isValidAmount = true;
    } else {
      _satsController.text = '';
      _isValidAmount = false;
    }
  }

  @override
  void dispose() {
    _satsController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _validateAmount() {
    final sats = _getSats();
    final isValid = sats >= minSats && sats <= maxSats;
    setState(() {
      _isValidAmount = isValid;
    });
  }

  void _onPayInvoice() async {
    setState(() {
      _isLoading = true;
    });
    final sats = _getSats();
    final description = _descController.text.trim();
    try {
      LnurlpCallbackResponseDto response = await _callLNURLPCallback(
          sats * 1000, commentsLength > 0 ? description : null);
      LndHubPaymentInvoiceDto invoice =
          await widget.repository.payInvoice(response.pr);
      widget.onSuccess(invoice);
    } catch (error) {
      // ignore: use_build_context_synchronously
      showError(context: context, text: 'Error creating invoice: $error');
      setState(() {
        _isLoading = false;
      });
    }
  }

  int _getSats() {
    final digits = _satsController.text.replaceAll(RegExp(r'\D'), '');
    return int.tryParse(digits) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_extractTextPlain() ?? '',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _createSatsRow(),
            _createMinMaxSatsRow(),
            if (commentsLength > 0) _createCommentsRow(),
            const SizedBox(height: 24),
            VUIButton(
              icon: Icons.bolt,
              label: 'Pay Invoice',
              onPressed: _onPayInvoice,
              isEnabled: _isValidAmount,
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }

  _createSatsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        IntrinsicWidth(
          child: TextField(
            enabled: minSats != maxSats,
            controller: _satsController,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              SatsInputFormatter(),
            ],
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
            decoration: const InputDecoration(
              hintText: '0',
              hintStyle: TextStyle(
                color: Colors.white54,
                fontSize: 28,
              ),
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
        const SizedBox(width: 6),
        const Text(
          'sats',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _createMinMaxSatsRow() {
    final minSats = (widget.lnurlPayParams.minSendable / 1000).floor();
    final maxSats = (widget.lnurlPayParams.maxSendable / 1000).floor();

    if (minSats == maxSats) {
      return const Text(
        'Fixed amount',
        style: TextStyle(color: Colors.white54),
        textAlign: TextAlign.center,
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Min: $minSats',
          style: const TextStyle(color: Colors.white54),
        ),
        const SizedBox(width: 16),
        Text(
          'Max: $maxSats',
          style: const TextStyle(color: Colors.white54),
        ),
      ],
    );
  }

  String? _extractTextPlain() {
    try {
      final List<dynamic> metadata = jsonDecode(widget.lnurlPayParams.metadata);

      for (var item in metadata) {
        if (item is List && item.isNotEmpty && item[0] == "text/plain") {
          return item[1] as String;
        }
      }
    } catch (e) {}
    return null;
  }

  _createCommentsRow() {
    return Column(children: [
      const SizedBox(height: 16),
      TextField(
        controller: _descController,
        maxLength: commentsLength,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: 'Comment',
          labelStyle: const TextStyle(color: Colors.white70),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          focusedBorder: AppColors.inputFocusedBorder,
        ),
      ),
      Text(
        '$commentsLength characters allowed',
        style: const TextStyle(color: Colors.white54),
      ),
    ]);
  }

  Future<LnurlpCallbackResponseDto> _callLNURLPCallback(
      int millisats, String? comment) async {
    String callback = widget.lnurlPayParams.callback;
    final separator = callback.contains('?') ? '&' : '?';
    final commentParameter = comment != null ? '&comment=$comment' : '';
    final url = '$callback${separator}amount=$millisats$commentParameter';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch invoice: ${response.statusCode}');
    }

    final Map<String, dynamic> json = jsonDecode(response.body);

    // Optional: check for LNURL error response
    if (json['status'] == 'ERROR') {
      throw Exception('LNURLP Error: ${json['reason'] ?? 'Unknown error'}');
    }

    return LnurlpCallbackResponseDto.fromJson(json);
  }
}
