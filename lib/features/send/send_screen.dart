import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/address_utils.dart';
import 'send_controller.dart';

class SendScreen extends ConsumerStatefulWidget {
  final String fromAddress;
  final int derivationIndex;
  final int chainId;
  const SendScreen({Key? key, required this.fromAddress, this.derivationIndex = 0, required this.chainId}) : super(key: key);

  @override
  ConsumerState<SendScreen> createState() => _SendScreenState();
}

class _SendScreenState extends ConsumerState<SendScreen> {
  final _toController = TextEditingController();
  final _amountController = TextEditingController();
  final _tokenController = TextEditingController(); // token address or empty for native

  @override
  void dispose() {
    _toController.dispose();
    _amountController.dispose();
    _tokenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deps = SendDeps(rpc: ref.read(sendDepsProvider).rpc, hd: ref.read(sendDepsProvider).hd, chainId: widget.chainId);
    final controller = ref.watch(sendControllerProvider(deps));
    final notifier = ref.read(sendControllerProvider(deps).notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Enviar')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          TextField(controller: _toController, decoration: const InputDecoration(labelText: 'Dirección destino')),
          const SizedBox(height: 12),
          TextField(controller: _amountController, decoration: const InputDecoration(labelText: 'Cantidad')),
          const SizedBox(height: 12),
          TextField(controller: _tokenController, decoration: const InputDecoration(labelText: 'Token (dirección ERC-20, vacío = nativo)')),
          const SizedBox(height: 20),
          controller.loading ? const CircularProgressIndicator() : ElevatedButton(
            onPressed: () async {
              final to = _toController.text.trim();
              final amount = _amountController.text.trim();
              final token = _tokenController.text.trim();
              if (!AddressUtils.isValidEthereumAddress(to)) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Dirección inválida')));
                return;
              }
              await notifier.send(fromAddress: widget.fromAddress, toAddress: to, amountDecimal: amount, tokenAddress: token, derivationIndex: widget.derivationIndex);
              final state = ref.read(sendControllerProvider(deps));
              if (state.error != null) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${state.error}')));
              } else if (state.txHash != null) {
                showDialog(context: context, builder: (_) => AlertDialog(title: const Text('Enviado'), content: Text('Tx hash: ${state.txHash}'), actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('OK'))]));
              }
            },
            child: const Text('Enviar'),
          )
        ]),
      ),
    );
  }
}
