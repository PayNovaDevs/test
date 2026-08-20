import 'dart:convert';

import 'package:crypto/crypto.dart';

import 'secure_storage_service.dart';

/// PinService handles storing and verifying a 6-digit PIN using a salted SHA-256 hash.
/// This is intentionally simple: for production prefer hardware-backed key protection and
/// additional hardening (PBKDF2, iterations, key wrapping, rate-limiting, secure enclave usage).
class PinService {
  final SecureStorageService _storage;
  static const _key = 'user_pin_hash';
  static const _saltKey = 'user_pin_salt';

  PinService(this._storage);

  Future<void> setPin(String pin) async {
    final salt = _generateSalt();
    final hash = _hashPin(pin, salt);
    await _storage.write(_saltKey, salt);
    await _storage.write(_key, hash);
  }

  Future<bool> verifyPin(String pin) async {
    final salt = await _storage.read(_saltKey);
    final stored = await _storage.read(_key);
    if (salt == null || stored == null) return false;
    final hash = _hashPin(pin, salt);
    return hash == stored;
  }

  String _generateSalt() {
    final bytes = List<int>.generate(16, (i) => DateTime.now().microsecond.remainder(256) ^ i);
    return base64Url.encode(bytes);
  }

  String _hashPin(String pin, String salt) {
    final input = utf8.encode('$salt|$pin');
    final digest = sha256.convert(input);
    return digest.toString();
  }

  Future<void> clearPin() async {
    await _storage.delete(_key);
    await _storage.delete(_saltKey);
  }
}
