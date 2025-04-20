enum LndHubTransactionType {
  payment,
  userInvoice,
}

class LndHubTransaction {
  final LndHubTransactionType transactionType;
  final int feeMsat;
  final double fee;
  final int value;
  final DateTime timestamp;
  final DateTime? expireTime;
  final String? description;
  final String? paymentRequest;
  final String paymentHash;
  final bool? _isPaid;

  LndHubTransaction({
    required this.transactionType,
    required this.feeMsat,
    required this.fee,
    required this.value,
    required this.timestamp,
    required this.paymentHash,
    this.expireTime,
    bool? isPaid,
    this.paymentRequest,
    this.description,
  }) : _isPaid = isPaid;

  bool get isPaid {
    return transactionType == LndHubTransactionType.payment ||
        (transactionType == LndHubTransactionType.userInvoice &&
            _isPaid == true);
  }

  /// Unified factory method
  factory LndHubTransaction.fromJson(Map<String, dynamic> json) {
    switch (json['transactionType']) {
      case 'payment':
        return LndHubTransaction.fromPaymentJson(json);
      case 'userInvoice':
        return LndHubTransaction.fromUserInvoiceJson(json);
      default:
        throw Exception('Unknown transaction type: ${json['transactionType']}');
    }
  }

  factory LndHubTransaction.fromPaymentJson(Map<String, dynamic> json) {
    return LndHubTransaction(
      transactionType: LndHubTransactionType.payment,
      paymentHash: json['payment_hash'],
      feeMsat: json['fee_msat'] ?? 0,
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
      paymentHash: json['payment_hash'],
      feeMsat: json['fee_msat'] ?? 0,
      fee: 0,
      value: json['amt'] ?? 0,
      timestamp:
          DateTime.fromMillisecondsSinceEpoch((json['timestamp'] ?? 0) * 1000),
      expireTime: json['expire_time'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              (json['expire_time'] ?? 0) * 1000)
          : null,
      description: json['description'] is List
          ? (json['description'] as List).join(' ')
          : json['description']?.toString() ?? '',
      isPaid: json['ispaid'] ?? false,
      paymentRequest: json['payment_request'],
    );
  }

  /// Fully detailed serializer for caching
  Map<String, dynamic> toJson() {
    return {
      'transactionType': transactionType.name,
      'fee_msat': feeMsat,
      'fee': fee,
      'value': value,
      'timestamp': timestamp.millisecondsSinceEpoch ~/ 1000,
      'expire_time': expireTime?.millisecondsSinceEpoch ?? 0 ~/ 1000,
      'description': description,
      'payment_request': paymentRequest,
      'payment_hash': paymentHash,
      'ispaid': _isPaid,
    };
  }
}
