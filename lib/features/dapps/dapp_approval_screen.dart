import 'package:flutter/material.dart';

/// Approval screen used to display WalletConnect requests (signature/tx) to the user.
/// This is a minimal UI that shows the DApp, the method and payload, and allows the user
/// to approve or reject. Approval will typically call into SessionManager to request PIN/biometrics
/// and then sign locally in the Vault.
class DappApprovalScreen extends StatelessWidget {
  final String dappName;
  final String method;
  final Map<String, dynamic> payload;
  final void Function() onApprove;
  final void Function() onReject;

  const DappApprovalScreen({Key? key, required this.dappName, required this.method, required this.payload, required this.onApprove, required this.onReject}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Approval: $dappName')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Method: $method', style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text('Payload:'),
          const SizedBox(height: 8),
          Expanded(child: SingleChildScrollView(child: Text(payload.toString()))),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            TextButton(onPressed: onReject, child: const Text('Rechazar')),
            const SizedBox(width: 12),
            ElevatedButton(onPressed: onApprove, child: const Text('Aprobar')),
          ])
        ]),
      ),
    );
  }
}
