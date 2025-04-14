import 'package:volt_ui/layout/sats_input_formatter.dart';
import 'package:volt_ui/models/lndhub/lndhub_transaction.dart';

String getFormattedSatsFromTransaction(LndHubTransaction transaction,
    {bool addPlusSign = true}) {
  return getFormattedSats(
    transaction.value,
    addPlusSign: addPlusSign,
  );
}

String getFormattedSats(int value, {bool addPlusSign = true}) {
  String sign = value < 0
      ? '- '
      : addPlusSign
          ? '+ '
          : '';
  return '$sign${SatsInputFormatter.format(value.toString())} sats';
}
