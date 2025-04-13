import 'package:volt_ui/layout/sats_input_formatter.dart';
import 'package:volt_ui/models/lndhub/lndhub_transaction.dart';

String getFormattedSatsFromTransaction(LndHubTransaction transaction,
    {bool addPlusSign = true}) {
  return getFormattedSats(
    transaction.transactionType == LndHubTransactionType.payment
        ? -transaction.value
        : transaction.value,
    addPlusSign: addPlusSign,
  );
}

String getFormattedSats(int value, {bool addPlusSign = true}) {
  return '${value > 0 && addPlusSign ? '+ ' : ''}${SatsInputFormatter.format(value.toString())} sats';
}
