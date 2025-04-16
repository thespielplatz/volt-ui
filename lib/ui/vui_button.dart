import 'package:flutter/material.dart';
import 'package:volt_ui/ui/app_colors.dart';

class VUIButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final bool isEnabled;
  final bool isLoading;
  final Color accentColor;
  final Color secondaryColor;
  final bool isFullWidth;

  const VUIButton(
      {super.key,
      required this.icon,
      required this.label,
      required this.onPressed,
      this.isEnabled = true,
      this.isLoading = false,
      this.accentColor = AppColors.accentColor,
      this.secondaryColor = Colors.black,
      this.isFullWidth = true});

  @override
  Widget build(BuildContext context) {
    Widget button = OutlinedButton(
      onPressed: (isEnabled && !isLoading) ? onPressed : null,
      style: ButtonStyle(
        minimumSize: WidgetStateProperty.all(const Size(100, 48)),
        padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10)),
        backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.disabled)) {
            return const Color(0x20FFFF00);
          }
          return accentColor;
        }),
        foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
          return isEnabled ? Colors.black : Colors.white;
        }),
        side: WidgetStateProperty.all(
          BorderSide(color: accentColor, width: 2),
        ),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
      ),
      child: isLoading
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(accentColor),
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: isEnabled ? secondaryColor : const Color(0xFFB0B0B0),
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: isEnabled ? secondaryColor : const Color(0xFFB0B0B0),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
    );

    if (isFullWidth) {
      button = SizedBox(
        width: double.infinity,
        child: button,
      );
    }

    return button;
  }
}
