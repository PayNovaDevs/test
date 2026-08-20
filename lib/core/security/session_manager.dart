import 'dart:async';

import 'package:flutter/widgets.dart';

import 'secure_storage_service.dart';
import 'encryption_service.dart';
import 'biometric_service.dart';

/// SessionManager handles lock/unlock and auto-lock timeout.
class SessionManager {
  final SecureStorageService _storage;
  final BiometricService _biometric;

  static const _pinKey = 'user_pin_hash';
  Timer? _lockTimer;
  Duration _timeout = const Duration(minutes: 5);
  bool _locked = true;

  SessionManager(this._storage, this._biometric);

  bool get isLocked => _locked;

  Future<void> setPin(String pin) async {
    final hash = EncryptionService.hashPin(pin);
    await _storage.write(_pinKey, hash);
  }

  Future<bool> validatePin(String pin) async {
    final hash = EncryptionService.hashPin(pin);
    final stored = await _storage.read(_pinKey);
    if (stored == null) return false;
    return stored == hash;
  }

  Future<void> lock() async {
    _locked = true;
  }

  Future<void> unlockWithPin(String pin) async {
    final ok = await validatePin(pin);
    if (!ok) throw Exception('Invalid PIN');
    _locked = false;
    _startTimer();
  }

  Future<void> unlockWithBiometrics() async {
    final ok = await _biometric.authenticate('Unlock dex wallet');
    if (!ok) throw Exception('Biometric failed');
    _locked = false;
    _startTimer();
  }

  void _startTimer() {
    _lockTimer?.cancel();
    _lockTimer = Timer(_timeout, () => lock());
  }

  void updateTimeout(Duration d) {
    _timeout = d;
    if (!_locked) _startTimer();
  }

  void onAppBackground() {
    lock();
  }

  void dispose() {
    _lockTimer?.cancel();
  }
}
