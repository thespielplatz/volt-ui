import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:volt_ui/layout/sats_input_formatter.dart';
import 'package:volt_ui/ui/vui_button.dart';

class CreateInvoice extends StatefulWidget {
  final void Function(int sats, String description) onSuccess;

  const CreateInvoice({super.key, required this.onSuccess});

  @override
  State<CreateInvoice> createState() => _CreateInvoiceState();
}

class _CreateInvoiceState extends State<CreateInvoice> {
  final _satsController = TextEditingController();
  final _descController = TextEditingController();
  bool _isValidAmount = false;

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

  void _handleSuccess() {
    final sats = _getSats();
    final description = _descController.text.trim();
    if (sats > 0) {
      widget.onSuccess(sats, description);
    }
  }

  int _getSats() {
    final digits = _satsController.text.replaceAll(RegExp(r'\D'), '');
    return int.tryParse(digits) ?? 0;
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
            _createSatsRow(),
            const SizedBox(height: 16),
            TextField(
              controller: _descController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Description',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: whiteBorder,
                focusedBorder: whiteBorder,
              ),
            ),
            const SizedBox(height: 24),
            VUIButton(
              icon: Icons.bolt,
              label: 'Create Invoice',
              onPressed: _handleSuccess,
              isEnabled: _isValidAmount,
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
