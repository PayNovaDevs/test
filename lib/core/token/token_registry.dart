import 'dart:math';

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

  Future<String> getTokenBalance(String tokenAddress, String ownerAddress) async {
    // ERC20 balanceOf signature: 0x70a08231 + padded address
    final cleanOwner = ownerAddress.toLowerCase().replaceFirst('0x', '');
    final data = '0x70a08231' + cleanOwner.padLeft(64, '0');
    final resp = await _rpc.ethCall({'to': tokenAddress, 'data': data});
    // resp is hex value
    return resp as String;
  }
}
