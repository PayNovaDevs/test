import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../widgets/sparkline.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/skeleton_loader.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);
    final sampleData = [1.0, 1.2, 1.15, 1.4, 1.3, 1.6, 1.55, 1.7];
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('app_title')),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.settings))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          GlassCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(loc.translate('balance_label'), style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 8),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
                  Text('1.2345', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                  SizedBox(height: 6),
                  Text('≈ USD 3,456.78', style: TextStyle(color: Colors.white54)),
                ]),
                SizedBox(
                  width: 120,
                  height: 48,
                  child: Sparkline(data: sampleData, lineColor: theme.colorScheme.primary),
                )
              ])
            ]),
          ),
          const SizedBox(height: 16),
          Text(loc.translate('tokens_label'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.separated(
              itemCount: 4,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                return GlassCard(
                  child: ListTile(
                    leading: CircleAvatar(backgroundColor: theme.colorScheme.primary, child: const Icon(Icons.currency_bitcoin, color: Colors.white)),
                    title: Text('TOKEN $index'),
                    subtitle: const Text('0x...abcd', style: TextStyle(color: Colors.white54)),
                    trailing: Column(mainAxisAlignment: MainAxisAlignment.center, children: const [Text('12.345', style: TextStyle(fontWeight: FontWeight.bold)), SizedBox(height: 4), Text('≈ 123.45 USD', style: TextStyle(color: Colors.white54, fontSize: 12))]),
                  ),
                );
              },
            ),
          )
        ]),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        label: Text(loc.translate('send_button')),
        icon: const Icon(Icons.send),
      ),
    );
  }
}
