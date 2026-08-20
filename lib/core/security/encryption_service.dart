import 'dart:convert';
import 'package:crypto/crypto.dart';

class EncryptionService {
  // A minimal hashing utility for PIN. Do NOT store PIN in plaintext.
  static String hashPin(String pin) {
    final bytes = utf8.encode(pin);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
