import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../core/security/secure_storage_service.dart';
import '../../core/hd/hd_wallet_service.dart';
import 'account_model.dart';

/// AccountManager enhanced to support deriving addresses from the HD wallet service
/// and persisting accounts. If HdWalletService is available (seed stored), createDerivedAccount
/// will derive an address for the next index; otherwise you can still create a manual account.
class AccountManager with ChangeNotifier {
  static const _key = 'accounts_list_v1';
  final SecureStorageService _storage;
  final HdWalletService? _hdService;
  final List<AccountModel> _accounts = [];

  AccountManager(this._storage, {HdWalletService? hdService}) : _hdService = hdService;

  List<AccountModel> get accounts => List.unmodifiable(_accounts);

  Future<void> init() async {
    final raw = await _storage.read(_key);
    if (raw == null) return;
    try {
      final arr = jsonDecode(raw) as List<dynamic>;
      _accounts.clear();
      for (final e in arr) {
        _accounts.add(AccountModel.fromJson(e as Map<String, dynamic>));
      }
      notifyListeners();
    } catch (_) {
      // ignore parse errors
    }
  }

  Future<void> _persist() async {
    final raw = jsonEncode(_accounts.map((e) => e.toJson()).toList());
    await _storage.write(_key, raw);
  }

  /// Create a new manual account using the provided address.
  Future<AccountModel> createAccount({required String address, String? alias}) async {
    final idx = _accounts.isEmpty ? 0 : (_accounts.map((a) => a.index).reduce((a, b) => a > b ? a : b) + 1);
    final acc = AccountModel(address: address, index: idx, alias: alias ?? 'Account #${idx + 1}');
    _accounts.add(acc);
    await _persist();
    notifyListeners();
    return acc;
  }

  /// Create a derived account using the HD wallet service. If hdService is null or seed missing, throws.
  Future<AccountModel> createDerivedAccount({String? alias}) async {
    if (_hdService == null) throw Exception('HD wallet service not configured');
    final nextIndex = _accounts.isEmpty ? 0 : (_accounts.map((a) => a.index).reduce((a, b) => a > b ? a : b) + 1);
    final addr = await _hdService!.deriveAddressAt(nextIndex);
    final acc = AccountModel(address: addr, index: nextIndex, alias: alias ?? 'Account #${nextIndex + 1}');
    _accounts.add(acc);
    await _persist();
    notifyListeners();
    return acc;
  }

  Future<void> removeAccount(int index) async {
    _accounts.removeWhere((a) => a.index == index);
    await _persist();
    notifyListeners();
  }

  Future<void> renameAccount(int index, String newAlias) async {
    final i = _accounts.indexWhere((a) => a.index == index);
    if (i == -1) return;
    final old = _accounts[i];
    _accounts[i] = AccountModel(address: old.address, index: old.index, alias: newAlias, createdAt: old.createdAt);
    await _persist();
    notifyListeners();
  }
}
