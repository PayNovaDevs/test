import 'dart:convert';

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
    }
  ];

  final List<NetworkConfig> _networks = _defaultNetworks.map((e) => NetworkConfig.fromJson(e)).toList();

  List<NetworkConfig> get networks => List.unmodifiable(_networks);

  void addNetwork(NetworkConfig cfg) {
    _networks.add(cfg);
  }

  void removeNetwork(String id) {
    _networks.removeWhere((n) => n.id == id);
  }
}
