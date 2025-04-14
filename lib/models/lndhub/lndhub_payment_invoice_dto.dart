import 'package:volt_ui/models/lndhub/lndhub_decoded_invoice.dart';

class LndHubPaymentInvoiceDto {
  final String paymentError;
  final String paymentPreimage;
  final String paymentHash;
  final LndHubDecodedInvoice decoded;
  final int feeMsat;
  final String type;
  final int fee;
  final double value;
  final int timestamp;
  final String memo;

  LndHubPaymentInvoiceDto({
    required this.paymentError,
    required this.paymentPreimage,
    required this.paymentHash,
    required this.decoded,
    required this.feeMsat,
    required this.type,
    required this.fee,
    required this.value,
    required this.timestamp,
    required this.memo,
  });

  factory LndHubPaymentInvoiceDto.fromJson(Map<String, dynamic> json) {
    return LndHubPaymentInvoiceDto(
      paymentError: json['payment_error'],
      paymentPreimage: json['payment_preimage'],
      paymentHash: json['payment_hash'],
      decoded: LndHubDecodedInvoice.fromJson(json['decoded']),
      feeMsat: json['fee_msat'],
      type: json['type'],
      fee: json['fee'],
      value: (json['value'] as num).toDouble(),
      timestamp: json['timestamp'],
      memo: json['memo'],
    );
  }
}
