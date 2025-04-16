import 'package:flutter/material.dart';
import 'package:volt_ui/pages/create/open_create_wallet.dart';
import 'package:volt_ui/ui/app_colors.dart';

class TheHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const TheHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.headerBackground,
      title: Row(
        children: [
          Image.asset(
            'design/logo/logo_orange.png',
            width: 35,
            height: 35,
          ),
          const SizedBox(width: 6),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.headerText,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () => openCreateWallet(context),
          icon: const Icon(Icons.add, color: AppColors.headerText),
        ),
      ],
      iconTheme: const IconThemeData(color: AppColors.headerText),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
