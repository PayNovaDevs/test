import 'package:flutter_test/flutter_test.dart';
import 'package:dex_wallet/core/transactions/fee_utils.dart';

void main() {
  test('hexToBigInt should parse hex strings', () {
    expect(hexToBigInt('0x0'), BigInt.zero);
    expect(hexToBigInt('0x1a'), BigInt.from(26));
    expect(hexToBigInt('1a'), BigInt.from(26));
  });

  test('weiToEth conversion basic', () {
    final wei = BigInt.parse('1000000000000000000');
    expect(weiToEth(wei), 1.0);
    final half = BigInt.parse('500000000000000000');
    expect(weiToEth(half), 0.5);
  });

  test('estimateTotalFeeEth basic', () {
    final gasLimit = 21000;
    final maxFee = BigInt.parse('1000000000'); // 1 gwei
    final total = estimateTotalFeeEth(gasLimit, maxFee);
    expect(total, isNonZero);
  });
}
