import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:volt_ui/layout/sats_input_formatter.dart';
import 'package:volt_ui/layout/show_error.dart';
import 'package:volt_ui/repository/wallet_repository.dart';
import 'package:volt_ui/ui/app_colors.dart';
import 'package:volt_ui/ui/vui_button.dart';

class CreateInvoice extends StatefulWidget {
  final void Function(String invoice) onSuccess;
  final WalletRepository repository;

  const CreateInvoice(
      {super.key, required this.onSuccess, required this.repository});

  @override
  State<CreateInvoice> createState() => _CreateInvoiceState();
}

class _CreateInvoiceState extends State<CreateInvoice> {
  final _satsController = TextEditingController();
  final _descController = TextEditingController();
  bool _isValidAmount = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _satsController.addListener(_validateAmount);
  }

  @override
  void dispose() {
    _satsController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _validateAmount() {
    final sats = _getSats();
    final isValid = sats > 0;
    if (isValid != _isValidAmount) {
      setState(() {
        _isValidAmount = isValid;
      });
    }
  }

  void _onCreateInvoice() async {
    setState(() {
      _isLoading = true;
    });
    final sats = _getSats();
    final description = _descController.text.trim();
    try {
      var invoice = await widget.repository.createInvoice(
        amountSat: sats,
        memo: description,
      );
      widget.onSuccess(invoice);
    } catch (error) {
      // ignore: use_build_context_synchronously
      showError(context: context, text: 'Error creating invoice: $error');
    } finally {
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
            _createSatsRow(),
            const SizedBox(height: 16),
            TextField(
              controller: _descController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Description',
                labelStyle: const TextStyle(color: Colors.white70),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                focusedBorder: AppColors.inputFocusedBorder,
              ),
            ),
            const SizedBox(height: 24),
            VUIButton(
              icon: Icons.bolt,
              label: 'Create Invoice',
              onPressed: _onCreateInvoice,
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
}
