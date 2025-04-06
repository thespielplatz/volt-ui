import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class TheHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const TheHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF081428),
      title: Row(
        children: [
          const Icon(
            CupertinoIcons.bolt_fill,
            color: Colors.yellow,
            size: 24,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFFFDF4E9),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      iconTheme: const IconThemeData(color: Color(0xFFFDF4E9)),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
