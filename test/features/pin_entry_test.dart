import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:dex_wallet/features/transactions/pin_entry_dialog.dart';

void main() {
  testWidgets('PinEntryDialog shows and validates length', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: Builder(builder: (context) {
      return ElevatedButton(onPressed: () async {
        await showDialog(context: context, builder: (_) => const PinEntryDialog());
      }, child: const Text('Open'));
    })));

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsOneWidget);

    await tester.enterText(find.byType(TextField), '123');
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();
    expect(find.text('PIN must have 6 digits') , findsOneWidget);
  });
}
