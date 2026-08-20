import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/skeleton_loader.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('dex wallet'),
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
              const Text('Balance', style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 8),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
                  Text('1.2345', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                  SizedBox(height: 6),
                  Text('≈ USD 3,456.78', style: TextStyle(color: Colors.white54)),
                ]),
                Container(
                  width: 120,
                  height: 48,
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.03), borderRadius: BorderRadius.circular(8)),
                  child: Center(child: Text('Mini‑chart', style: TextStyle(color: Colors.white24))),
                )
              ])
            ]),
          ),
          const SizedBox(height: 16),
          const Text('Tokens', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
        label: const Text('Send'),
        icon: const Icon(Icons.send),
      ),
    );
  }
}
