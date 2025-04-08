import 'package:flutter/material.dart';

class VUIButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final bool isEnabled;

  const VUIButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: isEnabled ? onPressed : null,
      icon: Icon(
        icon,
        color: isEnabled ? Colors.black : Colors.grey,
      ),
      label: Text(
        label,
        style: TextStyle(
          color: isEnabled ? Colors.black : Colors.grey,
          fontWeight: FontWeight.bold,
        ),
      ),
      style: ButtonStyle(
        minimumSize: WidgetStateProperty.all(const Size(100, 48)),
        padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10)),
        backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.disabled)) {
            // ignore: deprecated_member_use
            return Colors.yellow.withOpacity(0.1);
          }
          return Colors.yellow;
        }),
        foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
          return isEnabled ? Colors.black : Colors.white;
        }),
        side: WidgetStateProperty.all(
          const BorderSide(color: Colors.yellow, width: 1.5),
        ),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
      ),
    );
  }
}
