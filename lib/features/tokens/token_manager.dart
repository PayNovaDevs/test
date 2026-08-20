import 'dart:convert';

import '../../core/security/secure_storage_service.dart';

class TokenInfo {
  final String address;
  final String symbol;
  final int decimals;
  final String name;

  TokenInfo({required this.address, required this.symbol, required this.decimals, required this.name});

  Map<String, dynamic> toJson() => {'address': address, 'symbol': symbol, 'decimals': decimals, 'name': name};

  static TokenInfo fromJson(Map<String, dynamic> j) => TokenInfo(address: j['address'], symbol: j['symbol'], decimals: j['decimals'], name: j['name']);
}

class TokenManager {
  static const _key = 'tokens_list_v1';
  final SecureStorageService _storage;
  final List<TokenInfo> _tokens = [];

  TokenManager(this._storage);

  List<TokenInfo> get tokens => List.unmodifiable(_tokens);

  Future<void> init() async {
    final raw = await _storage.read(_key);
    if (raw == null) return;
    try {
      final arr = jsonDecode(raw) as List<dynamic>;
      _tokens.clear();
      for (final e in arr) {
        _tokens.add(TokenInfo.fromJson(e as Map<String, dynamic>));
      }
    } catch (_) {}
  }

  Future<void> addToken(TokenInfo token) async {
    _tokens.add(token);
    await _persist();
  }

  Future<void> _persist() async {
    final raw = jsonEncode(_tokens.map((t) => t.toJson()).toList());
    await _storage.write(_key, raw);
  }

  Future<void> removeToken(String address) async {
    _tokens.removeWhere((t) => t.address.toLowerCase() == address.toLowerCase());
    await _persist();
  }
}
