import 'package:flutter/material.dart';

class VUIButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final bool isEnabled;
  final bool isLoading;

  const VUIButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.isEnabled = true,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: (isEnabled && !isLoading) ? onPressed : null,
      style: ButtonStyle(
        minimumSize: WidgetStateProperty.all(const Size(100, 48)),
        padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10)),
        backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.disabled)) {
            return const Color(0x20FFFF00);
          }
          return Colors.yellow;
        }),
        foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
          return isEnabled ? Colors.black : Colors.white;
        }),
        side: WidgetStateProperty.all(
          const BorderSide(color: Colors.yellow, width: 2),
        ),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
      ),
      child: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.yellow),
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: isEnabled ? Colors.black : const Color(0xFFB0B0B0),
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: isEnabled ? Colors.black : const Color(0xFFB0B0B0),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
    );
  }
}
