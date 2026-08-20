import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bip39/bip39.dart' as bip39;

import '../../core/hd/hd_wallet_service.dart';

class CreateWalletScreen extends ConsumerStatefulWidget {
  const CreateWalletScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CreateWalletScreen> createState() => _CreateWalletScreenState();
}

class _CreateWalletScreenState extends ConsumerState<CreateWalletScreen> {
  late String _mnemonic;

  @override
  void initState() {
    super.initState();
    _mnemonic = bip39.generateMnemonic();
  }

  Future<void> _confirmAndSave() async {
    // Convert mnemonic to seedHex and store via HdWalletService
    final hd = ref.read(hdWalletServiceProvider);
    final seedHex = bip39.mnemonicToSeedHex(_mnemonic);
    await hd.storeSeedHexSecurely(seedHex);
    // After storing, navigate to backup verification
    if (mounted) Navigator.of(context).push(MaterialPageRoute(builder: (_) => SeedBackupScreen(mnemonic: _mnemonic)));
  }

  @override
  Widget build(BuildContext context) {
    final words = _mnemonic.split(' ');
    return Scaffold(
      appBar: AppBar(title: const Text('Crear Wallet')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Anota estas palabras en orden y guárdalas en un lugar seguro. Nunca las compartas.'),
          const SizedBox(height: 12),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 4),
              itemCount: words.length,
              itemBuilder: (_, i) => Card(
                color: Colors.grey[900],
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(children: [Text('${i + 1}.', style: const TextStyle(color: Colors.green)), const SizedBox(width: 8), Text(words[i])]),
                ),
              ),
            ),
          ),
          ElevatedButton(onPressed: _confirmAndSave, child: const Text('Continuar'))
        ]),
      ),
    );
  }
}

class SeedBackupScreen extends ConsumerWidget {
  final String mnemonic;
  const SeedBackupScreen({Key? key, required this.mnemonic}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final words = mnemonic.split(' ');
    return Scaffold(
      appBar: AppBar(title: const Text('Backup de Seed')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          const Text('Confirma que has guardado tus palabras.'),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              itemCount: words.length,
              itemBuilder: (_, i) => ListTile(title: Text('${i + 1}. ${words[i]}')),
            ),
          ),
          ElevatedButton(onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => SeedVerifyScreen(mnemonic: mnemonic))), child: const Text('Verificar'))
        ]),
      ),
    );
  }
}

class SeedVerifyScreen extends ConsumerStatefulWidget {
  final String mnemonic;
  const SeedVerifyScreen({Key? key, required this.mnemonic}) : super(key: key);

  @override
  ConsumerState<SeedVerifyScreen> createState() => _SeedVerifyScreenState();
}

class _SeedVerifyScreenState extends ConsumerState<SeedVerifyScreen> {
  final _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _check() {
    final entered = _controller.text.trim();
    if (entered == widget.mnemonic) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else {
      setState(() {
        _error = 'La frase no coincide. Intenta de nuevo.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verificar Seed')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          const Text('Introduce tu frase completa para confirmar que la guardaste correctamente'),
          const SizedBox(height: 12),
          TextField(controller: _controller, maxLines: 3, decoration: InputDecoration(hintText: 'palabra1 palabra2 ...', errorText: _error)),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _check, child: const Text('Verificar'))
        ]),
      ),
    );
  }
}
