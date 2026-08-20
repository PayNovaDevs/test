/// HdWalletService defines an abstraction for HD derivation and signing.
/// Implementations must ensure private keys and seed material are kept inside secure storage
/// and are NOT exposed to UI layers.
abstract class HdWalletService {
  /// Store the seed (hex) securely. Implementations decide how to encrypt/wrap it.
  Future<void> storeSeedHexSecurely(String seedHex);

  /// Derive the address at the provided index (BIP44 path convention expected externally)
  Future<String> deriveAddressAt(int index);

  /// Sign a serialized transaction payload. The implementation must locate the private key
  /// associated with the derivation index and sign locally.
  Future<String> signTransaction(String unsignedTx, int index);

  /// Sign an arbitrary message using the account at index
  Future<String> signMessage(String message, int index);

  /// Import an external private key into the secure store at the provided index
  Future<void> importPrivateKey(String privateKeyHex, int index);
}
