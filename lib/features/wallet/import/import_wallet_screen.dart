import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bip39/bip39.dart' as bip39;

import '../../core/hd/hd_wallet_service.dart';

class ImportWalletScreen extends ConsumerStatefulWidget {
  const ImportWalletScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ImportWalletScreen> createState() => _ImportWalletScreenState();
}

class _ImportWalletScreenState extends ConsumerState<ImportWalletScreen> {
  final _controller = TextEditingController();
  String _mode = 'mnemonic';
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _import() async {
    final text = _controller.text.trim();
    final hd = ref.read(hdWalletServiceProvider);
    try {
      if (_mode == 'mnemonic') {
        if (!bip39.validateMnemonic(text)) throw Exception('Mnemonic inválido');
        final seedHex = bip39.mnemonicToSeedHex(text);
        await hd.storeSeedHexSecurely(seedHex);
        if (mounted) Navigator.of(context).pop();
      } else {
        // private key
        final pk = text.replaceFirst('0x', '');
        await hd.importPrivateKey(pk, 0);
        if (mounted) Navigator.of(context).pop();
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Importar Wallet')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          Row(children: [
            ChoiceChip(label: const Text('Mnemonic'), selected: _mode == 'mnemonic', onSelected: (_) => setState(() => _mode = 'mnemonic')),
            const SizedBox(width: 8),
            ChoiceChip(label: const Text('Private Key'), selected: _mode == 'private'),
          ]),
          const SizedBox(height: 12),
          TextField(controller: _controller, maxLines: 4, decoration: InputDecoration(hintText: _mode == 'mnemonic' ? 'ingresa 12/24 palabras' : '0x... o hex', errorText: _error)),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: _import, child: const Text('Importar'))
        ]),
      ),
    );
  }
}
