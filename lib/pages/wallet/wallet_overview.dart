import 'package:flutter/material.dart';
import 'package:volt_ui/models/wallets/wallet.dart';
import 'package:volt_ui/pages/wallet/transaction_details/get_formatted_sats.dart';
import 'package:volt_ui/ui/app_colors.dart';

class WalletOverview extends StatelessWidget {
  final int balanceSats;
  final bool isLoading;
  final VoidCallback onSettings;
  final VoidCallback onRefresh;
  final Wallet wallet;

  const WalletOverview({
    super.key,
    required this.balanceSats,
    required this.onSettings,
    required this.onRefresh,
    required this.wallet,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.pageDarkBackground,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              wallet.label.isEmpty ? 'Wallet' : wallet.label,
              style:
                  const TextStyle(color: AppColors.textSecondary, fontSize: 16),
            ),
            const SizedBox(height: 40),
            Text(
              getFormattedSats(balanceSats, addPlusSign: false),
              style: const TextStyle(
                color: AppColors.text,
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
                    color: AppColors.accentColor,
                  ),
          ),
        ),
      ),
      Positioned(
        top: 8,
        right: 8,
        child: GestureDetector(
          onTap: onSettings,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.black,
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(6),
            child: const Icon(
              Icons.settings,
              size: 20,
              color: AppColors.accentColor,
            ),
          ),
        ),
      )
    ]);
  }
}
