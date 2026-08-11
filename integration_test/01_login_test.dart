import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mspeed/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Login Admin E2E Test', () {
    testWidgets('Login gagal (Validasi input kosong)', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Find widgets
      final submitButton = find.byKey(const ValueKey('login.submit'));

      // Tap submit directly to trigger validation error
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      // Verify validation message appears or snackbar is shown
      // Depending on implementation, look for error text or snackbar.
      expect(find.textContaining('Maaf'), findsWidgets); 
    });

    testWidgets('Login berhasil & Navigasi ke Dashboard', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      final emailField = find.byKey(const ValueKey('login.email'));
      final passwordField = find.byKey(const ValueKey('login.password'));
      final submitButton = find.byKey(const ValueKey('login.submit'));

      // 1. Enter email
      await tester.enterText(emailField, 'admin@mspeed.com');
      await tester.pumpAndSettle();

      // 2. Enter password
      await tester.enterText(passwordField, 'password123'); // Adjust with real dummy
      await tester.pumpAndSettle();

      // 3. Tap submit
      await tester.tap(submitButton);
      await tester.pump(); // Start loading
      
      // Wait for loading to finish and navigation to occur
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // 4. Verify Dashboard is shown
      // Assumes Dashboard has a distinct identifier or text
      // Di sini kita cek apakah Dashboard Admin muncul
      expect(find.byType(BottomNavigationBar), findsOneWidget);
    });
  });
}
