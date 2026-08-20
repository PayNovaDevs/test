import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../features/transactions/pin_entry_dialog.dart';

class TransactionConfirmationScreen extends StatelessWidget {
  final String to;
  final String value; // hex or decimal string
  final int gasLimit;
  final String gasPriceHex; // optional
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const TransactionConfirmationScreen({Key? key, required this.to, required this.value, required this.gasLimit, required this.gasPriceHex, required this.onApprove, required this.onReject}) : super(key: key);

  Future<void> _handleApprove(BuildContext context) async {
    final confirmed = await showDialog<bool>(context: context, builder: (_) => const PinEntryDialog());
    if (confirmed == true) {
      onApprove();
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    // Basic display of tx details. Caller should construct proper values.
    return Scaffold(
      appBar: AppBar(title: Text(loc.translate('confirm_transaction_title'))),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(loc.translate('to_label'), style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(to),
          const SizedBox(height: 12),
          Text(loc.translate('value_label'), style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(value),
          const SizedBox(height: 12),
          Text(loc.translate('gas_limit_label'), style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(gasLimit.toString()),
          const SizedBox(height: 12),
          Text(loc.translate('gas_price_label'), style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(gasPriceHex),
          const Spacer(),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            TextButton(onPressed: onReject, child: Text(loc.translate('reject'))),
            const SizedBox(width: 12),
            ElevatedButton(onPressed: () => _handleApprove(context), child: Text(loc.translate('approve'))),
          ])
        ]),
      ),
    );
  }
}
