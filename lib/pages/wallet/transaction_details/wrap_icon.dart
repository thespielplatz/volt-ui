import 'package:flutter/widgets.dart';

Widget wrapIcon(Icon icon, {double? border}) {
  return Container(
    padding: EdgeInsets.all(border ?? 8),
    decoration: const BoxDecoration(
      color: Color(0xFF081428),
      shape: BoxShape.circle,
    ),
    child: icon,
  );
}
