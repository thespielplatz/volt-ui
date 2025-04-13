import 'package:flutter/services.dart';

class SatsInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // Only digits
    String digits = newValue.text.replaceAll(RegExp(r'\D'), '');

    // Format into XXXXX XXX XXX
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i == digits.length - 6 || i == digits.length - 3) buffer.write(' ');
      buffer.write(digits[i]);
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
