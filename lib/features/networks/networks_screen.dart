import 'package:flutter/material.dart';

import '../../features/networks/networks_service.dart';

class NetworksScreen extends StatefulWidget {
  const NetworksScreen({Key? key}) : super(key: key);

  @override
  State<NetworksScreen> createState() => _NetworksScreenState();
}

class _NetworksScreenState extends State<NetworksScreen> {
  late final NetworksService _svc;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _svc = NetworksService();
    _init();
  }

  Future<void> _init() async {
    await _svc.init();
    setState(() => _loading = false);
  }

  Future<void> _editNetwork(String id) async {
    final n = _svc.networks.firstWhere((e) => e.id == id);
    final nameCtrl = TextEditingController(text: n.name);
    final rpcCtrl = TextEditingController(text: n.rpcUrl);
    final explorerCtrl = TextEditingController(text: n.explorerUrl);
    final res = await showDialog<bool>(context: context, builder: (ctx) {
      return AlertDialog(
        title: const Text('Edit Network'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name')),
          TextField(controller: rpcCtrl, decoration: const InputDecoration(labelText: 'RPC URL')),
          TextField(controller: explorerCtrl, decoration: const InputDecoration(labelText: 'Explorer URL')),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Save')),
        ],
      );
    });
    if (res == true) {
      final updated = n.copyWith(rpcUrl: rpcCtrl.text.trim(), name: nameCtrl.text.trim(), explorerUrl: explorerCtrl.text.trim());
      await _svc.updateNetwork(updated);
      setState(() {});
    }
  }

  Future<void> _setActive(String id) async {
    await _svc.setActiveNetwork(id);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Networks')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              itemCount: _svc.networks.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final n = _svc.networks[index];
                final active = _svc.activeNetwork?.id == n.id;
                return ListTile(
                  title: Text(n.name),
                  subtitle: Text('chainId: ${n.chainId} • RPC: ${n.rpcUrl.isEmpty ? 'none' : n.rpcUrl}'),
                  trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                    if (!active) IconButton(icon: const Icon(Icons.check), onPressed: () => _setActive(n.id)),
                    IconButton(icon: const Icon(Icons.edit), onPressed: () => _editNetwork(n.id)),
                  ]),
                );
              },
            ),
    );
  }
}
