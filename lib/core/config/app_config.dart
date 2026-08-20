import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/network_config.dart';
import '../../security/secure_storage_service.dart';

/// AppConfig loads networks from assets and allows runtime overrides persisted locally.
class AppConfig {
  static const _networksKey = 'app_networks_override';

  final SecureStorageService _storage;
  List<NetworkConfig> _networks = [];

  AppConfig(this._storage);

  /// Load default networks from assets and merge with any saved overrides.
  Future<void> load() async {
    final raw = await rootBundle.loadString('assets/networks.json');
    final parsed = jsonDecode(raw) as List<dynamic>;
    _networks = parsed.map((e) => _fromJson(e as Map<String, dynamic>)).toList();

    final override = await _storage.read(_networksKey);
    if (override != null) {
      try {
        final ov = jsonDecode(override) as List<dynamic>;
        final overrideList = ov.map((e) => _fromJson(e as Map<String, dynamic>)).toList();
        // Merge overrides by id (override existing or add new)
        for (final o in overrideList) {
          final idx = _networks.indexWhere((n) => n.id == o.id);
          if (idx >= 0) _networks[idx] = o;
          else _networks.add(o);
        }
      } catch (e) {
        // ignore malformed overrides
      }
    }
  }

  List<NetworkConfig> get networks => List.unmodifiable(_networks);

  Future<void> addOrUpdateNetwork(NetworkConfig cfg) async {
    final idx = _networks.indexWhere((n) => n.id == cfg.id);
    if (idx >= 0) _networks[idx] = cfg;
    else _networks.add(cfg);
    await _persistOverrides();
  }

  Future<void> removeNetwork(String id) async {
    _networks.removeWhere((n) => n.id == id);
    await _persistOverrides();
  }

  Future<void> _persistOverrides() async {
    final jsonList = _networks.map((n) => _toJson(n)).toList();
    await _storage.write(_networksKey, jsonEncode(jsonList));
  }

  NetworkConfig _fromJson(Map<String, dynamic> json) => NetworkConfig(
        id: json['id'] as String,
        name: json['name'] as String,
        chainId: json['chainId'] as int,
        symbol: json['symbol'] as String,
        rpcUrl: json['rpcUrl'] as String,
        wsRpcUrl: json['wsRpcUrl'] as String?,
        explorerUrl: json['explorerUrl'] as String? ?? '',
        decimals: json['decimals'] as int? ?? 18,
        isTestnet: json['isTestnet'] as bool? ?? false,
      );

  Map<String, dynamic> _toJson(NetworkConfig n) => {
        'id': n.id,
        'name': n.name,
        'chainId': n.chainId,
        'symbol': n.symbol,
        'rpcUrl': n.rpcUrl,
        'wsRpcUrl': n.wsRpcUrl,
        'explorerUrl': n.explorerUrl,
        'decimals': n.decimals,
        'isTestnet': n.isTestnet,
      };
}
