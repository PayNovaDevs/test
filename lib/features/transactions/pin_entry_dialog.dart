import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

import '../../l10n/app_localizations.dart';
import '../../core/security/secure_storage_service.dart';

class PinEntryDialog extends StatefulWidget {
  const PinEntryDialog({Key? key}) : super(key: key);

  @override
  _PinEntryDialogState createState() => _PinEntryDialogState();
}

class _PinEntryDialogState extends State<PinEntryDialog> {
  final _controller = TextEditingController();
  String? _error;
  final _localAuth = LocalAuthentication();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<bool> _tryBiometric() async {
    try {
      final canAuthenticate = await _localAuth.canCheckBiometrics || await _localAuth.isDeviceSupported();
      if (!canAuthenticate) return false;
      final didAuthenticate = await _localAuth.authenticate(localizedReason: 'Authenticate to approve transaction', biometricOnly: false);
      return didAuthenticate;
    } catch (_) {
      return false;
    }
  }

  Future<void> _submit() async {
    final loc = AppLocalizations.of(context);
    // First try biometric
    final bio = await _tryBiometric();
    if (bio) return Navigator.of(context).pop(true);

    final pin = _controller.text.trim();
    if (pin.length != 6) {
      setState(() => _error = loc.translate('pin_error_length'));
      return;
    }
    // Validate against secure storage (placeholder key user_pin_hash)
    try {
      final storage = SecureStorageService();
      final stored = await storage.read('user_pin_hash');
      if (stored == pin) {
        return Navigator.of(context).pop(true);
      } else {
        setState(() => _error = loc.translate('pin_error_invalid'));
      }
    } catch (_) {
      setState(() => _error = loc.translate('pin_error_invalid'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(loc.translate('enter_pin_title')),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: _controller, keyboardType: TextInputType.number, obscureText: true, maxLength: 6, decoration: InputDecoration(errorText: _error)),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(loc.translate('cancel'))),
        ElevatedButton(onPressed: _submit, child: Text(loc.translate('confirm'))),
      ],
    );
  }
}
