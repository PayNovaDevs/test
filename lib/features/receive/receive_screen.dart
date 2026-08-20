import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ReceiveScreen extends StatelessWidget {
  final String address;
  const ReceiveScreen({Key? key, required this.address}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Receive')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
          const SizedBox(height: 12),
          Text(address, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 24),
          QrImage(data: address, size: 220),
          const SizedBox(height: 24),
          ElevatedButton(onPressed: () async {
            await Clipboard.setData(ClipboardData(text: address));
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Address copied')));
          }, child: const Text('Copy Address'))
        ]),
      ),
    );
  }
}
