import 'package:dio/dio.dart';

class OneInchQuote {
  final String fromTokenAddress;
  final String toTokenAddress;
  final String fromTokenAmount; // integer amount in token smallest units
  final String toTokenAmount;
  final double estimatedGas;

  OneInchQuote({required this.fromTokenAddress, required this.toTokenAddress, required this.fromTokenAmount, required this.toTokenAmount, required this.estimatedGas});
}

class OneInchSwapTx {
  final String to; // contract address
  final String data; // calldata hex
  final String value; // wei hex
  final int gas; // estimated gas
  final String gasPrice; // optional

  OneInchSwapTx({required this.to, required this.data, required this.value, required this.gas, required this.gasPrice});
}

/// Adapter to 1inch API (v5) for quotes and building swap transactions.
///
/// Note: 1inch public API endpoints can be used without an API key for quotes in many cases,
/// but for production and higher rate limits consider obtaining an API key. Do NOT store keys
/// in the repository. See README for .env.example and instructions.
class OneInchAdapter {
  final Dio _dio;
  final String base;

  OneInchAdapter({Dio? dio, this.base = 'https://api.1inch.io/v5.0'}) : _dio = dio ?? Dio();

  /// Get a quote from 1inch. chainId is required (e.g. 1 for Ethereum, 56 for BSC).
  /// fromToken and toToken use token addresses or '0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE' for native.
  Future<OneInchQuote> getQuote(int chainId, {required String fromToken, required String toToken, required String amount}) async {
    final url = '\$base/\$chainId/quote';
    final resp = await _dio.get(url, queryParameters: {'fromTokenAddress': fromToken, 'toTokenAddress': toToken, 'amount': amount});
    if (resp.statusCode == 200) {
      final data = resp.data as Map<String, dynamic>;
      final toAmount = data['toTokenAmount'] as String;
      final fromAmount = data['fromTokenAmount'] as String;
      final estimatedGas = (data['estimatedGas'] as num).toDouble();
      return OneInchQuote(fromTokenAddress: fromToken, toTokenAddress: toToken, fromTokenAmount: fromAmount, toTokenAmount: toAmount, estimatedGas: estimatedGas);
    } else {
      throw Exception('1inch quote failed with status code: \\${resp.statusCode}');
    }
  }

  /// Build a swap transaction payload using 1inch API. This does not execute the swap.
  /// The returned OneInchSwapTx contains tx.to, tx.data, tx.value, and estimated gas.
  /// You should present the tx details to the user and then sign it locally in the Vault.
  Future<OneInchSwapTx> buildSwapTransaction({required int chainId, required String fromToken, required String toToken, required String amount, required String fromAddress, double slippage = 1.0, String? referrerAddress}) async {
    // The 1inch swap endpoint constructs the transaction for the user to send. We request the 'tx' object.
    final url = '\$base/\$chainId/swap';
    final params = {
      'fromTokenAddress': fromToken,
      'toTokenAddress': toToken,
      'amount': amount,
      'fromAddress': fromAddress,
      'slippage': slippage.toString(),
    };
    if (referrerAddress != null && referrerAddress.isNotEmpty) params['referrerAddress'] = referrerAddress;

    final resp = await _dio.get(url, queryParameters: params);
    if (resp.statusCode == 200) {
      final data = resp.data as Map<String, dynamic>;
      final tx = data['tx'] as Map<String, dynamic>;
      final to = tx['to'] as String;
      final txData = tx['data'] as String;
      final value = tx['value'] as String? ?? '0x0';
      final gas = (tx['gas'] as int?) ?? (data['estimatedGas'] as int? ?? 0);
      final gasPrice = tx['gasPrice']?.toString() ?? '';
      return OneInchSwapTx(to: to, data: txData, value: value, gas: gas, gasPrice: gasPrice);
    } else {
      throw Exception('1inch swap build failed with status code: \\${resp.statusCode}');
    }
  }
}
