import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:pointycastle/export.dart';

import 'secure_storage_service.dart';
import 'native_keystore.dart';

/// Envelope encryption helper that wraps the symmetric key using a native hardware-backed keystore
/// when available. The wrapped symmetric key is stored in secure storage; the native keystore
/// enforces device authentication when unwrapping.
class EnvelopeCrypto {
  static const _wrappedKeyStorage = 'envelope_wrap_key_wrapped_v1';
  static const _encryptedSeedKey = 'vault_seed_enc_v1';

  static Uint8List _randomBytes(int len) {
    final rnd = Random.secure();
    return Uint8List.fromList(List<int>.generate(len, (_) => rnd.nextInt(256)));
  }

  static Future<void> storeEncryptedSeed(SecureStorageService storage, String seedHex) async {
    // generate ephemeral symmetric key
    final symKey = _randomBytes(32);
    // ensure native keystore exists
    await NativeKeystore.ensureWrapKey();
    // wrap the symmetric key using native keystore
    final wrapped = await NativeKeystore.wrapKey(symKey);

    // encrypt seed with symKey using AES-GCM
    final nonce = _randomBytes(12);
    final cipher = GCMBlockCipher(AESEngine());
    final params = AEADParameters(KeyParameter(symKey), 128, nonce, Uint8List(0));
    cipher.init(true, params);
    final seedBytes = _hexDecode(seedHex);
    final out = cipher.process(seedBytes);
    final combined = Uint8List(nonce.length + out.length)..setAll(0, nonce)..setAll(nonce.length, out);

    // store wrapped symmetric key (base64) and ciphertext
    await storage.write(_wrappedKeyStorage, wrapped);
    await storage.write(_encryptedSeedKey, base64Url.encode(combined));
  }

  static Future<String?> readDecryptedSeed(SecureStorageService storage) async {
    final wrapped = await storage.read(_wrappedKeyStorage);
    final raw = await storage.read(_encryptedSeedKey);
    if (wrapped == null || raw == null) return null;

    // unwrap symmetric key via native keystore (may prompt for auth)
    final symKeyBytes = await NativeKeystore.unwrapKey(wrapped);
    final combined = base64Url.decode(raw);
    final nonce = combined.sublist(0, 12);
    final cipherText = combined.sublist(12);
    final cipher = GCMBlockCipher(AESEngine());
    final params = AEADParameters(KeyParameter(symKeyBytes), 128, nonce, Uint8List(0));
    cipher.init(false, params);
    try {
      final plain = cipher.process(Uint8List.fromList(cipherText));
      return _hexEncode(plain);
    } catch (e) {
      return null;
    }
  }

  static List<int> _hexDecode(String hex) {
    var h = hex;
    if (h.startsWith('0x')) h = h.substring(2);
    if (h.length % 2 == 1) h = '0$h';
    final bytes = <int>[];
    for (var i = 0; i < h.length; i += 2) {
      bytes.add(int.parse(h.substring(i, i + 2), radix: 16));
    }
    return bytes;
  }

  static String _hexEncode(Uint8List bytes) {
    final sb = StringBuffer();
    for (final b in bytes) sb.write(b.toRadixString(16).padLeft(2, '0'));
    return sb.toString();
  }
}
