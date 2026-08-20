import 'package:flutter/material.dart';

import 'package:dex_wallet/core/transactions/fee_utils.dart';

import '../../l10n/app_localizations.dart';

class TransactionConfirmationScreen extends StatelessWidget {
  final String to;
  final String value; // hex or decimal string
  final int gasLimit;
  final String? maxPriorityFeeHex; // optional (EIP-1559)
  final String? maxFeeHex; // optional (EIP-1559)
  final String? baseFeeHex; // optional (EIP-1559)
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const TransactionConfirmationScreen({Key? key, required this.to, required this.value, required this.gasLimit, required this.onApprove, required this.onReject, this.maxPriorityFeeHex, this.maxFeeHex, this.baseFeeHex}) : super(key: key);

  Future<void> _handleApprove(BuildContext context) async {
    final confirmed = await showDialog<bool>(context: context, builder: (_) => const _PinEntryPlaceholder());
    if (confirmed == true) {
      onApprove();
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    BigInt? maxFee;
    BigInt? maxPriority;
    BigInt? baseFee;
    double estTotalEth = 0.0;

    try {
      if (maxFeeHex != null) maxFee = hexToBigInt(maxFeeHex!);
      if (maxPriorityFeeHex != null) maxPriority = hexToBigInt(maxPriorityFeeHex!);
      if (baseFeeHex != null) baseFee = hexToBigInt(baseFeeHex!);
      if (maxFee != null) {
        estTotalEth = estimateTotalFeeEth(gasLimit, maxFee);
      }
    } catch (_) {}

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
          if (maxPriority != null) ...[
            Text(loc.translate('max_priority_fee_label'), style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(formatGwei(weiToGwei(maxPriority))),
            const SizedBox(height: 12),
          ],
          if (maxFee != null) ...[
            Text(loc.translate('max_fee_label'), style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(formatGwei(weiToGwei(maxFee))),
            const SizedBox(height: 12),
          ],
          if (estTotalEth > 0) ...[
            Text(loc.translate('estimated_fee_label'), style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text('${formatEth(estTotalEth)} ETH'),
            const SizedBox(height: 12),
          ],
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

class _PinEntryPlaceholder extends StatelessWidget {
  const _PinEntryPlaceholder({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // The real PIN dialog is implemented elsewhere; keep a simple placeholder for the dialog call stack.
    return AlertDialog(
      title: const Text('Authenticate'),
      content: const Text('Authentication flow will be triggered here.'),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
        ElevatedButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Confirm')),
      ],
    );
  }
}
