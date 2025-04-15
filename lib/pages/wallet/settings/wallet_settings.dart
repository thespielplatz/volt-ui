import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:volt_ui/models/wallets/wallet.dart';
import 'package:volt_ui/services/storage_provider.dart';
import 'package:volt_ui/ui/vui_button.dart';

class WalletSettings extends StatefulWidget {
  final Wallet wallet;

  const WalletSettings({super.key, required this.wallet});

  @override
  State<WalletSettings> createState() => _WalletSettingsState();
}

class _WalletSettingsState extends State<WalletSettings> {
  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.wallet.label;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
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
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Wallet Name',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: whiteBorder,
                focusedBorder: whiteBorder,
              ),
            ),
            ..._createConfigRow(
              'Type',
              widget.wallet.type,
            ),
            ..._createConfigRow(
              'Connected To',
              widget.wallet.url,
            ),
            const SizedBox(height: 35),
            VUIButton(
              icon: Icons.save,
              label: 'Save',
              onPressed: _onSaveWallet,
            ),
            const SizedBox(height: 24),
            VUIButton(
              icon: Icons.delete,
              label: 'Delete Wallet',
              onPressed: _onDeleteWallet,
              accentColor: const Color.fromARGB(255, 150, 0, 0),
              secondaryColor: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  _onSaveWallet() async {
    final name = _nameController.text.trim();
    if (context.mounted) {
      // ignore: use_build_context_synchronously
      final storage = Provider.of<StorageProvider>(context, listen: false);
      Wallet? wallet = storage.getWalletById(widget.wallet.id);
      if (wallet != null) {
        wallet.label = name;
        await storage.save();
      }
      // ignore: use_build_context_synchronously
      Navigator.of(context).pop();
    }
  }

  Future<void> _onDeleteWallet() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Wallet'),
        content: const Text(
            'Are you sure you want to delete this wallet? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      if (context.mounted) {
        // ignore: use_build_context_synchronously
        final storage = Provider.of<StorageProvider>(context, listen: false);
        await storage.removeWallet(widget.wallet.id);
        // ignore: use_build_context_synchronously
        Navigator.of(context).pop();
      }
    }
  }

  _createConfigRow(String label, String value) {
    return [
      const SizedBox(height: 24),
      Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox(height: 5),
      Text(value)
    ];
  }
}
