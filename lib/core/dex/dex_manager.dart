import 'package:flutter/foundation.dart';

import '../dex/dex_service.dart';
import '../dex/one_inch_adapter.dart';

/// DexManager acts as a facade. Swaps are disabled by default via configuration. The adapter is prepared
/// but swap execution is intentionally disabled until the UI or settings enable it.
class DexManager implements DexService {
  final OneInchAdapter _oneInch;
  final bool enabled;

  DexManager({OneInchAdapter? oneInchAdapter, this.enabled = false}) : _oneInch = oneInchAdapter ?? OneInchAdapter();

  @override
  Future<Map<String, dynamic>> getQuote({required int chainId, required String fromToken, required String toToken, required String amount}) async {
    if (!enabled) throw Exception('Swaps are currently disabled');
    final quote = await _oneInch.getQuote(chainId, fromToken: fromToken, toToken: toToken, amount: amount);
    return {
      'fromTokenAmount': quote.fromTokenAmount,
      'toTokenAmount': quote.toTokenAmount,
      'estimatedGas': quote.estimatedGas,
    };
  }

  @override
  Future<Map<String, dynamic>> buildSwapTransaction({required int chainId, required String fromToken, required String toToken, required String amount, required String fromAddress, double slippage = 1.0}) async {
    if (!enabled) throw Exception('Swaps are currently disabled');
    final tx = await _oneInch.buildSwapTransaction(chainId: chainId, fromToken: fromToken, toToken: toToken, amount: amount, fromAddress: fromAddress, slippage: slippage);
    return {
      'to': tx.to,
      'data': tx.data,
      'value': tx.value,
      'gas': tx.gas,
      'gasPrice': tx.gasPrice,
    };
  }
}
