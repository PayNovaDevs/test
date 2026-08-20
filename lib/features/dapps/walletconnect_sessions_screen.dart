import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';

class WalletConnectSessionsScreen extends ConsumerWidget {
  const WalletConnectSessionsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final manager = ref.watch(walletConnectManagerProvider);
    final sessions = manager.sessions;
    return Scaffold(
      appBar: AppBar(title: const Text('WalletConnect Sessions')),
      body: sessions.isEmpty
          ? const Center(child: Text('No sessions'))
          : ListView.separated(
              itemCount: sessions.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final s = sessions[index];
                return ListTile(
                  title: Text('Session ${s['id']}'),
                  subtitle: Text('Created: ${s['createdAt']}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.logout),
                    onPressed: () async {
                      await manager.revokeSession(s['id']);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Session revoked')));
                    },
                  ),
                );
              },
            ),
    );
  }
}
