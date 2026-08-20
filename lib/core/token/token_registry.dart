import 'dart:convert';

import 'package:convert/convert.dart';

import '../models/token_config.dart';
import '../models/network_config.dart';
import '../network/rpc_manager.dart';

class TokenRegistry {
  final RpcManager _rpc;
  final Map<String, TokenConfig> _tokens = {};

  TokenRegistry(this._rpc);

  void addToken(TokenConfig token) {
    _tokens[token.address.toLowerCase()] = token;
  }

  TokenConfig? getToken(String address) => _tokens[address.toLowerCase()];

  Future<Map<String, dynamic>> fetchTokenMetadata(String tokenAddress) async {
    // ERC20: name() -> 0x06fdde03, symbol() -> 0x95d89b41, decimals() -> 0x313ce567
    final nameData = '0x06fdde03';
    final symbolData = '0x95d89b41';
    final decimalsData = '0x313ce567';

    final nameResp = await _rpc.ethCall({'to': tokenAddress, 'data': nameData});
    final symbolResp = await _rpc.ethCall({'to': tokenAddress, 'data': symbolData});
    final decimalsResp = await _rpc.ethCall({'to': tokenAddress, 'data': decimalsData});

    final name = _decodeStringResult(nameResp as String?);
    final symbol = _decodeStringResult(symbolResp as String?);
    final decimals = _decodeUint256(decimalsResp as String?);

    return {'name': name ?? '', 'symbol': symbol ?? '', 'decimals': decimals ?? 18};
  }

  Future<BigInt> getTokenBalanceRaw(String tokenAddress, String ownerAddress) async {
    final cleanOwner = ownerAddress.toLowerCase().replaceFirst('0x', '').padLeft(64, '0');
    final data = '0x70a08231' + cleanOwner;
    final resp = await _rpc.ethCall({'to': tokenAddress, 'data': data});
    return _decodeUint256(resp as String? ?? '0x0') ?? BigInt.zero;
  }

  Future<String> getTokenBalanceFormatted(String tokenAddress, String ownerAddress) async {
    final meta = await fetchTokenMetadata(tokenAddress);
    final decimals = meta['decimals'] as int;
    final raw = await getTokenBalanceRaw(tokenAddress, ownerAddress);
    final divisor = BigInt.from(10).pow(decimals);
    final whole = raw ~/ divisor;
    final fraction = raw % divisor;
    // Simple formatting
    return '$whole.${fraction.toString().padLeft(decimals, '0')}';
  }

  String? _decodeStringResult(String? hexString) {
    if (hexString == null || hexString == '0x') return null;
    // Some tokens return dynamic offset-encoded strings; for simplicity attempt to decode ascii from hex
    try {
      final cleaned = hexString.replaceFirst('0x', '');
      final bytes = hex.decode(cleaned);
      // remove nulls
      final trimmed = bytes.takeWhile((b) => b != 0).toList();
      return String.fromCharCodes(trimmed);
    } catch (e) {
      return null;
    }
  }

  BigInt? _decodeUint256(String? hexString) {
    if (hexString == null || hexString == '0x') return null;
    try {
      return BigInt.parse(hexString.replaceFirst('0x', ''), radix: 16);
    } catch (e) {
      return null;
    }
  }
}
