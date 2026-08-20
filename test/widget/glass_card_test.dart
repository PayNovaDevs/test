import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dex_wallet/widgets/glass_card.dart';

void main() {
  testWidgets('GlassCard renders child', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: GlassCard(child: Text('Hello')))));
    expect(find.text('Hello'), findsOneWidget);
  });
}
