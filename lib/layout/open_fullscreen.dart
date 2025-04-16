import 'package:flutter/material.dart';
import 'package:volt_ui/ui/app_colors.dart';

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
      backgroundColor: AppColors.pageBackground,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.headerBackground,
        title: Row(children: [
          Image.asset(
            'design/logo/logo_orange.png',
            width: 35,
            height: 35,
          ),
          const SizedBox(width: 6),
          Text(
            title,
            style: const TextStyle(
                color: AppColors.text, fontWeight: FontWeight.bold),
          ),
        ]),
        iconTheme: const IconThemeData(color: AppColors.text),
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
        style: const TextStyle(color: AppColors.text),
        child: body,
      ),
    ),
  );
}
