import 'package:flutter/material.dart';

void openFullscreen({
  required BuildContext context,
  required String title,
  required Widget body,
}) {
  Navigator.of(context).push(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (context) => Scaffold(
        backgroundColor: const Color(0xFF0F1B34),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: const Color(0xFF081428),
          title: Text(
            title,
            style: const TextStyle(color: Colors.white),
          ),
          iconTheme: const IconThemeData(color: Color(0xFFFDF4E9)),
          actions: [
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
        body: DefaultTextStyle(
          style: const TextStyle(color: Colors.white),
          child: body,
        ),
      ),
    ),
  );
}
