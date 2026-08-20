import 'dart:convert';

import 'package:dio/dio.dart';

import '../models/network_config.dart';

class RpcException implements Exception {
  final String message;
  RpcException(this.message);
  @override
  String toString() => 'RpcException: $message';
}

/// Simple JSON-RPC manager using Dio. Supports switching network at runtime.
class RpcManager {
  late NetworkConfig _network;
  final Dio _dio;

  RpcManager(NetworkConfig initialNetwork)
      : _network = initialNetwork,
        _dio = Dio(BaseOptions(baseUrl: initialNetwork.rpcUrl, connectTimeout: const Duration(seconds: 8), receiveTimeout: const Duration(seconds: 20)));

  NetworkConfig get currentNetwork => _network;

  void switchNetwork(NetworkConfig network) {
    _network = network;
    _dio.options.baseUrl = network.rpcUrl;
  }

  Future<dynamic> _postRpc(String method, List params) async {
    final body = {'jsonrpc': '2.0', 'id': DateTime.now().millisecondsSinceEpoch, 'method': method, 'params': params};
    try {
      final r = await _dio.post('', data: body);
      if (r.statusCode == 200) {
        if (r.data['error'] != null) throw RpcException(r.data['error'].toString());
        return r.data;
      } else {
        throw RpcException('RPC error: ${r.statusCode}');
      }
    } on DioError catch (e) {
      throw RpcException('Network error: ${e.message}');
    }
  }

  Future<String> sendRawTransaction(String signedTxHex) async {
    final resp = await _postRpc('eth_sendRawTransaction', [signedTxHex]);
    return resp['result'] as String;
  }

  Future<String> getBalance(String address) async {
    final resp = await _postRpc('eth_getBalance', [address, 'latest']);
    return resp['result'] as String;
  }

  Future<int> getBlockNumber() async {
    final resp = await _postRpc('eth_blockNumber', []);
    final hex = resp['result'] as String;
    return int.parse(hex.substring(2), radix: 16);
  }

  Future<dynamic> getTransactionByHash(String txHash) async {
    final resp = await _postRpc('eth_getTransactionByHash', [txHash]);
    return resp['result'];
  }

  Future<String> estimateGas(Map<String, dynamic> tx) async {
    final resp = await _postRpc('eth_estimateGas', [tx]);
    return resp['result'] as String;
  }

  Future<String> getNonce(String address) async {
    final resp = await _postRpc('eth_getTransactionCount', [address, 'pending']);
    return resp['result'] as String;
  }

  Future<dynamic> getLogs(Map<String, dynamic> filter) async {
    final resp = await _postRpc('eth_getLogs', [filter]);
    return resp['result'];
  }

  Future<dynamic> ethCall(Map<String, dynamic> call, {String block = 'latest'}) async {
    final resp = await _postRpc('eth_call', [call, block]);
    return resp['result'];
  }

  // TODO: add getTokenBalance helper using eth_call (handled in TokenRegistry)
}
