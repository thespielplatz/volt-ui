import 'package:flutter/services.dart';

class SatsInputFormatter extends TextInputFormatter {
  static String format(String digits) {
    digits = digits.replaceAll(RegExp(r'\D'), '');

    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i == digits.length - 6 || i == digits.length - 3) buffer.write(' ');
      buffer.write(digits[i]);
    }

    return buffer.toString();
  }

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final formatted = format(newValue.text);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
