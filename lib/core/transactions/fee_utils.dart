import 'dart:math';

import 'package:convert/convert.dart';

BigInt hexToBigInt(String hex) {
  var h = hex;
  if (h.startsWith('0x')) h = h.substring(2);
  if (h.isEmpty) return BigInt.zero;
  return BigInt.parse(h, radix: 16);
}

/// Convert wei (BigInt) to double Ether value. Warning: this uses double and may lose precision for very large values.
double weiToEth(BigInt wei) {
  final ethBase = BigInt.from(1000000000000000000); // 1e18
  final whole = wei ~/ ethBase;
  final remainder = wei % ethBase;
  return whole.toDouble() + remainder.toDouble() / ethBase.toDouble();
}

/// Convert wei to Gwei as double
double weiToGwei(BigInt wei) {
  final gweiBase = BigInt.from(1000000000); // 1e9
  final whole = wei ~/ gweiBase;
  final remainder = wei % gweiBase;
  return whole.toDouble() + remainder.toDouble() / gweiBase.toDouble();
}

String formatEth(double eth) {
  if (eth >= 1) return '\${eth.toStringAsFixed(4)}';
  return '\${eth.toStringAsFixed(6)}';
}

String formatGwei(double gwei) {
  if (gwei >= 1) return '${gwei.toStringAsFixed(2)} Gwei';
  return '${gwei.toStringAsFixed(4)} Gwei';
}

/// Estimate total fee in ETH given gasLimit and maxFeePerGas (wei)
double estimateTotalFeeEth(int gasLimit, BigInt maxFeePerGasWei) {
  final totalWei = BigInt.from(gasLimit) * maxFeePerGasWei;
  return weiToEth(totalWei);
}
