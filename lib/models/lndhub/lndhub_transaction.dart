// lib/models/transaction.dart

enum LndHubTransactionType {
  payment,
  userInvoice,
}

class LndHubTransaction {
  final LndHubTransactionType transactionType;
  final int feeMsat;
  final String type;
  final double fee;
  final int value;
  final DateTime timestamp;
  final DateTime? expireTime;
  final String? description;
  final String? paymentRequest;
  final bool? isPaid;

  LndHubTransaction({
    required this.transactionType,
    required this.feeMsat,
    required this.type,
    required this.fee,
    required this.value,
    required this.timestamp,
    this.expireTime,
    this.isPaid,
    this.paymentRequest,
    this.description,
  });

  factory LndHubTransaction.fromPaymentJson(Map<String, dynamic> json) {
    return LndHubTransaction(
      transactionType: LndHubTransactionType.payment,
      feeMsat: json['fee_msat'] ?? 0,
      type: json['type'] ?? 'unknown',
      fee: (json['fee'] ?? 0).toDouble(),
      value: json['value'] ?? 0,
      timestamp:
          DateTime.fromMillisecondsSinceEpoch((json['timestamp'] ?? 0) * 1000),
      description: json['memo'],
    );
  }

  factory LndHubTransaction.fromUserInvoiceJson(Map<String, dynamic> json) {
    return LndHubTransaction(
      transactionType: LndHubTransactionType.userInvoice,
      feeMsat: json['fee_msat'] ?? 0,
      type: json['type'] ?? 'user_invoice',
      fee: 0,
      value: json['amt'] ?? 0,
      timestamp:
          DateTime.fromMillisecondsSinceEpoch((json['timestamp'] ?? 0) * 1000),
      expireTime: DateTime.fromMillisecondsSinceEpoch(
          (json['expire_time'] ?? 0) * 1000),
      description: json['description'] is List
          ? (json['description'] as List).join(' ')
          : json['description']?.toString() ?? '',
      isPaid: json['ispaid'] ?? false,
      paymentRequest: json['payment_request'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fee_msat': feeMsat,
      'type': type,
      'fee': fee,
      'value': value,
      'timestamp': timestamp.millisecondsSinceEpoch ~/ 1000,
      'memo': description,
    };
  }
}
