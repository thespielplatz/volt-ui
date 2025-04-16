import 'package:flutter/widgets.dart';
import 'package:volt_ui/ui/app_colors.dart';

Widget wrapIcon(Icon icon,
    {double? border, Color background = AppColors.pageBackground}) {
  return Container(
    padding: EdgeInsets.all(border ?? 8),
    decoration: BoxDecoration(
      color: background,
      shape: BoxShape.circle,
    ),
    child: icon,
  );
}
