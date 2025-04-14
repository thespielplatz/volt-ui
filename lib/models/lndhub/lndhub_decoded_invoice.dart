class LndHubDecodedInvoice {
  final String destination;
  final String paymentHash;
  final double numSatoshis;
  final int timestamp;
  final DateTime timestampAsDateTime;
  final int expiry;
  final String? description;
  final String fallbackAddr;
  final int cltvExpiry;

  LndHubDecodedInvoice({
    required this.destination,
    required this.paymentHash,
    required this.numSatoshis,
    required this.timestamp,
    required this.timestampAsDateTime,
    required this.expiry,
    required this.description,
    required this.fallbackAddr,
    required this.cltvExpiry,
  });

  factory LndHubDecodedInvoice.fromJson(Map<String, dynamic> json) {
    return LndHubDecodedInvoice(
      destination: json['destination'],
      paymentHash: json['payment_hash'],
      numSatoshis: (json['num_satoshis'] as num).toDouble(),
      timestamp: int.parse(json['timestamp']),
      timestampAsDateTime: DateTime.fromMillisecondsSinceEpoch(
          int.parse(json['timestamp']) * 1000),
      expiry: int.parse(json['expiry']),
      description: json['description'],
      fallbackAddr: json['fallback_addr'],
      cltvExpiry: json['cltv_expiry'],
    );
  }
}
