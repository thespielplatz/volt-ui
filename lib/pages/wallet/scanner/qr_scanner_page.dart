import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:volt_ui/layout/show_error.dart';
import 'package:volt_ui/models/lndhub/lndhub_decoded_invoice.dart';
import 'package:volt_ui/repository/wallet_repository.dart';
import 'package:dart_lnurl/dart_lnurl.dart';
import 'package:volt_ui/services/lightning/validate_bolt11.dart';
import 'package:volt_ui/ui/app_colors.dart';

class QRScannerPage extends StatefulWidget {
  final WalletRepository walletRepository;
  final void Function({String invoice, LndHubDecodedInvoice decodedInvoice})
      onInvoiceFound;

  const QRScannerPage(
      {super.key,
      required this.walletRepository,
      required this.onInvoiceFound});

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage>
    with WidgetsBindingObserver {
  bool _isLoading = false;

  final MobileScannerController controller = MobileScannerController(
    autoStart: false,
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
    torchEnabled: false,
    returnImage: false,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Start the scanner
    unawaited(controller.start());
    _isLoading = false;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!controller.value.hasCameraPermission) {
      showError(
          context: context,
          text: 'Camera permission are missing to use the QR Code Scanner');
      return;
    }

    switch (state) {
      case AppLifecycleState.resumed:
        unawaited(controller.start());
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
        unawaited(controller.stop());
        break;
      case AppLifecycleState.detached:
        break;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(controller.dispose());
    super.dispose();
  }

  void _handleBarcode(BarcodeCapture capture) async {
    var code = capture.barcodes.firstOrNull?.rawValue;
    if (code == null) {
      return;
    }

    setState(() {
      _isLoading = true;
    });
    if (validateBolt11(code)) {
      try {
        LndHubDecodedInvoice decodedInvoice =
            await widget.walletRepository.decodeInvoice(code);
        widget.onInvoiceFound(
          invoice: code,
          decodedInvoice: decodedInvoice,
        );
        return;
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        showError(
          context: context,
          text: 'Error processing invoice: $e',
        );
        return;
      }
    }

    try {
      // dart_lnurl can decode lighting: also
      LNURLParseResult result = await getParams(code);
      if (result.error != null) {
        showError(
          context: context,
          text:
              'Error processing lnurl: ${result.error?.status} ${result.error?.reason} ${result.error?.domain} ${result.error?.url}',
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }
      if (result.withdrawalParams != null) {
        showError(
          context: context,
          text: 'LNURLw not implemented yet',
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }
      if (result.payParams != null) {
        showError(
          context: context,
          text: 'LNURLp not implemented yet',
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }
      if (result.authParams != null) {
        showError(
          context: context,
          text: 'LNURLauth not implemented yet',
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }
      if (result.channelParams != null) {
        showError(
          context: context,
          text: 'LNURLchannel not implemented yet',
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }
      setState(() {
        _isLoading = false;
      });
      return;
    } catch (e) {
      showError(
        context: context,
        text: 'LNURL processing error: $e',
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        MobileScanner(
          controller: controller,
          onDetect: _handleBarcode,
        ),

        // Top-centered loader
        if (_isLoading)
          const Align(
            alignment: Alignment.topCenter,
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.only(top: 30),
                child: CircularProgressIndicator(
                  strokeWidth: 5,
                  color: AppColors.accentColor,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
