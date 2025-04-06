// lib/wallet_action_button.dart
import 'package:flutter/material.dart';

class VUIButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const VUIButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.black),
      label: Text(label,
          style: const TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold)),
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(100, 48),
        backgroundColor: Colors.yellow,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      ),
    );
  }
}
