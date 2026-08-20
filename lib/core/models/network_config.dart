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

  const NetworkConfig({
    required this.id,
    required this.name,
    required this.chainId,
    required this.symbol,
    required this.rpcUrl,
    this.wsRpcUrl,
    this.explorerUrl = '',
    this.decimals = 18,
    this.isTestnet = false,
  });

  NetworkConfig copyWith({
    String? rpcUrl,
    String? wsRpcUrl,
    String? name,
    String? explorerUrl,
    int? decimals,
    bool? isTestnet,
  }) {
    return NetworkConfig(
      id: id,
      name: name ?? this.name,
      chainId: chainId,
      symbol: symbol,
      rpcUrl: rpcUrl ?? this.rpcUrl,
      wsRpcUrl: wsRpcUrl ?? this.wsRpcUrl,
      explorerUrl: explorerUrl ?? this.explorerUrl,
      decimals: decimals ?? this.decimals,
      isTestnet: isTestnet ?? this.isTestnet,
    );
  }
}
