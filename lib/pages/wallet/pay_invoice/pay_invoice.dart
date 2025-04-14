import 'package:flutter/material.dart';
import 'package:volt_ui/layout/show_error.dart';
import 'package:volt_ui/models/lndhub/lndhub_decoded_invoice.dart';
import 'package:volt_ui/pages/wallet/transaction_details/get_formatted_sats.dart';
import 'package:volt_ui/repository/wallet_repository.dart';
import 'package:volt_ui/services/lightning/validate_bolt11.dart';
import 'package:volt_ui/ui/vui_button.dart';

class PayInvoice extends StatefulWidget {
  final void Function() onSuccess;
  final WalletRepository repository;

  const PayInvoice(
      {super.key, required this.onSuccess, required this.repository});

  @override
  State<PayInvoice> createState() => _PayInvoiceState();
}

class _PayInvoiceState extends State<PayInvoice> {
  final _paymentRequestController = TextEditingController();
  LndHubDecodedInvoice? _invoice;

  @override
  void initState() {
    super.initState();
    _paymentRequestController.addListener(_validateInput);
  }

  @override
  void dispose() {
    _paymentRequestController.dispose();
    super.dispose();
  }

  void _handleSuccess() {
    widget.onSuccess();
  }

  void _validateInput() async {
    final paymentRequest = _paymentRequestController.text;
    if (!validateBolt11(paymentRequest)) {
      setState(() {
        _invoice = null;
      });
      return;
    }
    try {
      LndHubDecodedInvoice invoice =
          await widget.repository.decodeInvoice(paymentRequest);
      setState(() {
        _invoice = invoice;
      });
    } catch (e) {
      showError(context: context, text: 'Error decoding invoice: $e');
      setState(() {
        _invoice = null;
      });
      return;
    }
  }

  void _payInvoice() async {
    final paymentRequest = _paymentRequestController.text;
    if (paymentRequest.isEmpty) {
      showError(context: context, text: 'Please enter a payment request');
      return;
    }

    try {
      await widget.repository.payInvoice(paymentRequest);
      _handleSuccess();
    } catch (e) {
      showError(context: context, text: 'Error paying invoice: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    const whiteBorder = OutlineInputBorder(
      borderSide: BorderSide(color: Colors.white),
    );

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              getFormattedSats(_invoice?.numSatoshis.toInt() ?? 0,
                  addPlusSign: false),
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              _invoice?.description ?? '',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _paymentRequestController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Payment Request',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: whiteBorder,
                focusedBorder: whiteBorder,
              ),
            ),
            const SizedBox(height: 24),
            VUIButton(
              icon: Icons.bolt,
              label: 'Pay Invoice',
              onPressed: _payInvoice,
              isEnabled: _invoice != null,
            ),
          ],
        ),
      ),
    );
  }
}
