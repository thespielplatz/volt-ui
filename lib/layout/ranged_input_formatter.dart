import 'package:flutter/services.dart';

class RangedInputFormatter extends TextInputFormatter {
  final int min;
  final int max;

  RangedInputFormatter({required this.min, required this.max});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Remove leading zeros
    String sanitized = newValue.text.replaceFirst(RegExp(r'^0+'), '');
    if (sanitized.isEmpty) return newValue.copyWith(text: '');

    int? value = int.tryParse(sanitized);
    if (value == null) return oldValue;

    // Clamp the value
    value = value.clamp(min, max);

    return TextEditingValue(
      text: value.toString(),
      selection: TextSelection.collapsed(offset: value.toString().length),
    );
  }
}
