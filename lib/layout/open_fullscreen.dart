import 'package:flutter/material.dart';

void openFullscreen({
  required BuildContext context,
  required String title,
  required Widget body,
  VoidCallback? onClosed,
  bool replace = false,
}) {
  if (!replace) {
    Navigator.of(context).push(
        _createFullscreenWidget(context: context, title: title, body: body));
    return;
  }
  Navigator.of(context).pushReplacement(
      _createFullscreenWidget(context: context, title: title, body: body));
}

MaterialPageRoute<dynamic> _createFullscreenWidget({
  required BuildContext context,
  required String title,
  required Widget body,
  VoidCallback? onClosed,
}) {
  return MaterialPageRoute(
    fullscreenDialog: true,
    builder: (context) => Scaffold(
      backgroundColor: const Color(0xFF0F1B34),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color.fromARGB(255, 53, 59, 69),
        title: Text(
          title,
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Color(0xFFFDF4E9)),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              Navigator.of(context).pop();
              onClosed?.call();
            },
          ),
        ],
      ),
      body: DefaultTextStyle(
        style: const TextStyle(color: Colors.white),
        child: body,
      ),
    ),
  );
}
