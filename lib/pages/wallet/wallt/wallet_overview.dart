// lib/wallet_overview.dart
import 'package:flutter/material.dart';

class WalletOverview extends StatelessWidget {
  final int balanceSats;

  const WalletOverview({super.key, required this.balanceSats});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF14243C),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Wallet',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            '$balanceSats sats',
            style: const TextStyle(
              color: Color(0xFFFDF4E9),
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
