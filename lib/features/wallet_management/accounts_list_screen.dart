import 'package:flutter/material.dart';

import '../../core/security/secure_storage_service.dart';
import '../../core/hd/impl/hd_wallet_service_impl.dart';
import '../../core/hd/hd_wallet_service.dart';
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
    final storage = SecureStorageService();
    final hd = HdWalletServiceImpl(storage);
    _manager = AccountManager(storage, hdService: hd);
    _init();
  }

  Future<void> _init() async {
    await _manager.init();
    setState(() => _loading = false);
    _manager.addListener(() => setState(() {}));
  }

  Future<void> _addAccountManual() async {
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

  Future<void> _addDerivedAccount() async {
    try {
      final acc = await _manager.createDerivedAccount();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Derived ${acc.address}')));
    } catch (e) {
      final create = await showDialog<bool>(context: context, builder: (ctx) {
        return AlertDialog(
          title: const Text('No seed'),
          content: const Text('No seed found in vault. Do you want to import a seed (hex) now?'),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
            ElevatedButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Import')),
          ],
        );
      });
      if (create == true) {
        final seed = await showDialog<String>(context: context, builder: (ctx) {
          final ctrl = TextEditingController();
          return AlertDialog(
            title: const Text('Import seed (hex)'),
            content: TextField(controller: ctrl, decoration: const InputDecoration(hintText: 'seed hex (no 0x)')),
            actions: [
              TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
              ElevatedButton(onPressed: () => Navigator.of(ctx).pop(ctrl.text.trim()), child: const Text('Import')),
            ],
          );
        });
        if (seed != null && seed.isNotEmpty) {
          await (HdWalletServiceImpl(_manager._storage)).storeSeedHexSecurely(seed);
          final acc = await _manager.createDerivedAccount();
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Derived ${acc.address}')));
        }
      }
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
      floatingActionButton: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
        FloatingActionButton.extended(onPressed: _addDerivedAccount, label: const Text('Derive'), icon: const Icon(Icons.auto_fix_high)),
        const SizedBox(height: 12),
        FloatingActionButton.extended(onPressed: _addAccountManual, label: const Text('Add'), icon: const Icon(Icons.add)),
      ]),
    );
  }
}
