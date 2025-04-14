import 'package:flutter/material.dart';

void showError({required BuildContext context, required String text}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(text),
      backgroundColor: const Color(0xFF8B0000),
    ),
  );
}
