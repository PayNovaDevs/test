import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../widgets/gradient_button.dart';
import '../wallet/create_wallet/create_wallet_screen.dart';
import '../wallet/import/import_wallet_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SizedBox(height: 48),
            Text(loc.translate('welcome_title'), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text(loc.translate('welcome_subtitle')),
            const Spacer(),
            GradientButton(onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CreateWalletScreen())), child: Text(loc.translate('create_wallet'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ImportWalletScreen())), child: Text(loc.translate('import_wallet'))),
            const SizedBox(height: 24),
          ]),
        ),
      ),
    );
  }
}
