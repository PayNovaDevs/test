import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/services.dart';

class NativeKeystore {
  static const _channel = MethodChannel('com.example.dex_wallet/keystore');

  static Future<void> ensureWrapKey() async {
    await _channel.invokeMethod('ensureWrapKey');
  }

  static Future<String> wrapKey(Uint8List keyBytes) async {
    final res = await _channel.invokeMethod<String>('wrapKey', {'key': base64Encode(keyBytes)});
    if (res == null) throw Exception('wrapKey returned null');
    return res;
  }

  static Future<Uint8List> unwrapKey(String wrappedBase64) async {
    final res = await _channel.invokeMethod<String>('unwrapKey', {'wrapped': wrappedBase64});
    if (res == null) throw Exception('unwrapKey returned null');
    return base64Decode(res);
  }

  static Future<void> deleteWrapKey() async {
    await _channel.invokeMethod('deleteWrapKey');
  }
}
