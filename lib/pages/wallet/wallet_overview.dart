import 'package:flutter/material.dart';

class WalletOverview extends StatelessWidget {
  final int balanceSats;
  final bool isLoading;
  final VoidCallback onDelete;
  final VoidCallback onRefresh;

  const WalletOverview({
    super.key,
    required this.balanceSats,
    required this.onDelete,
    required this.onRefresh,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Container(
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
      ),
      Positioned(
        top: 8,
        right: 46,
        child: GestureDetector(
          onTap: onRefresh,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.black,
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(6),
            child: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(
                    Icons.refresh,
                    size: 20,
                    color: Colors.yellow,
                  ),
          ),
        ),
      ),
      Positioned(
        top: 8,
        right: 8,
        child: GestureDetector(
          onTap: onDelete,
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0xFF081428),
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(6),
            child: const Icon(
              Icons.delete,
              size: 20,
              color: Colors.redAccent,
            ),
          ),
        ),
      )
    ]);
  }
}
