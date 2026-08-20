import 'package:flutter_test/flutter_test.dart';
import 'package:bip39/bip39.dart' as bip39;

void main() {
  test('generate mnemonic and validate', () {
    final mnemonic = bip39.generateMnemonic();
    expect(mnemonic.split(' ').length, anyOf(12, 24));
    expect(bip39.validateMnemonic(mnemonic), isTrue);
  });
}
