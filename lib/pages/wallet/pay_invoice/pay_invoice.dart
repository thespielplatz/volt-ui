import 'package:flutter/material.dart';
import 'package:volt_ui/layout/show_error.dart';
import 'package:volt_ui/models/lndhub/lndhub_decoded_invoice.dart';
import 'package:volt_ui/models/lndhub/lndhub_payment_invoice_dto.dart';
import 'package:volt_ui/pages/wallet/transaction_details/get_formatted_sats.dart';
import 'package:volt_ui/repository/wallet_repository.dart';
import 'package:volt_ui/services/lightning/validate_bolt11.dart';
import 'package:volt_ui/ui/app_colors.dart';
import 'package:volt_ui/ui/vui_button.dart';

class PayInvoice extends StatefulWidget {
  final void Function(LndHubPaymentInvoiceDto dto) onSuccess;
  final WalletRepository repository;
  final String? openWithInvoice;
  final LndHubDecodedInvoice? openWithDecodedInvoice;

  const PayInvoice(
      {super.key,
      required this.onSuccess,
      required this.repository,
      this.openWithInvoice,
      this.openWithDecodedInvoice});

  @override
  State<PayInvoice> createState() => _PayInvoiceState();
}

class _PayInvoiceState extends State<PayInvoice> {
  final _paymentRequestController = TextEditingController();
  LndHubDecodedInvoice? _decodedInvoice;
  String? _paymentRequest;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.openWithInvoice != null) {
      _paymentRequestController.text = widget.openWithInvoice!;
    }
    if (widget.openWithDecodedInvoice != null) {
      _decodedInvoice = widget.openWithDecodedInvoice;
    }
    _paymentRequestController.addListener(_validateInput);
  }

  @override
  void dispose() {
    _paymentRequestController.dispose();
    super.dispose();
  }

  void _handleSuccess(LndHubPaymentInvoiceDto dto) {
    widget.onSuccess(dto);
  }

  void _validateInput() async {
    final paymentRequest = _paymentRequestController.text;
    if (!validateBolt11(paymentRequest)) {
      setState(() {
        _decodedInvoice = null;
      });
      return;
    }
    setState(() {
      _isLoading = true;
    });
    try {
      LndHubDecodedInvoice invoice =
          await widget.repository.decodeInvoice(paymentRequest);
      setState(() {
        _decodedInvoice = invoice;
        _paymentRequest = paymentRequest;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _decodedInvoice = null;
      });
      // ignore: use_build_context_synchronously
      showError(context: context, text: 'Error decoding invoice: $e');
      return;
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _payInvoice() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await widget.repository.checkRoute(_paymentRequest!);
    } catch (e) {
      // ignore: use_build_context_synchronously
      showError(context: context, text: 'Error paying invoice: $e');
      setState(() {
        _isLoading = false;
      });
      return;
    }
    try {
      LndHubPaymentInvoiceDto dto =
          await widget.repository.payInvoice(_paymentRequest!);
      _handleSuccess(dto);
    } catch (e) {
      // ignore: use_build_context_synchronously
      showError(context: context, text: 'Error paying invoice: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _decodedInvoice == null
                  ? ''
                  : getFormattedSats(_decodedInvoice?.numSatoshis.toInt() ?? 0,
                      addPlusSign: false),
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              _decodedInvoice?.description ?? '',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _paymentRequestController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Payment Request',
                labelStyle: const TextStyle(color: Colors.white70),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                focusedBorder: AppColors.inputFocusedBorder,
              ),
            ),
            const SizedBox(height: 24),
            VUIButton(
              icon: Icons.bolt,
              label: 'Pay Invoice',
              onPressed: _payInvoice,
              isEnabled: _decodedInvoice != null,
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }
}
