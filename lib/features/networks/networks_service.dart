import 'dart:convert';

import '../../core/security/secure_storage_service.dart';

class NetworkConfig {
  final String id;
  final String name;
  final int chainId;
  final String symbol;
  final String rpcUrl;
  final String? wsRpcUrl;
  final String explorerUrl;
  final int decimals;
  final bool isTestnet;

  NetworkConfig({required this.id, required this.name, required this.chainId, required this.symbol, required this.rpcUrl, this.wsRpcUrl, required this.explorerUrl, required this.decimals, required this.isTestnet});

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'chainId': chainId,
        'symbol': symbol,
        'rpcUrl': rpcUrl,
        'wsRpcUrl': wsRpcUrl,
        'explorerUrl': explorerUrl,
        'decimals': decimals,
        'isTestnet': isTestnet,
      };

  static NetworkConfig fromJson(Map<String, dynamic> j) => NetworkConfig(
        id: j['id'],
        name: j['name'],
        chainId: j['chainId'],
        symbol: j['symbol'],
        rpcUrl: j['rpcUrl'],
        wsRpcUrl: j['wsRpcUrl'],
        explorerUrl: j['explorerUrl'],
        decimals: j['decimals'],
        isTestnet: j['isTestnet'],
      );

  @override
  String toString() => jsonEncode(toJson());
}

class NetworksService {
  static const _storageKey = 'networks_v1';
  static const _activeKey = 'active_network_id';

  static const _defaultNetworks = <Map<String, dynamic>>[
    {
      'id': 'ethereum_mainnet',
      'name': 'Ethereum Mainnet',
      'chainId': 1,
      'symbol': 'ETH',
      'rpcUrl': '',
      'wsRpcUrl': null,
      'explorerUrl': 'https://etherscan.io',
      'decimals': 18,
      'isTestnet': false
    },
    {
      'id': 'goerli',
      'name': 'Goerli Testnet',
      'chainId': 5,
      'symbol': 'ETH',
      'rpcUrl': '',
      'wsRpcUrl': null,
      'explorerUrl': 'https://goerli.etherscan.io',
      'decimals': 18,
      'isTestnet': true
    },
    {
      'id': 'bsc',
      'name': 'Binance Smart Chain',
      'chainId': 56,
      'symbol': 'BNB',
      'rpcUrl': '',
      'wsRpcUrl': null,
      'explorerUrl': 'https://bscscan.com',
      'decimals': 18,
      'isTestnet': false
    },
    {
      'id': 'bsc_testnet',
      'name': 'BSC Testnet',
      'chainId': 97,
      'symbol': 'BNB',
      'rpcUrl': '',
      'wsRpcUrl': null,
      'explorerUrl': 'https://testnet.bscscan.com',
      'decimals': 18,
      'isTestnet': true
    }
  ];

  final SecureStorageService _storage;
  final List<NetworkConfig> _networks = [];
  String? _activeNetworkId;

  NetworksService([SecureStorageService? storage]) : _storage = storage ?? SecureStorageService() {
    _loadDefaults();
  }

  void _loadDefaults() {
    _networks.clear();
    _networks.addAll(_defaultNetworks.map((e) => NetworkConfig.fromJson(e)).toList());
  }

  List<NetworkConfig> get networks => List.unmodifiable(_networks);

  Future<void> init() async {
    try {
      final raw = await _storage.read(_storageKey);
      if (raw != null) {
        final arr = jsonDecode(raw) as List<dynamic>;
        _networks.clear();
        for (final e in arr) {
          _networks.add(NetworkConfig.fromJson(e as Map<String, dynamic>));
        }
      }
      _activeNetworkId = await _storage.read(_activeKey);
    } catch (_) {
      // ignore
    }
  }

  NetworkConfig? get activeNetwork => _networks.firstWhere((n) => n.id == _activeNetworkId, orElse: () => _networks.first);

  Future<void> setActiveNetwork(String id) async {
    _activeNetworkId = id;
    await _storage.write(_activeKey, id);
  }

  Future<void> addNetwork(NetworkConfig cfg) async {
    _networks.add(cfg);
    await _persist();
  }

  Future<void> updateNetwork(NetworkConfig cfg) async {
    final i = _networks.indexWhere((n) => n.id == cfg.id);
    if (i != -1) _networks[i] = cfg;
    await _persist();
  }

  Future<void> removeNetwork(String id) async {
    _networks.removeWhere((n) => n.id == id);
    await _persist();
  }

  Future<void> _persist() async {
    final raw = jsonEncode(_networks.map((n) => n.toJson()).toList());
    await _storage.write(_storageKey, raw);
  }
}
