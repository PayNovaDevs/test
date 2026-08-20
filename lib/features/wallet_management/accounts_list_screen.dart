import 'package:flutter/material.dart';

import '../../core/security/secure_storage_service.dart';
import 'account_manager.dart';

class AccountsListScreen extends StatefulWidget {
  const AccountsListScreen({Key? key}) : super(key: key);

  @override
  State<AccountsListScreen> createState() => _AccountsListScreenState();
}

class _AccountsListScreenState extends State<AccountsListScreen> {
  late final AccountManager _manager;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _manager = AccountManager(SecureStorageService());
    _init();
  }

  Future<void> _init() async {
    await _manager.init();
    setState(() => _loading = false);
    _manager.addListener(() => setState(() {}));
  }

  Future<void> _addAccount() async {
    // In a real app we'd derive from the HD wallet. For now ask the user for a placeholder address.
    final address = await showDialog<String>(context: context, builder: (ctx) {
      final ctrl = TextEditingController();
      return AlertDialog(
        title: const Text('Add account'),
        content: TextField(controller: ctrl, decoration: const InputDecoration(hintText: '0x...')),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.of(ctx).pop(ctrl.text.trim()), child: const Text('Add')),
        ],
      );
    });

    if (address != null && address.isNotEmpty) {
      await _manager.createAccount(address: address);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Accounts')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _manager.accounts.isEmpty
              ? const Center(child: Text('No accounts. Add one to get started.'))
              : ListView.separated(
                  itemCount: _manager.accounts.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final a = _manager.accounts[index];
                    return ListTile(
                      title: Text(a.alias),
                      subtitle: Text(a.address),
                      trailing: IconButton(icon: const Icon(Icons.delete), onPressed: () => _manager.removeAccount(a.index)),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(onPressed: _addAccount, label: const Text('Add'), icon: const Icon(Icons.add)),
    );
  }
}
