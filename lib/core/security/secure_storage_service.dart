import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// A small wrapper around flutter_secure_storage to centralize platform options.
class SecureStorageService {
  final FlutterSecureStorage _storage;
  SecureStorageService({FlutterSecureStorage? storage}) : _storage = storage ?? const FlutterSecureStorage();

  Future<void> write(String key, String value) async {
    await _storage.write(key: key, value: value, iOptions: _iosOptions(), aOptions: _androidOptions());
  }

  Future<String?> read(String key) async {
    return _storage.read(key: key, iOptions: _iosOptions(), aOptions: _androidOptions());
  }

  Future<void> delete(String key) async {
    await _storage.delete(key: key, iOptions: _iosOptions(), aOptions: _androidOptions());
  }

  AndroidOptions _androidOptions() => const AndroidOptions(encryptedSharedPreferences: true);
  IOSOptions _iosOptions() => const IOSOptions(accessibility: IOSAccessibility.first_unlock_this_device);
}
