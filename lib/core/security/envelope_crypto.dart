import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:pointycastle/export.dart';

import 'secure_storage_service.dart';

/// Envelope encryption helper using AES-GCM with a randomly generated wrapping key stored in secure storage.
///
/// NOTE: This improves over storing seed plaintext directly by encrypting it with a symmetric key
/// and storing only the ciphertext. The wrapping key itself is stored in SecureStorage (OS-backed)
/// — for production prefer hardware-backed keystore or platform-provided key protection.
class EnvelopeCrypto {
  static const _wrapKeyStorageKey = 'envelope_wrap_key_v1';
  static const _encryptedSeedKey = 'vault_seed_enc_v1';

  /// Ensure a wrapping key exists and return it as raw bytes.
  static Future<Uint8List> _ensureWrapKey(SecureStorageService storage) async {
    final existing = await storage.read(_wrapKeyStorageKey);
    if (existing != null && existing.isNotEmpty) {
      return base64Url.decode(existing);
    }
    final rnd = Random.secure();
    final key = Uint8List.fromList(List<int>.generate(32, (_) => rnd.nextInt(256)));
    await storage.write(_wrapKeyStorageKey, base64Url.encode(key));
    return key;
  }

  static Future<void> storeEncryptedSeed(SecureStorageService storage, String seedHex) async {
    final key = await _ensureWrapKey(storage);
    final nonce = _randomBytes(12);

    final cipher = GCMBlockCipher(AESEngine());
    final aeadParams = AEADParameters(KeyParameter(key), 128, nonce, Uint8List(0));
    cipher.init(true, aeadParams);

    final seedBytes = Uint8List.fromList(hexDecode(seedHex));
    final out = cipher.process(seedBytes);

    // store as base64(nonce + ciphertext)
    final combined = Uint8List(nonce.length + out.length)..setAll(0, nonce)..setAll(nonce.length, out);
    await storage.write(_encryptedSeedKey, base64Url.encode(combined));
  }

  static Future<String?> readDecryptedSeed(SecureStorageService storage) async {
    final raw = await storage.read(_encryptedSeedKey);
    if (raw == null) return null;
    final combined = base64Url.decode(raw);
    if (combined.length < 13) return null;
    final nonce = combined.sublist(0, 12);
    final cipherText = combined.sublist(12);

    final keyB64 = await storage.read(_wrapKeyStorageKey);
    if (keyB64 == null) return null;
    final key = base64Url.decode(keyB64);

    final cipher = GCMBlockCipher(AESEngine());
    final aeadParams = AEADParameters(KeyParameter(Uint8List.fromList(key)), 128, Uint8List.fromList(nonce), Uint8List(0));
    cipher.init(false, aeadParams);

    try {
      final plain = cipher.process(Uint8List.fromList(cipherText));
      return hexEncode(plain);
    } catch (e) {
      return null;
    }
  }

  static Uint8List _randomBytes(int len) {
    final rnd = Random.secure();
    return Uint8List.fromList(List<int>.generate(len, (_) => rnd.nextInt(256)));
  }

  // lightweight hex helpers
  static List<int> hexDecode(String hex) {
    var h = hex;
    if (h.startsWith('0x')) h = h.substring(2);
    if (h.length % 2 == 1) h = '0$h';
    final bytes = <int>[];
    for (var i = 0; i < h.length; i += 2) {
      bytes.add(int.parse(h.substring(i, i + 2), radix: 16));
    }
    return bytes;
  }

  static String hexEncode(Uint8List bytes) {
    final sb = StringBuffer();
    for (final b in bytes) {
      sb.write(b.toRadixString(16).padLeft(2, '0'));
    }
    return sb.toString();
  }
}
