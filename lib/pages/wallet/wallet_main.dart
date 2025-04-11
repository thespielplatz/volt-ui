import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:volt_ui/layout/open_fullscreen.dart';
import 'package:volt_ui/models/lndhub/lndhub_transaction.dart';
import 'package:volt_ui/models/wallets/wallet.dart';
import 'package:volt_ui/pages/wallet/create_invoice/create_invoice.dart';
import 'package:volt_ui/pages/wallet/wallet_overview.dart';
import 'package:volt_ui/pages/wallet/wallet_transactions.dart';
import 'package:volt_ui/repository/wallet_repository.dart';
import 'package:volt_ui/services/storage_provide.dart';
import 'package:volt_ui/ui/vui_button.dart';

class WalletMain extends StatefulWidget {
  final Wallet wallet;

  const WalletMain({
    super.key,
    required this.wallet,
  });

  @override
  State<WalletMain> createState() => _WalletMainState();
}

class _WalletMainState extends State<WalletMain> {
  int? _balanceSats;
  final List<LndHubTransaction> _transactions = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _refreshWallet();
  }

  Future<void> _refreshWallet() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final repo = WalletRepository(widget.wallet);
      final balance = await repo.getBalance();
      final transactions = await repo.getTransactions();
      _transactions.clear();
      _transactions.addAll(transactions);

      setState(() {
        _balanceSats = balance;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
              child: WalletOverview(
                balanceSats: _balanceSats ?? 0,
                isLoading: _isLoading,
                onDelete: _onDelete,
                onRefresh: _refreshWallet,
              )),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(
              _error!,
              style: const TextStyle(color: Colors.redAccent),
            ),
          ],
          const SizedBox(height: 20),
          _buildActionButtons(),
          const SizedBox(height: 20),
          WalletTransactions(transactions: _transactions),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        VUIButton(icon: Icons.send, label: 'Send', onPressed: () {}),
        VUIButton(
            icon: Icons.download,
            label: 'Receive',
            onPressed: () {
              openCreateInvoice(context);
            }),
        VUIButton(icon: Icons.qr_code_scanner, label: 'Scan', onPressed: () {}),
      ],
    );
  }

  Future<void> _onDelete() async {
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
      }
    }
  }
}

void openCreateInvoice(BuildContext context) {
  openFullscreen(
      context: context,
      title: 'Receive',
      body: const CreateInvoice(onCreate: onCreate));
}

void onCreate(int sats, String description) {
  // Handle the creation of the invoice here
  // For example, you can show a dialog with the invoice details
  print('Invoice created: $sats sats, description: $description');
}
