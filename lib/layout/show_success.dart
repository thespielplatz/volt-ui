import 'package:flutter/material.dart';

void showSuccess({required BuildContext context, required String text}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(text),
      backgroundColor: const Color.fromARGB(255, 0, 180, 0),
    ),
  );
}
