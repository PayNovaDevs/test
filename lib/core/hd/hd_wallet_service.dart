abstract class HdWalletService {
  Future<void> storeSeedHexSecurely(String seedHex);
  Future<String> deriveAddressAt(int index);
  Future<String> signTransaction(String unsignedTx, int index);
  Future<String> signMessage(String message, int index);
  Future<void> importPrivateKey(String privateKeyHex, int index);

  /// Sign a web3dart Transaction object and return the raw signed transaction hex (0x...)
  Future<String> signTransactionObject(dynamic tx, int index, int chainId);
}
