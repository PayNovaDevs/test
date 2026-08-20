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

  /// Write with stronger protection on Android (require device authentication) when available.
  /// This is used for wrapping key material so the OS keystore enforces user auth.
  Future<void> writeWithAuthentication(String key, String value) async {
    await _storage.write(key: key, value: value, iOptions: _iosAuthOptions(), aOptions: _androidAuthOptions());
  }

  /// Read value that was written with authentication requirement.
  Future<String?> readWithAuthentication(String key) async {
    return _storage.read(key: key, iOptions: _iosAuthOptions(), aOptions: _androidAuthOptions());
  }

  AndroidOptions _androidOptions() => const AndroidOptions(encryptedSharedPreferences: true);

  AndroidOptions _androidAuthOptions() => const AndroidOptions(encryptedSharedPreferences: true, authenticationRequired: true, authenticationValidityDurationSeconds: 0);

  IOSOptions _iosOptions() => const IOSOptions(accessibility: IOSAccessibility.first_unlock_this_device);

  // For iOS we keep the accessibility option; in production consider using kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly
  // which maps to IOSAccessibility.when_passcode_set_this_device_only if available in the plugin.
  IOSOptions _iosAuthOptions() => const IOSOptions(accessibility: IOSAccessibility.first_unlock_this_device);
}
