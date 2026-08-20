import 'dart:convert';

import 'package:convert/convert.dart';

import '../models/network_config.dart';
import 'rpc_manager.dart';

class NetworkRepository {
  final RpcManager _rpcManager;
  final Map<String, NetworkConfig> _networks = {};

  NetworkRepository(this._rpcManager);

  void addNetwork(NetworkConfig config) {
    _networks[config.id] = config;
  }

  NetworkConfig? getNetwork(String id) => _networks[id];

  Future<String> getBalance(String networkId, String address) async {
    final net = _networks[networkId];
    if (net == null) throw Exception('Network not found');
    _rpcManager.switchNetwork(net);
    final balanceHex = await _rpcManager.getBalance(address);
    return balanceHex;
  }
}
