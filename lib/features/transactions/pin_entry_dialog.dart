import 'package:flutter/material.dart';

class PinEntryDialog extends StatefulWidget {
  const PinEntryDialog({Key? key}) : super(key: key);

  @override
  _PinEntryDialogState createState() => _PinEntryDialogState();
}

class _PinEntryDialogState extends State<PinEntryDialog> {
  final _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final pin = _controller.text.trim();
    if (pin.length != 6) {
      setState(() => _error = 'PIN must have 6 digits');
      return;
    }
    // Placeholder: accept any 6-digit pin for now. In production validate against secure storage.
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Enter PIN'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: _controller, keyboardType: TextInputType.number, obscureText: true, maxLength: 6, decoration: InputDecoration(errorText: _error)),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
        ElevatedButton(onPressed: _submit, child: const Text('Confirm')),
      ],
    );
  }
}
