import 'package:volt_ui/utils/too_two_digits.dart';

// ignore: non_constant_identifier_names
String VUIFormatDate(DateTime date) {
  return '${date.year}-${toTwoDigits(date.month)}-${toTwoDigits(date.day)} ${toTwoDigits(date.hour)}:${toTwoDigits(date.minute)}';
}
