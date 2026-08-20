import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../l10n/app_localizations.dart';

class ScanQrScreen extends StatefulWidget {
  const ScanQrScreen({Key? key}) : super(key: key);

  @override
  State<ScanQrScreen> createState() => _ScanQrScreenState();
}

class _ScanQrScreenState extends State<ScanQrScreen> {
  String? _result;
  final MobileScannerController _controller = MobileScannerController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(loc.translate('scan_qr_title'))),
      body: Stack(children: [
        MobileScanner(
          controller: _controller,
          onDetect: (barcode, args) {
            final String? code = barcode.rawValue;
            if (code != null && _result == null) {
              setState(() => _result = code);
              Navigator.of(context).pop(code);
            }
          },
        ),
        if (_result != null)
          Center(
            child: Container(
              padding: const EdgeInsets.all(12),
              color: Colors.black54,
              child: Text('${loc.translate('scan_result')}: $_result', style: const TextStyle(color: Colors.white)),
            ),
          )
      ]),
    );
  }
}
