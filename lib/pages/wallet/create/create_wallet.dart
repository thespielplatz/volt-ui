import 'package:flutter/material.dart';
import 'package:volt_ui/pages/wallet/create/lib/evaluate_config.dart';
import 'package:volt_ui/ui/vui_button.dart';

enum ConfigStatus {
  initial,
  evaluating,
  valid,
  invalid,
}

class CreateWallet extends StatefulWidget {
  final void Function(String) onFinished;

  CreateWallet({
    super.key,
    required this.onFinished,
  });

  @override
  State<CreateWallet> createState() => _CreateWalletState();
}

class _CreateWalletState extends State<CreateWallet> {
  ConfigStatus _status = ConfigStatus.initial;
  String _statusMessage = 'Paste your config';
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _controller.addListener(_onConfigChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onConfigChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onConfigChanged() {
    final config = _controller.text.trim();
    if (config.isEmpty) {
      setState(() {
        _status = ConfigStatus.initial;
        _statusMessage = 'Paste your config';
      });
      return;
    }

    setState(() {
      _status = ConfigStatus.evaluating;
      _statusMessage = 'Evaluating config...';
    });

    evaluateConfig(config).then((result) {
      setState(() {
        _status = ConfigStatus.valid;
        _statusMessage = result.message ?? 'OK';
      });
    }).onError((error, stackTrace) {
      setState(() {
        _status = ConfigStatus.invalid;
        _statusMessage = error.toString();
      });
    });
  }

  Widget _buildStatusIndicator() {
    Color color;
    Widget? icon;

    switch (_status) {
      case ConfigStatus.initial:
        color = Colors.grey;
        icon = const Icon(Icons.circle, size: 12, color: Colors.grey);
        break;
      case ConfigStatus.evaluating:
        color = Colors.blue;
        icon = const SizedBox(
          width: 12,
          height: 12,
          child: CircularProgressIndicator(strokeWidth: 2),
        );
        break;
      case ConfigStatus.valid:
        color = Colors.green;
        icon = const Icon(Icons.circle, size: 12, color: Colors.green);
        break;
      case ConfigStatus.invalid:
        color = Colors.red;
        icon = const Icon(Icons.circle, size: 12, color: Colors.red);
        break;
    }

    return Row(
      children: [
        icon,
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            'Status: $_statusMessage',
            style: TextStyle(color: color),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isButtonEnabled = _status == ConfigStatus.valid;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Enter your lndhub sconnection link',
            style: TextStyle(
              color: Color(0xFFFDF4E9),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            maxLines: 6,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white12,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              hintText: 'Paste your config here...',
              hintStyle: const TextStyle(color: Colors.white54),
            ),
          ),
          const SizedBox(height: 12),
          _buildStatusIndicator(),
          const SizedBox(height: 12),
          VUIButton(
            icon: Icons.check,
            isEnabled: isButtonEnabled,
            onPressed: _onFinished,
            label: 'Import',
          ),
          const SizedBox(height: 20),
          const Text(
            'This configuration connects your app to your lightning account with the lndhub protocol. This could be a lndhub.io or lnbits instance.',
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  _onFinished() {
    final configText = _controller.text.trim();
    widget.onFinished(configText);
  }
}
