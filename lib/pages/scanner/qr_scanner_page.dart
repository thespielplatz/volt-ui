import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:volt_ui/layout/show_error.dart';
import 'package:volt_ui/ui/app_colors.dart';

class QRScannerPage extends StatefulWidget {
  final Future<void> Function(String code) onDetect;

  const QRScannerPage({super.key, required this.onDetect});

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage>
    with WidgetsBindingObserver {
  bool _isLoading = false;
  bool _skipDetecting = false;

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

  void _onDetect(BarcodeCapture capture) async {
    var code = capture.barcodes.firstOrNull?.rawValue;
    if (code == null) {
      return;
    }

    if (_skipDetecting) {
      return;
    }
    _skipDetecting = true;

    setState(() {
      _isLoading = true;
    });
    await widget.onDetect(code);
    setState(() {
      _isLoading = false;
      _skipDetecting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        MobileScanner(
          controller: controller,
          onDetect: _onDetect,
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
