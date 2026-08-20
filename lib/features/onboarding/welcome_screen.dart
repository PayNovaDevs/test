import 'package:flutter/material.dart';

import '../../widgets/gradient_button.dart';
import '../wallet/create_wallet/create_wallet_screen.dart';
import '../wallet/import/import_wallet_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SizedBox(height: 48),
            const Text('Bienvenido a dex wallet', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const Text('Una wallet no-custodial premium para EVM. Protege tus llaves y controla tus fondos.'),
            const Spacer(),
            GradientButton(onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CreateWalletScreen())), child: const Text('Crear Wallet', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ImportWalletScreen())), child: const Text('Importar Wallet')),
            const SizedBox(height: 24),
          ]),
        ),
      ),
    );
  }
}
