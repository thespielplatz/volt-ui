import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:volt_ui/ui/vui_button.dart';

class CreateInvoice extends StatefulWidget {
  final void Function(int sats, String description) onCreate;

  const CreateInvoice({super.key, required this.onCreate});

  @override
  State<CreateInvoice> createState() => _CreateInvoiceState();
}

class _CreateInvoiceState extends State<CreateInvoice> {
  final _satsController = TextEditingController();
  final _descController = TextEditingController();

  @override
  void dispose() {
    _satsController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _handleCreate() {
    final sats = int.tryParse(_satsController.text) ?? 0;
    final description = _descController.text.trim();
    if (sats > 0) {
      widget.onCreate(sats, description);
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
            // Sats input
            TextField(
              controller: _satsController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Amount',
                labelStyle: TextStyle(color: Colors.white70),
                suffixText: 'sats',
                suffixStyle: TextStyle(color: Colors.white),
                enabledBorder: whiteBorder,
                focusedBorder: whiteBorder,
              ),
            ),
            const SizedBox(height: 16),

            // Description input
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

            // Create Invoice button
            VUIButton(
              icon: Icons.bolt,
              label: 'Create Invoice',
              onPressed: _handleCreate,
            ),
          ],
        ),
      ),
    );
  }
}
