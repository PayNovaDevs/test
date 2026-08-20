import 'dart:convert';
import 'dart:typed_data';

import 'package:bip32/bip32.dart' as bip32;
import 'package:convert/convert.dart';
import 'package:web3dart/web3dart.dart';
import 'package:web3dart/crypto.dart' as crypto;

import '../../security/secure_storage_service.dart';
import '../hd_wallet_service.dart';
import '../../security/envelope_crypto.dart';

/// Concrete HdWalletService implementation using bip39 + bip32 + web3dart.
///
/// NOTE: This implementation stores the seed encrypted using EnvelopeCrypto. For
/// production you should prefer hardware-backed key protection for the wrapping key.
class HdWalletServiceImpl implements HdWalletService {
  final SecureStorageService _secureStorage;
  static const _seedKey = 'vault_seed_hex'; // legacy key kept for compatibility but not used
  HdWalletServiceImpl(this._secureStorage);

  @override
  Future<void> storeSeedHexSecurely(String seedHex) async {
    // store encrypted seed using envelope
    await EnvelopeCrypto.storeEncryptedSeed(_secureStorage, seedHex);
  }

  Future<String?> _readSeedHex() async {
    final dec = await EnvelopeCrypto.readDecryptedSeed(_secureStorage);
    return dec; // hex string without 0x or null
  }

  /// Derive a private key for the given BIP44 index and return its hex representation (without 0x)
  Future<String> _derivePrivateKeyHexFromSeedHex(String seedHex, int index) async {
    final seed = hex.decode(seedHex);
    final root = bip32.BIP32.fromSeed(Uint8List.fromList(seed));
    // BIP44 path for Ethereum: m/44'/60'/0'/0/index
    final path = "m/44'/60'/0'/0/$index";
    final child = root.derivePath(path);
    final priv = child.privateKey;
    if (priv == null) throw Exception('Derived private key is null');
    return hex.encode(priv);
  }

  @override
  Future<String> deriveAddressAt(int index) async {
    final seedHex = await _readSeedHex();
    if (seedHex == null) throw Exception('Vault seed not found');
    final privHex = await _derivePrivateKeyHexFromSeedHex(seedHex, index);
    final credentials = EthPrivateKey.fromHex(privHex);
    final address = await credentials.extractAddress();
    return address.hex; // returns 0x...
  }

  @override
  Future<void> importPrivateKey(String privateKeyHex, int index) async {
    // Save private key hex into secure storage under a key for index.
    await _secureStorage.write('pk_$index', privateKeyHex);
  }

  Future<String> _getPrivateKeyHexForIndex(int index) async {
    final seedHex = await _readSeedHex();
    if (seedHex != null) {
      return await _derivePrivateKeyHexFromSeedHex(seedHex, index);
    }
    final pk = await _secureStorage.read('pk_$index');
    if (pk != null) return pk;
    throw Exception('No key material for index $index');
  }

  @override
  Future<String> signMessage(String message, int index) async {
    final pkHex = await _getPrivateKeyHexForIndex(index);
    final creds = EthPrivateKey.fromHex(pkHex);
    final msgBytes = Uint8List.fromList(utf8.encode(message));
    final sig = await creds.signPersonalMessage(msgBytes);
    return crypto.bytesToHex(sig, include0x: true);
  }

  @override
  Future<String> signTransaction(String unsignedTxRlpHex, int index) async {
    // Deprecated: prefer signTransactionObject for robust signing.
    throw UnsupportedError('Direct RLP signing is not supported. Use signTransactionObject.');
  }

  /// Higher level helper: sign a web3dart Transaction and return raw signed transaction hex.
  @override
  Future<String> signTransactionObject(dynamic tx, int index, int chainId) async {
    final pkHex = await _getPrivateKeyHexForIndex(index);
    final creds = EthPrivateKey.fromHex(pkHex);
    final signed = await creds.signTransaction(tx as Transaction, chainId: chainId);
    return crypto.bytesToHex(signed, include0x: true);
  }
}
