import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

import '../../l10n/app_localizations.dart';
import '../../core/security/secure_storage_service.dart';
import '../../core/security/pin_service.dart';

class PinEntryDialog extends StatefulWidget {
  const PinEntryDialog({Key? key}) : super(key: key);

  @override
  _PinEntryDialogState createState() => _PinEntryDialogState();
}

class _PinEntryDialogState extends State<PinEntryDialog> {
  final _controller = TextEditingController();
  String? _error;
  final _localAuth = LocalAuthentication();
  late final SecureStorageService _storage;
  late final PinService _pinService;

  static const _failCountKey = 'pin_fail_count';
  static const _lockUntilKey = 'pin_lock_until';
  static const _maxFails = 5;
  static const _lockDurationMinutes = 5;

  bool _locked = false;
  DateTime? _lockedUntil;

  @override
  void initState() {
    super.initState();
    _storage = SecureStorageService();
    _pinService = PinService(_storage);
    _loadLockState();
  }

  Future<void> _loadLockState() async {
    try {
      final until = await _storage.read(_lockUntilKey);
      if (until != null) {
        final dt = DateTime.tryParse(until);
        if (dt != null && dt.isAfter(DateTime.now())) {
          setState(() {
            _locked = true;
            _lockedUntil = dt;
          });
        } else if (dt != null && dt.isBefore(DateTime.now())) {
          // lock expired, clear
          await _storage.delete(_lockUntilKey);
          await _storage.delete(_failCountKey);
          setState(() {
            _locked = false;
            _lockedUntil = null;
          });
        }
      }
    } catch (_) {
      // ignore storage errors
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<bool> _tryBiometric() async {
    try {
      final canAuthenticate = await _localAuth.canCheckBiometrics || await _localAuth.isDeviceSupported();
      if (!canAuthenticate) return false;
      final didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'Authenticate to approve transaction',
        biometricOnly: false,
      );
      return didAuthenticate;
    } catch (_) {
      return false;
    }
  }

  Future<void> _submit() async {
    final loc = AppLocalizations.of(context);
    if (_locked) {
      setState(() => _error = '${loc.translate('pin_locked_until')} ${_lockedUntil?.toLocal().toString()}');
      return;
    }

    // Try biometric first
    final bio = await _tryBiometric();
    if (bio) {
      // successful biometric -> reset fail counter
      await _storage.delete(_failCountKey);
      return Navigator.of(context).pop(true);
    }

    final pin = _controller.text.trim();
    if (pin.length != 6) {
      setState(() => _error = loc.translate('pin_error_length'));
      return;
    }

    final ok = await _pinService.verifyPin(pin);
    if (ok) {
      // success: clear fail count and return
      await _storage.delete(_failCountKey);
      return Navigator.of(context).pop(true);
    } else {
      // increment fail count
      int fails = 0;
      try {
        final raw = await _storage.read(_failCountKey);
        if (raw != null) fails = int.tryParse(raw) ?? 0;
      } catch (_) {}
      fails += 1;
      await _storage.write(_failCountKey, fails.toString());

      if (fails >= _maxFails) {
        final until = DateTime.now().add(const Duration(minutes: _lockDurationMinutes));
        await _storage.write(_lockUntilKey, until.toIso8601String());
        setState(() {
          _locked = true;
          _lockedUntil = until;
          _error = loc.translate('pin_locked_message');
        });
      } else {
        setState(() => _error = loc.translate('pin_error_invalid'));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(loc.translate('enter_pin_title')),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        if (_locked && _lockedUntil != null) ...[
          Text('${loc.translate('pin_locked_until')} ${_lockedUntil?.toLocal().toString()}'),
        ] else ...[
          TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            obscureText: true,
            maxLength: 6,
            decoration: InputDecoration(errorText: _error),
          ),
        ]
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(loc.translate('cancel'))),
        ElevatedButton(onPressed: _locked ? null : _submit, child: Text(loc.translate('confirm'))),
      ],
    );
  }
}
