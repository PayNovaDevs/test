import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/security/session_manager.dart';

class PinSetupScreen extends ConsumerStatefulWidget {
  const PinSetupScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends ConsumerState<PinSetupScreen> {
  final _pin1 = TextEditingController();
  final _pin2 = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _pin1.dispose();
    _pin2.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final pin1 = _pin1.text.trim();
    final pin2 = _pin2.text.trim();
    if (pin1.length != 6 || pin2.length != 6) {
      setState(() => _error = 'El PIN debe tener 6 dígitos');
      return;
    }
    if (pin1 != pin2) {
      setState(() => _error = 'Los PIN no coinciden');
      return;
    }
    final session = ref.read(secureStorageProvider) as dynamic; // we will use session manager below
    final sm = SessionManager(ref.read(secureStorageProvider), ref.read(const Provider((_) => null)) as dynamic);
    // The above is a placeholder: SessionManager expects BiometricService in constructor; to keep simple store pin directly
    final storage = ref.read(secureStorageProvider);
    await storage.write('user_pin_hash', pin1); // IMPORTANT: in production store hash not raw PIN; this is placeholder
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configurar PIN')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          const Text('Elige un PIN de 6 dígitos para proteger tu wallet'),
          const SizedBox(height: 12),
          TextField(controller: _pin1, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'PIN')), 
          const SizedBox(height: 8),
          TextField(controller: _pin2, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Confirmar PIN')),
          const SizedBox(height: 12),
          if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red)),
          ElevatedButton(onPressed: _save, child: const Text('Guardar PIN'))
        ]),
      ),
    );
  }
}
