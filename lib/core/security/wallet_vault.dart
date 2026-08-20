import 'package:bip39/bip39.dart' as bip39;
import '../models/wallet_account.dart';
import '../hd/hd_wallet_service.dart';
import 'secure_storage_service.dart';

/// WalletVault is the single place responsible for key material handling.
/// It exposes only high-level operations and never returns raw private keys or mnemonics.
class WalletVault {
  final SecureStorageService _storage;
  final HdWalletService _hdService;

  WalletVault(this._storage, this._hdService);

  /// Generate a mnemonic (12 words by default -> 128 bits strength)
  Future<String> generateMnemonic({int strength = 128}) async {
    final mnemonic = bip39.generateMnemonic(strength: strength);
    // NEVER log or print the mnemonic
    return mnemonic;
  }

  /// Import an existing mnemonic into the vault. This validates checksum and delegates
  /// secure storage / derivation to HdWalletService.
  Future<void> importMnemonic(String mnemonic, {String? passphrase}) async {
    if (!bip39.validateMnemonic(mnemonic)) {
      throw InvalidMnemonicException();
    }
    // Convert mnemonic to seed hex and store it securely via HdWalletService.
    final seedHex = bip39.mnemonicToSeedHex(mnemonic, passphrase: passphrase);
    await _hdService.storeSeedHexSecurely(seedHex);
  }

  /// Derive an account (public data only) at a given index.
  Future<WalletAccount> deriveAccount(int index, {String name = 'Account'}) async {
    final address = await _hdService.deriveAddressAt(index);
    return WalletAccount(id: '${address}_$index', name: name, address: address, derivationIndex: index);
  }

  /// Sign a transaction (unsignedTx should be a serialized payload expected by HdWalletService)
  Future<String> signTransaction(String unsignedTx, int derivationIndex) async {
    return _hdService.signTransaction(unsignedTx, derivationIndex);
  }

  /// Sign a message with the account at derivationIndex
  Future<String> signMessage(String message, int derivationIndex) async {
    return _hdService.signMessage(message, derivationIndex);
  }
}

class InvalidMnemonicException implements Exception {}
