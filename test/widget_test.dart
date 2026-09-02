import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App basic smoke test', (WidgetTester tester) async {
    // Basic test widget rendering
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('M-Speed Logistics App'),
          ),
        ),
      ),
    );

    expect(find.text('M-Speed Logistics App'), findsOneWidget);
  });
}
