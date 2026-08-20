import 'package:flutter/material.dart';

class TransactionConfirmationScreen extends StatelessWidget {
  final String to;
  final String value; // hex or decimal string
  final int gasLimit;
  final String gasPriceHex; // optional
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const TransactionConfirmationScreen({Key? key, required this.to, required this.value, required this.gasLimit, required this.gasPriceHex, required this.onApprove, required this.onReject}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Basic display of tx details. Caller should construct proper values.
    return Scaffold(
      appBar: AppBar(title: const Text('Confirm Transaction')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('To', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(to),
          const SizedBox(height: 12),
          const Text('Value', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(value),
          const SizedBox(height: 12),
          const Text('Gas Limit', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(gasLimit.toString()),
          const SizedBox(height: 12),
          const Text('Gas Price (hex)', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(gasPriceHex),
          const Spacer(),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            TextButton(onPressed: onReject, child: const Text('Reject')),
            const SizedBox(width: 12),
            ElevatedButton(onPressed: onApprove, child: const Text('Approve')),
          ])
        ]),
      ),
    );
  }
}
