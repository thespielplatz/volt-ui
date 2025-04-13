import 'package:flutter/material.dart';
import 'package:volt_ui/models/lndhub/lndhub_transaction.dart';

Icon getTransactionIcon(LndHubTransaction transaction, {double size = 24.0}) {
  Icon icon;
  if (transaction.transactionType == LndHubTransactionType.payment) {
    icon = Icon(Icons.north_east, color: Colors.red, size: size);
  } else if (transaction.transactionType == LndHubTransactionType.userInvoice) {
    if (transaction.isPaid ?? false) {
      icon = Icon(Icons.south_east, color: Colors.green, size: size);
    } else {
      icon = Icon(Icons.more_horiz, color: Colors.grey, size: size);
    }
  } else {
    icon = Icon(Icons.question_mark, color: Colors.grey, size: size);
  }

  return icon;
}
