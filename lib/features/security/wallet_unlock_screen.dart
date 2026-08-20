import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/security/session_manager.dart';

class WalletUnlockScreen extends ConsumerStatefulWidget {
  const WalletUnlockScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<WalletUnlockScreen> createState() => _WalletUnlockScreenState();
}

class _WalletUnlockScreenState extends ConsumerState<WalletUnlockScreen> {
  final _pin = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _pin.dispose();
    super.dispose();
  }

  Future<void> _unlock() async {
    final pin = _pin.text.trim();
    // placeholder validation
    final storage = ref.read(secureStorageProvider);
    final stored = await storage.read('user_pin_hash');
    if (stored == pin) {
      Navigator.of(context).pop();
    } else {
      setState(() => _error = 'PIN inválido');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Desbloquear Wallet')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          const Text('Introduce tu PIN para desbloquear'),
          const SizedBox(height: 12),
          TextField(controller: _pin, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'PIN')),
          const SizedBox(height: 12),
          if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red)),
          ElevatedButton(onPressed: _unlock, child: const Text('Desbloquear'))
        ]),
      ),
    );
  }
}
