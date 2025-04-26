import 'package:tsp_dart_lnurl/dart_lnurl.dart';
import 'package:flutter/material.dart';
import 'package:volt_ui/layout/show_error.dart';
import 'package:volt_ui/models/lndhub/lndhub_decoded_invoice.dart';
import 'package:volt_ui/repository/wallet_repository.dart';
import 'package:volt_ui/services/lightning/validate_bolt11.dart';

class CodeIdentifier {
  final BuildContext context;
  final WalletRepository walletRepository;
  final void Function({String invoice, LndHubDecodedInvoice decodedInvoice})
      onInvoiceFound;
  final void Function(LNURLPayParams payParams) onLNURLpFound;

  CodeIdentifier({
    required this.context,
    required this.walletRepository,
    required this.onInvoiceFound,
    required this.onLNURLpFound,
  });

  identifyCode(String code) async {
    if (validateBolt11(code)) {
      await _tryBolt11(code);
      return;
    }

    try {
      // dart_lnurl can decode lighting: also
      LNURLParseResult result = await getParams(code);
      if (result.error != null) {
        showError(
          // ignore: use_build_context_synchronously
          context: context,
          text:
              'Error processing lnurl: ${result.error?.status} ${result.error?.reason} ${result.error?.domain} ${result.error?.url}',
        );
        return;
      }
      if (result.withdrawalParams != null) {
        showError(
          // ignore: use_build_context_synchronously
          context: context,
          text: 'LNURLw not implemented yet',
        );
        return;
      }
      if (result.payParams != null) {
        onLNURLpFound(result.payParams!);
        return;
      }
      if (result.authParams != null) {
        showError(
          // ignore: use_build_context_synchronously
          context: context,
          text: 'LNURLauth not implemented yet',
        );
        return;
      }
      if (result.channelParams != null) {
        showError(
          // ignore: use_build_context_synchronously
          context: context,
          text: 'LNURLchannel not implemented yet',
        );
        return;
      }
      return;
    } catch (e) {
      showError(
        // ignore: use_build_context_synchronously
        context: context,
        text: 'LNURL processing error: $e',
      );
      return;
    }
  }

  _tryBolt11(code) async {
    try {
      LndHubDecodedInvoice decodedInvoice =
          await walletRepository.decodeInvoice(code);
      onInvoiceFound(
        invoice: code,
        decodedInvoice: decodedInvoice,
      );
    } catch (e) {
      showError(
        // ignore: use_build_context_synchronously
        context: context,
        text: 'Error processing invoice: $e',
      );
    }
  }
}
