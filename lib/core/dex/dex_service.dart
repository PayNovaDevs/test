/// DexService defines the interface the app uses to obtain swap quotes and build swap transactions.
abstract class DexService {
  Future<Map<String, dynamic>> getQuote({required int chainId, required String fromToken, required String toToken, required String amount});

  /// Build swap transaction data for signing locally. Returns a map with at least: to, data, value, gas, gasPrice?
  Future<Map<String, dynamic>> buildSwapTransaction({required int chainId, required String fromToken, required String toToken, required String amount, required String fromAddress, double slippage});
}
