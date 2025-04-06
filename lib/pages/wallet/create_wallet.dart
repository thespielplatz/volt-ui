// lib/create_wallet.dart
import 'package:flutter/material.dart';

class CreateWallet extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSetup;

  const CreateWallet({
    super.key,
    required this.controller,
    required this.onSetup,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Enter your lndhub connection link:',
            style: TextStyle(
              color: Color(0xFFFDF4E9),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
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
          ElevatedButton(
            onPressed: onSetup,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.yellow,
              foregroundColor: Colors.black,
            ),
            child: const Text('Setup'),
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
}
