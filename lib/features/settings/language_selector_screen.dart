import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../l10n/app_localizations.dart';

class LanguageSelectorScreen extends ConsumerWidget {
  const LanguageSelectorScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final loc = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(loc.translate('language_title'))),
      body: ListView(children: [
        RadioListTile<Locale>(title: const Text('Español'), value: const Locale('es'), groupValue: locale, onChanged: (v) => ref.read(localeProvider.notifier).setLocale(v!)),
        RadioListTile<Locale>(title: const Text('English'), value: const Locale('en'), groupValue: locale, onChanged: (v) => ref.read(localeProvider.notifier).setLocale(v!)),
      ]),
    );
  }
}
