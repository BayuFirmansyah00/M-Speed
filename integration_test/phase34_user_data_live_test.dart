import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mspeed/main.dart' as app;

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('PHASE 34 — Live User Data Full Parity Verification on Emulator', (tester) async {
    app.main();
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // If on Login screen, enter admin credentials
    final emailField = find.byKey(const ValueKey('login.email'));
    if (emailField.evaluate().isNotEmpty) {
      final passwordField = find.byKey(const ValueKey('login.password'));
      final submitButton = find.byKey(const ValueKey('login.submit'));

      await tester.enterText(emailField, 'admin@example.com');
      await tester.pumpAndSettle();

      await tester.enterText(passwordField, 'password123');
      await tester.pumpAndSettle();

      await tester.tap(submitButton);
      await tester.pumpAndSettle(const Duration(seconds: 6));
    }

    // 1. Verify Bottom Navigation "User Data"
    final userDataNav = find.text('User Data');
    expect(userDataNav, findsWidgets);

    // Tap on "User Data" navigation
    await tester.tap(userDataNav.first);
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // 2. Verify User Data Menu has 7 categories
    expect(find.text('Buyer'), findsOneWidget);
    expect(find.text('Seller'), findsOneWidget);
    expect(find.text('Keuangan'), findsOneWidget);
    expect(find.text('Penerima'), findsOneWidget);
    expect(find.text('Manager'), findsOneWidget);
    expect(find.text('Direksi'), findsOneWidget);
    expect(find.text('Audit'), findsOneWidget);

    // 3. Open Buyer
    await tester.tap(find.text('Buyer'));
    await tester.pumpAndSettle(const Duration(seconds: 4));
    expect(find.text('Daftar Buyer'), findsOneWidget);
    expect(find.text('Aktif'), findsWidgets);
    expect(find.text('Departemen'), findsWidgets);
    expect(find.text('Manager'), findsWidgets);

    // Pop back to User Data menu
    await tester.tap(find.byIcon(Icons.arrow_back_rounded).first);
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // 4. Open Seller
    await tester.tap(find.text('Seller'));
    await tester.pumpAndSettle(const Duration(seconds: 4));
    expect(find.text('Daftar Seller'), findsOneWidget);
    expect(find.text('Nama Pemilik'), findsWidgets);

    // Search for Seller ID 121: seller1@example.com
    final searchInput = find.byType(TextField);
    if (searchInput.evaluate().isNotEmpty) {
      await tester.enterText(searchInput, 'seller1@example.com');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle(const Duration(seconds: 4));

      // Verify Seller 121 record and "Tidak Aktif"
      expect(find.text('Perum Namaga Namaga PT'), findsOneWidget);
      expect(find.text('Tidak Aktif'), findsOneWidget);
      expect(find.text('seller1@example.com'), findsOneWidget);
      expect(find.text('#121'), findsOneWidget);
    }

    // Pop back
    await tester.tap(find.byIcon(Icons.arrow_back_rounded).first);
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // 5. Open Keuangan
    await tester.tap(find.text('Keuangan'));
    await tester.pumpAndSettle(const Duration(seconds: 4));
    expect(find.text('Daftar Keuangan'), findsOneWidget);
    expect(find.text('Aktif'), findsWidgets);
    expect(find.text('Departemen'), findsWidgets);

    // Pop back
    await tester.tap(find.byIcon(Icons.arrow_back_rounded).first);
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // 6. Open Penerima
    await tester.tap(find.text('Penerima'));
    await tester.pumpAndSettle(const Duration(seconds: 4));
    expect(find.text('Daftar Penerima'), findsOneWidget);
    expect(find.text('Aktif'), findsWidgets);

    // Pop back
    await tester.tap(find.byIcon(Icons.arrow_back_rounded).first);
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // 7. Open Manager
    await tester.tap(find.text('Manager'));
    await tester.pumpAndSettle(const Duration(seconds: 4));
    expect(find.text('Daftar Manager'), findsOneWidget);
    expect(find.text('Aktif'), findsWidgets);
    expect(find.textContaining('Anggota'), findsWidgets);

    // Pop back
    await tester.tap(find.byIcon(Icons.arrow_back_rounded).first);
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // 8. Open Direksi
    await tester.tap(find.text('Direksi'));
    await tester.pumpAndSettle(const Duration(seconds: 4));
    expect(find.text('Daftar Direksi'), findsOneWidget);
    // Direksi should NOT have status badge
    expect(find.text('Aktif'), findsNothing);
    expect(find.text('Tidak Aktif'), findsNothing);

    // Pop back
    await tester.tap(find.byIcon(Icons.arrow_back_rounded).first);
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // 9. Open Audit
    await tester.tap(find.text('Audit'));
    await tester.pumpAndSettle(const Duration(seconds: 4));
    expect(find.text('Daftar Audit'), findsOneWidget);
    // Audit should NOT have status badge
    expect(find.text('Aktif'), findsNothing);
    expect(find.text('Tidak Aktif'), findsNothing);
  });
}
